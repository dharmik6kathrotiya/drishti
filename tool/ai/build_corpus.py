"""Collect the optional public-domain text corpus.

Refuses every source whose licence in sources.yaml is not exactly
`public-domain`, and every source without a URL. Output: one cleaned UTF-8
text file per source plus a manifest recording where each came from.

Usage:
    python -I tool/ai/build_corpus.py --sources tool/ai/sources.yaml --out tool/ai/corpus
"""

import argparse
import hashlib
import json
import pathlib
import re
import sys

import requests
import yaml
from bs4 import BeautifulSoup

ALLOWED_LICENCE = "public-domain"


def clean(text: str) -> str:
    text = re.sub(r"\r\n?", "\n", text)
    text = re.sub(r"[ \t]+", " ", text)
    text = re.sub(r"\n{3,}", "\n\n", text)
    return text.strip()


def fetch(url: str) -> str:
    res = requests.get(url, timeout=60, headers={"User-Agent": "drishti-corpus/1.0"})
    res.raise_for_status()
    if "html" in res.headers.get("content-type", ""):
        return BeautifulSoup(res.text, "html.parser").get_text("\n")
    return res.text


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--sources", required=True)
    ap.add_argument("--out", required=True)
    args = ap.parse_args()

    out = pathlib.Path(args.out)
    out.mkdir(parents=True, exist_ok=True)
    sources = yaml.safe_load(pathlib.Path(args.sources).read_text(encoding="utf-8"))["sources"]

    manifest = []
    for s in sources:
        sid, licence, url = s["id"], s.get("licence", "unknown"), (s.get("url") or "").strip()
        if licence != ALLOWED_LICENCE:
            print(f"SKIP {sid}: licence is '{licence}', only '{ALLOWED_LICENCE}' is allowed", file=sys.stderr)
            continue
        if not url:
            print(f"SKIP {sid}: no verified URL yet", file=sys.stderr)
            continue
        text = clean(fetch(url))
        path = out / f"{sid}.txt"
        path.write_text(text, encoding="utf-8")
        manifest.append({
            "id": sid,
            "title": s.get("title"),
            "url": url,
            "licence": licence,
            "basis": s.get("basis"),
            "sha256": hashlib.sha256(text.encode("utf-8")).hexdigest(),
            "chars": len(text),
        })
        print(f"OK   {sid}: {len(text)} chars")

    (out / "manifest.json").write_text(json.dumps(manifest, indent=2, ensure_ascii=False), encoding="utf-8")
    print(f"{len(manifest)} sources written to {out}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
