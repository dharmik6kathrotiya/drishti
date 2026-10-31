"""Merge the LoRA adapter, convert to GGUF and quantize to Q4_K_M.

Requires a local llama.cpp checkout (for convert_hf_to_gguf.py and the
llama-quantize binary). See export_gguf.md for details.

Usage:
    python tool/ai/export_gguf.py --base Qwen/Qwen2.5-1.5B-Instruct \
        --lora tool/ai/out/lora-1.5b --llama-cpp ../llama.cpp \
        --out tool/ai/out/drishti-guide-1.5b-q4_k_m.gguf
"""

import argparse
import hashlib
import pathlib
import shutil
import subprocess
import sys

import torch
from peft import PeftModel
from transformers import AutoModelForCausalLM, AutoTokenizer


def sha256(path: pathlib.Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--base", required=True)
    ap.add_argument("--lora", required=True)
    ap.add_argument("--llama-cpp", required=True, help="path to a llama.cpp checkout with built tools")
    ap.add_argument("--out", required=True)
    ap.add_argument("--quant", default="Q4_K_M")
    ap.add_argument("--quantize-bin", help="llama-quantize executable (default: PATH, then <llama-cpp>/build/bin)")
    args = ap.parse_args()

    out = pathlib.Path(args.out)
    work = out.parent / (out.stem + "-work")
    merged = work / "merged"
    work.mkdir(parents=True, exist_ok=True)

    print("1/3 merging adapter")
    base = AutoModelForCausalLM.from_pretrained(args.base, dtype=torch.float16)
    model = PeftModel.from_pretrained(base, args.lora).merge_and_unload()
    model.save_pretrained(merged, safe_serialization=True)
    AutoTokenizer.from_pretrained(args.lora).save_pretrained(merged)

    llama = pathlib.Path(args.llama_cpp)
    f16 = work / "model-f16.gguf"
    print("2/3 converting to GGUF")
    subprocess.run(
        [sys.executable, str(llama / "convert_hf_to_gguf.py"), str(merged), "--outfile", str(f16), "--outtype", "f16"],
        check=True,
    )

    print(f"3/3 quantizing to {args.quant}")
    quantize = args.quantize_bin or shutil.which("llama-quantize") or str(llama / "build" / "bin" / "llama-quantize")
    subprocess.run([quantize, str(f16), str(out), args.quant], check=True)

    size = out.stat().st_size
    print(f"\nDone: {out}\n  size   {size} bytes\n  sha256 {sha256(out)}")
    print("Copy size and sha256 into modelCatalogueJson in lib/core/ai/model_manager.dart.")


if __name__ == "__main__":
    main()
