"""Build a top-up training set: new safety/lifespan examples mixed with
regular ones, so a trained adapter learns the change without forgetting.

The safety facts must come from fact_cli.dart run with --safety-percent 100,
so the last example of every chart is a crisis or lifespan question.

Usage:
    dart run tool/ai/fact_cli.dart --count 1500 --seed 7 --safety-percent 100 > tool/ai/out/facts-topup.jsonl
    python -I tool/ai/make_topup.py --facts tool/ai/out/facts-topup.jsonl --data tool/ai/data --out tool/ai/data-topup
"""

import argparse
import json
import pathlib
import random
import shutil


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--facts", required=True, help="fact_cli.dart output with --safety-percent 100")
    ap.add_argument("--data", required=True, help="regular dataset (train.jsonl, eval.jsonl)")
    ap.add_argument("--out", required=True)
    ap.add_argument("--regular", type=int, default=1000, help="regular examples to mix in")
    ap.add_argument("--crisis", type=int, default=300, help="crisis examples to keep (all lifespan ones are kept)")
    ap.add_argument("--seed", type=int, default=7)
    args = ap.parse_args()
    random.seed(args.seed)

    data = pathlib.Path(args.data)
    eval_ids = {json.loads(l)["id"] for l in (data / "eval.jsonl").read_text(encoding="utf-8").splitlines()}
    lifespan, crisis = [], []
    for line in pathlib.Path(args.facts).read_text(encoding="utf-8").splitlines():
        chart = json.loads(line)
        if chart["id"] in eval_ids:
            continue
        ex = chart["examples"][-1]
        row = {
            "id": chart["id"],
            "lang": chart["lang"],
            "facts": chart["facts"],
            "prompt": [{"role": "system", "content": ex["system"]}, {"role": "user", "content": ex["user"]}],
            "completion": [{"role": "assistant", "content": ex["assistant"]}],
        }
        # Crisis answers carry the helplines; lifespan answers never do.
        (crisis if "14416" in ex["assistant"] else lifespan).append(row)

    regular = [json.loads(l) for l in (data / "train.jsonl").read_text(encoding="utf-8").splitlines()]
    regular = [r for r in regular if "14416" not in r["completion"][0]["content"] and "[longevity." not in r["prompt"][1]["content"]]
    rows = lifespan + random.sample(crisis, min(args.crisis, len(crisis))) + random.sample(regular, args.regular)
    random.shuffle(rows)

    out = pathlib.Path(args.out)
    out.mkdir(parents=True, exist_ok=True)
    with (out / "train.jsonl").open("w", encoding="utf-8") as f:
        for r in rows:
            f.write(json.dumps(r, ensure_ascii=False) + "\n")
    shutil.copy(data / "eval.jsonl", out / "eval.jsonl")
    print(f"train: {len(rows)} ({len(lifespan)} lifespan, {min(args.crisis, len(crisis))} crisis, {args.regular} regular)")


if __name__ == "__main__":
    main()
