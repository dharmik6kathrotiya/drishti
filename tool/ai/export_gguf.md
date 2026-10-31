# Exporting the fine-tuned model to GGUF

The app runs models through [llamadart](https://pub.dev/packages/llamadart) (llama.cpp), which loads **GGUF** files.

1. Build llama.cpp once (free; works on the Colab/Kaggle machine):
   ```bash
   git clone https://github.com/ggml-org/llama.cpp ../llama.cpp
   cmake -S ../llama.cpp -B ../llama.cpp/build -DLLAMA_CURL=OFF
   cmake --build ../llama.cpp/build --target llama-quantize -j
   pip install -r ../llama.cpp/requirements/requirements-convert_hf_to_gguf.txt
   ```
2. Run `python tool/ai/export_gguf.py ...` (see README). It:
   - merges the LoRA adapter into the base weights (fp16),
   - converts them with `convert_hf_to_gguf.py`,
   - quantizes them with `llama-quantize` to **Q4_K_M**: about 1 GB for 1.5B or about 400 MB for 0.5B, which suits phones with 3–6 GB of RAM,
   - prints the size and SHA-256 for the app's model catalogue.
3. Run `eval.py` on the GGUF. Release only if it passes.

Licence: the Qwen2.5-0.5B and 1.5B Instruct bases are Apache-2.0. Ship their `LICENSE` and `NOTICE` files with the release assets.
