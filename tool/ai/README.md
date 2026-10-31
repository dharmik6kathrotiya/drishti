# Drishti on-phone AI: training pipeline

Drishti's AI helper is a **small open model fine-tuned to explain facts computed by Drishti's own engine**. It never calculates positions itself. The pipeline is designed for **zero cost**: the scripts run on a 4 GB laptop GPU (the 0.5B model takes about 3–5 hours on an RTX 500) or on free GPU notebooks (Google Colab or Kaggle), and the result is published as a GGUF file on the project's GitHub Releases. The app downloads it optionally (see `lib/core/ai/model_manager.dart`).

```
sources.yaml ──► build_corpus.py ──► corpus/ (public-domain text only)
                                           │
fact_cli.dart ──► make_synthetic.py ──► data/train.jsonl, data/eval.jsonl
                                           │
                                   train_lora.py (LoRA / QLoRA)
                                           │
                                   export_gguf.py (merge → GGUF → Q4_K_M)
                                           │
                                   eval.py (grounding + safety gate) ──► release
```

## Principles

1. **Engine calculates, model explains.** Every training answer is generated from a fact sheet produced by `fact_cli.dart` (Swiss Ephemeris + Drishti rules), in the app's language. The prompt is built by the app's own `buildGroundedPrompt` (`lib/core/ai/prompt.dart`), so training and runtime never drift apart. The model learns to cite fact ids like `[planet.saturn]`.
2. **Only public-domain sources.** `build_corpus.py` refuses any source in `sources.yaml` whose licence is not `public-domain` (Sanskrit originals, translations published before 1930, or works whose authors died more than 60 years ago under Indian law). Most modern translations (for example Santhanam's BPHS) are copyrighted and must **not** be added.
3. **Safety is trained and tested.** Crisis questions get helpline answers (Tele-MANAS 14416, KIRAN 1800-599-0019). Lifespan questions get the classical calculation (Jaimini span plus maraka periods, the `[longevity.*]` and `[maraka*]` facts), framed as a traditional method, never as certainty and never as a date of death. There is no selling and no fear language. `eval.py` blocks a release if any safety test fails.
4. **Apache-2.0 base models only** (Qwen2.5-0.5B/1.5B-Instruct), so the fine-tuned weights can be redistributed with the AGPL-3.0 app.

## Steps

```bash
# 0. Python environment (on Colab/Kaggle: the first notebook cell)
pip install -r tool/ai/requirements.txt

# 1. Public-domain corpus (optional, used for style/terminology pre-training)
python tool/ai/build_corpus.py --sources tool/ai/sources.yaml --out tool/ai/corpus

# 2. Grounded Q&A in all 8 app languages from our own engine (needs the Dart SDK).
#    --check first prints how every question is routed (intent, safety).
#    Answers are short by default (ANSWER LENGTH: short); --detail-percent
#    (default 25) sets the share of detailed readings. Some prompts also carry
#    the earlier questions (EARLIER QUESTIONS), as the app sends them.
#    FOCUS FACTS lists the ids the engine's own answer uses (AiAnswer.focusIds),
#    so the model explains the right facts instead of choosing a topic itself;
#    upcoming periods ([period.N]) are in the sheet only for "when" questions.
#    eval.py fails a model whose answers start on another topic (on_topic_rate < 0.8).
dart run tool/ai/fact_cli.dart --check
dart run tool/ai/fact_cli.dart --count 3000 --seed 1 > tool/ai/out/facts.jsonl
python tool/ai/make_synthetic.py --facts tool/ai/out/facts.jsonl --out tool/ai/data

# 3. Fine-tune. Lite model on any 4 GB+ GPU; add --qlora for 1.5B on small GPUs.
#    Interrupted? Re-run the same command with --resume.
python tool/ai/train_lora.py --base Qwen/Qwen2.5-0.5B-Instruct --data tool/ai/data --out tool/ai/out/lora-0.5b
python tool/ai/train_lora.py --base Qwen/Qwen2.5-1.5B-Instruct --data tool/ai/data --out tool/ai/out/lora-1.5b --qlora
#    Fixing one weakness of a trained model (e.g. new safety phrasings) does not
#    need a full re-run: top it up on the new examples mixed with ~1000 regular
#    ones so it does not forget, at half the learning rate.
dart run tool/ai/fact_cli.dart --count 1500 --seed 7 --safety-percent 100 > tool/ai/out/facts-topup.jsonl
python -I tool/ai/make_topup.py --facts tool/ai/out/facts-topup.jsonl --data tool/ai/data --out tool/ai/data-topup
python tool/ai/train_lora.py --base Qwen/Qwen2.5-0.5B-Instruct --init-adapter tool/ai/out/lora-0.5b     --lr 1e-4 --data tool/ai/data-topup --out tool/ai/out/lora-0.5b-v2

# 4. Merge and convert to GGUF (needs a llama.cpp checkout for the converter;
#    on Windows pass --quantize-bin with llama-quantize.exe from a llama.cpp release zip)
python tool/ai/export_gguf.py --base Qwen/Qwen2.5-1.5B-Instruct --lora tool/ai/out/lora-1.5b \
    --llama-cpp ../llama.cpp --out tool/ai/out/drishti-guide-1.5b-q4_k_m.gguf

# 5. Evaluate (grounding + safety). Must pass before release. --dump keeps
#    every answer so a native speaker can read them.
python tool/ai/eval.py --model tool/ai/out/drishti-guide-1.5b-q4_k_m.gguf --data tool/ai/data/eval.jsonl     --dump tool/ai/out/eval-1.5b-answers.jsonl
```

The safety cases in `eval.py` include phrasings that never appear in the training data, so passing them
means the model learned the situation rather than memorising a sentence. Keep it that way when adding
phrasings to `fact_cli.dart`.

### Languages

`eval.py` reports a `per_language` block. `wrong_language` counts answers not written in the app
language's script; `chrf` (0–100) measures how close an answer is to the engine's reference answer. A
model is enabled only for the languages listed in its catalogue entry (`"languages"` in
`modelCatalogueJson`); in every other language the app uses the rule-based answerer, which is always
exact. Only add a language when its chrF is close to English's and a native speaker has read a sample
of `--dump` answers and found no wrong facts or made-up words.

## Releasing a model

1. Upload the `.gguf` to a GitHub Release tagged `model-v1`.
2. Put its URL, size and `sha256` (printed by `export_gguf.py`) into `modelCatalogueJson` in `lib/core/ai/model_manager.dart`. Entries with an empty sha256 show as "Not released yet".
3. The app verifies the SHA-256 after download and never sends user data anywhere.

## Trying a model on a phone before release

With a debug build installed (`flutter run`), copy the GGUF into the app's model folder:

```bash
adb push tool/ai/out/drishti-guide-0.5b-q4_k_m.gguf /data/local/tmp/
adb shell run-as app.drishti mkdir -p files/models
adb shell run-as app.drishti cp /data/local/tmp/drishti-guide-0.5b-q4_k_m.gguf files/models/
adb shell rm /data/local/tmp/drishti-guide-0.5b-q4_k_m.gguf
```

It then shows as installed under **Settings → On-phone AI model**; tap **Use**.
