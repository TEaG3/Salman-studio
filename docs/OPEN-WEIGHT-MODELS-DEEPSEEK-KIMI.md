# DeepSeek and Kimi open-weight integration

## Decision

TEa.G3-studio now has local-only backend adapter targets for three model families:

| Provider key | Official model | Intended role | License shown on model card |
|---|---|---|---|
| `gpt_oss_local` | `openai/gpt-oss-20b` | General AI Director and tool planning | Apache-2.0 |
| `deepseek_local` | `deepseek-ai/DeepSeek-R1-Distill-Qwen-7B` | Reasoning, coding and second-opinion planning | MIT (review upstream base-model notices) |
| `kimi_local` | `moonshotai/Kimi-VL-A3B-Instruct` | Visual understanding, OCR, image/video review | MIT |

Official model cards:
- DeepSeek R1 Distill 7B: https://huggingface.co/deepseek-ai/DeepSeek-R1-Distill-Qwen-7B
- Kimi-VL A3B Instruct: https://huggingface.co/moonshotai/Kimi-VL-A3B-Instruct
- GPT-OSS 20B: https://huggingface.co/openai/gpt-oss-20b

## Why these variants

### DeepSeek

The full DeepSeek-R1 model is a 671B-parameter MoE model and is not a sensible target for a free, small host. DeepSeek publishes distilled variants; the 7B Qwen distilled model is a more realistic first local evaluation candidate. Its model card states MIT licensing and documents the Qwen2.5 base lineage. Review all upstream notices before redistribution.

### Kimi

Kimi K2 is open-weight, but its model card describes a 1T-parameter model with 32B activated parameters. It is not the default for free hosting or ordinary desktop hardware.

For TEa.G3's media workflow, the more practical initial Kimi choice is Kimi-VL-A3B-Instruct: 16B total parameters, 3B activated, 128K context, and multimodal image/video/document understanding. The model card recommends this Instruct variant for general multimodal perception, OCR, long video/document understanding and agent use. It is MIT-licensed according to its model card.

The selected Kimi model can understand visual inputs, but **the current TEa.G3 endpoint only sends text**. Image/video upload and multimodal request handling are a separate integration stage and are not claimed to work yet.

## Backend adapter

The FastAPI backend supports:
- `GET /v1/ai/status`
- `POST /v1/ai/chat`

Select exactly one local provider per backend process using `TEAG3_AI_PROVIDER`:
- `gpt_oss_local` — Ollama on localhost port 11434.
- `deepseek_local` — OpenAI-compatible local inference server on localhost port 8001.
- `kimi_local` — OpenAI-compatible local inference server on localhost port 8002.

The adapter rejects remote hosts and unexpected ports. The DeepSeek and Kimi servers must be started separately by the user on the same computer as the backend. The app does not download model weights automatically.

### DeepSeek local server example

Install a compatible vLLM/SGLang runtime using its official installation guide, then serve the exact model ID:

```bash
vllm serve deepseek-ai/DeepSeek-R1-Distill-Qwen-7B --host 127.0.0.1 --port 8001
```

### Kimi local server example

Use a vLLM/SGLang version compatible with the model card and serve:

```bash
vllm serve moonshotai/Kimi-VL-A3B-Instruct --host 127.0.0.1 --port 8002
```

Model-specific runtime compatibility changes over time. Check the official model card before installing the runtime. Kimi's model card documents vLLM/SGLang deployment paths.

### Select the provider

PowerShell example for DeepSeek:

```powershell
$env:TEAG3_AI_PROVIDER="deepseek_local"
$env:TEAG3_DEEPSEEK_URL="http://127.0.0.1:8001"
$env:TEAG3_DEEPSEEK_MODEL="deepseek-ai/DeepSeek-R1-Distill-Qwen-7B"
uvicorn app:app --reload
```

PowerShell example for Kimi:

```powershell
$env:TEAG3_AI_PROVIDER="kimi_local"
$env:TEAG3_KIMI_URL="http://127.0.0.1:8002"
$env:TEAG3_KIMI_MODEL="moonshotai/Kimi-VL-A3B-Instruct"
uvicorn app:app --reload
```

Check status at `http://127.0.0.1:8000/v1/ai/status`. Send text requests to `POST http://127.0.0.1:8000/v1/ai/chat` using JSON:

```json
{"message":"اكتب خطة لمشهد فيديو قصير","language":"ar"}
```

## Safety, privacy and cost

- Local endpoints only; no remote API or paid fallback is enabled.
- Never expose these unauthenticated development endpoints to the public internet.
- Model downloads and inference require disk, RAM/VRAM, electricity and compute. Open weights do not make inference compute free.
- Do not send private images/videos to a remote service without explicit consent and a separate privacy review.
- Model output is text only at the current API boundary. It does not execute tools or create media files.
- The adapter is a transport integration, not proof of successful real inference. Run a real test on target hardware before marking a model ready.

## Current validation state

Automated tests use mocked local-server responses. They validate provider selection, localhost restrictions and response parsing. They do not download weights, benchmark GPU/RAM, or prove real inference. The backend remains local-development-only pending authentication, PostgreSQL, and secure storage.
