"""LoRA fine-tuning with a small, memory-frugal training loop.

The loss is computed only on the answer tokens, and the 152k-word output
layer runs on those positions in small checkpointed chunks. Together with
gradient checkpointing this keeps the 0.5B model under 3 GB of VRAM at
3k-token examples, so it trains on a 4 GB laptop GPU as well as on a free
Colab/Kaggle T4. Add --qlora (needs bitsandbytes) to fit the 1.5B model in
the same memory.

Base models must be Apache-2.0 (Qwen2.5-0.5B/1.5B-Instruct).

Usage:
    python tool/ai/train_lora.py --base Qwen/Qwen2.5-0.5B-Instruct \
        --data tool/ai/data --out tool/ai/out/lora-0.5b
    # interrupted? add --resume to continue from the last checkpoint
"""

import argparse
import json
import math
import pathlib
import random
import time

import torch
import torch.nn.functional as F
import transformers.integrations.sdpa_attention as sdpa_attention
from peft import LoraConfig, PeftModel, get_peft_model
from torch.nn.attention import SDPBackend, sdpa_kernel
from torch.utils.checkpoint import checkpoint
from transformers import AutoModelForCausalLM, AutoTokenizer, get_cosine_schedule_with_warmup

# Qwen shares key/value heads (GQA). PyTorch's memory-efficient attention
# kernel does not take SDPA's enable_gqa flag, so attention would silently
# fall back to the quadratic-memory "math" kernel (10x slower, and it spills
# out of a 4 GB GPU). Repeating the k/v heads instead keeps the fast kernel.
sdpa_attention.use_gqa_in_sdpa = lambda *args, **kwargs: False
FAST_ATTENTION = [SDPBackend.FLASH_ATTENTION, SDPBackend.EFFICIENT_ATTENTION]

APACHE_BASES = {
    "Qwen/Qwen2.5-0.5B-Instruct",
    "Qwen/Qwen2.5-1.5B-Instruct",
}


def encode(tokenizer, row: dict, max_len: int):
    """Token ids of prompt + answer and the index where the answer starts."""
    prompt = tokenizer.apply_chat_template(row["prompt"], tokenize=False, add_generation_prompt=True)
    full = tokenizer.apply_chat_template(row["prompt"] + row["completion"], tokenize=False)
    p_ids = tokenizer(prompt, add_special_tokens=False)["input_ids"]
    ids = tokenizer(full, add_special_tokens=False)["input_ids"]
    if ids[: len(p_ids)] != p_ids or len(ids) > max_len or len(ids) <= len(p_ids):
        return None
    return ids, len(p_ids)


def load(tokenizer, path: pathlib.Path, max_len: int, limit: int | None = None):
    rows = [json.loads(l) for l in path.read_text(encoding="utf-8").splitlines() if l.strip()]
    if limit:
        rows = rows[:limit]
    data = [e for e in (encode(tokenizer, r, max_len) for r in rows) if e]
    print(f"{path.name}: {len(data)} of {len(rows)} examples fit in {max_len} tokens", flush=True)
    return data


def answer_loss(model, ids, start: int, chunk: int = 256):
    """Mean next-token loss over the answer, without materialising the full
    sequence x vocabulary logits."""
    base = model.base_model.model  # PeftModel -> LoraModel -> CausalLM
    x = torch.tensor([ids], device=model.device)
    with sdpa_kernel(FAST_ATTENTION):
        hidden = base.model(input_ids=x).last_hidden_state[0]
    pos = torch.arange(start - 1, len(ids) - 1, device=model.device)
    h, y = hidden[pos], x[0, pos + 1]

    def part(hc, yc):
        return F.cross_entropy(base.lm_head(hc).float(), yc, reduction="sum")

    total = sum(
        checkpoint(part, h[i : i + chunk], y[i : i + chunk], use_reentrant=False) for i in range(0, len(pos), chunk)
    )
    return total / len(pos)


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--base", default="Qwen/Qwen2.5-1.5B-Instruct")
    ap.add_argument("--data", required=True)
    ap.add_argument("--out", required=True)
    ap.add_argument("--epochs", type=float, default=1)
    ap.add_argument("--lr", type=float, default=2e-4)
    ap.add_argument("--rank", type=int, default=16)
    ap.add_argument("--accum", type=int, default=16, help="examples per optimizer step")
    ap.add_argument("--max-len", type=int, default=3000)
    ap.add_argument("--limit", type=int, help="use only the first N training examples")
    ap.add_argument("--max-steps", type=int, help="stop early (for timing runs)")
    ap.add_argument("--save-every", type=int, default=25, help="optimizer steps between checkpoints")
    ap.add_argument("--qlora", action="store_true", help="4-bit base weights (saves memory)")
    ap.add_argument("--resume", action="store_true", help="continue from the checkpoint in --out")
    ap.add_argument("--init-adapter", help="start from a trained adapter (a short top-up run on new data)")
    ap.add_argument("--seed", type=int, default=1)
    args = ap.parse_args()

    if args.base not in APACHE_BASES:
        raise SystemExit(f"{args.base} is not in the reviewed list of permissively licensed bases.")

    random.seed(args.seed)
    torch.manual_seed(args.seed)
    out = pathlib.Path(args.out)
    ckpt = out / "checkpoint"
    out.mkdir(parents=True, exist_ok=True)

    bf16 = torch.cuda.is_available() and torch.cuda.is_bf16_supported()
    dtype = torch.bfloat16 if bf16 else torch.float16
    tokenizer = AutoTokenizer.from_pretrained(args.base)
    quant = None
    if args.qlora:
        from transformers import BitsAndBytesConfig

        quant = BitsAndBytesConfig(load_in_4bit=True, bnb_4bit_quant_type="nf4", bnb_4bit_compute_dtype=dtype)
    model = AutoModelForCausalLM.from_pretrained(
        args.base, dtype=dtype, quantization_config=quant, device_map="cuda", attn_implementation="sdpa"
    )
    model.gradient_checkpointing_enable(gradient_checkpointing_kwargs={"use_reentrant": False})
    model.enable_input_require_grads()
    model.config.use_cache = False
    if args.resume and (ckpt / "adapter_config.json").exists():
        model = PeftModel.from_pretrained(model, ckpt, is_trainable=True)
    elif args.init_adapter:
        model = PeftModel.from_pretrained(model, args.init_adapter, is_trainable=True)
    else:
        model = get_peft_model(
            model,
            LoraConfig(
                r=args.rank,
                lora_alpha=args.rank * 2,
                lora_dropout=0.05,
                target_modules=["q_proj", "k_proj", "v_proj", "o_proj", "gate_proj", "up_proj", "down_proj"],
                task_type="CAUSAL_LM",
            ),
        )
    model.print_trainable_parameters()

    data_dir = pathlib.Path(args.data)
    train = load(tokenizer, data_dir / "train.jsonl", args.max_len, args.limit)
    evals = load(tokenizer, data_dir / "eval.jsonl", args.max_len, 100)
    # Same shuffled order on every run, so --resume continues where it stopped.
    rng = random.Random(args.seed)
    order = [i for _ in range(math.ceil(args.epochs)) for i in rng.sample(range(len(train)), len(train))]
    order = order[: int(len(train) * args.epochs)]
    total_steps = len(order) // args.accum
    if args.max_steps:
        total_steps = min(total_steps, args.max_steps)

    params = [p for p in model.parameters() if p.requires_grad]
    opt = torch.optim.AdamW(params, lr=args.lr, weight_decay=0.0)
    sched = get_cosine_schedule_with_warmup(opt, max(1, int(total_steps * 0.03)), total_steps)
    step = 0
    state_file = ckpt / "trainer_state.pt"
    if args.resume and state_file.exists():
        state = torch.load(state_file, weights_only=False)
        opt.load_state_dict(state["opt"])
        sched.load_state_dict(state["sched"])
        step = state["step"]
        print(f"resumed at step {step}/{total_steps}", flush=True)

    def evaluate() -> float:
        model.eval()
        with torch.no_grad():
            losses = [answer_loss(model, ids, start).item() for ids, start in evals]
        model.train()
        return sum(losses) / max(1, len(losses))

    def save(dir_: pathlib.Path) -> None:
        model.save_pretrained(dir_)
        tokenizer.save_pretrained(dir_)
        torch.save({"opt": opt.state_dict(), "sched": sched.state_dict(), "step": step}, dir_ / "trainer_state.pt")

    model.train()
    log = (out / "train_log.jsonl").open("a", encoding="utf-8")
    t0, first = time.time(), step
    running = 0.0
    while step < total_steps:
        batch = order[step * args.accum : (step + 1) * args.accum]
        for i in batch:
            ids, start = train[i]
            loss = answer_loss(model, ids, start) / len(batch)
            with sdpa_kernel(FAST_ATTENTION):  # the recomputation in backward
                loss.backward()
            running += loss.item()
        torch.nn.utils.clip_grad_norm_(params, 1.0)
        opt.step()
        sched.step()
        opt.zero_grad(set_to_none=True)
        step += 1
        if step % 5 == 0 or step == total_steps:
            per = (time.time() - t0) / (step - first)
            entry = {
                "step": step,
                "of": total_steps,
                "loss": round(running / 5, 4),
                "lr": round(sched.get_last_lr()[0], 7),
                "eta_min": round(per * (total_steps - step) / 60),
            }
            print(json.dumps(entry), flush=True)
            log.write(json.dumps(entry) + "\n")
            log.flush()
            running = 0.0
        if step % args.save_every == 0 and step < total_steps:
            save(ckpt)
    save(ckpt)
    model.save_pretrained(out)
    tokenizer.save_pretrained(out)
    entry = {"eval_loss": round(evaluate(), 4)}
    print(json.dumps(entry), flush=True)
    log.write(json.dumps(entry) + "\n")
    print(f"LoRA adapter saved to {out}", flush=True)


if __name__ == "__main__":
    main()
