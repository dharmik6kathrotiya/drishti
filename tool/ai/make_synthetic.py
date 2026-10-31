"""Turn fact_cli.dart output into prompt/completion training data.

fact_cli.dart already builds every example with the app's own system prompt
and buildGroundedPrompt, and composes the target answer from engine output
in the app language. This script only splits by chart (so no chart appears
in both train and eval), drops any target that would fail the app's own
output guard, and writes TRL's conversational prompt/completion format, so
the loss is computed on the answer only.

Usage:
    python -I tool/ai/make_synthetic.py --facts tool/ai/out/facts.jsonl --out tool/ai/data
"""

import argparse
import collections
import json
import pathlib
import random
import re

# Keep in sync with Safety.forbiddenOutput in lib/core/ai/safety.dart and eval.py.
FORBIDDEN = [
    r"\bguarante\w*",
    r"\b100 ?%",
    r"\b(definitely|certainly|surely) will\b",
    r"\bwill (definitely|certainly|surely)\b",
    r"\b(curse[ds]?|doomed|ruined|cursed)\b",
    r"\b(buy|purchase|order now|shop|store|price|discount|₹|rs\.? ?\d)",
    r"\b(you|he|she|they) will die\b",
    r"\b(death|accident) (will happen|in \d{4})",
]


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--facts", required=True)
    ap.add_argument("--out", required=True)
    ap.add_argument("--eval-fraction", type=float, default=0.04)
    ap.add_argument("--seed", type=int, default=7)
    args = ap.parse_args()

    random.seed(args.seed)
    charts = [json.loads(l) for l in pathlib.Path(args.facts).read_text(encoding="utf-8").splitlines() if l.strip()]
    random.shuffle(charts)
    n_eval = max(1, int(len(charts) * args.eval_fraction))

    out = pathlib.Path(args.out)
    out.mkdir(parents=True, exist_ok=True)
    for name, rows in (("eval", charts[:n_eval]), ("train", charts[n_eval:])):
        langs = collections.Counter()
        dropped = 0
        examples = []
        for chart in rows:
            for ex in chart["examples"]:
                if any(re.search(p, ex["assistant"], re.I) for p in FORBIDDEN):
                    dropped += 1
                    continue
                langs[chart["lang"]] += 1
                examples.append({
                    "id": chart["id"],
                    "lang": chart["lang"],
                    "facts": chart["facts"],
                    "prompt": [
                        {"role": "system", "content": ex["system"]},
                        {"role": "user", "content": ex["user"]},
                    ],
                    "completion": [{"role": "assistant", "content": ex["assistant"]}],
                })
        random.shuffle(examples)
        with (out / f"{name}.jsonl").open("w", encoding="utf-8") as f:
            for e in examples:
                f.write(json.dumps(e, ensure_ascii=False) + "\n")
        print(f"{name}: {len(examples)} examples from {len(rows)} charts, dropped {dropped}; {dict(langs)}")


if __name__ == "__main__":
    main()
