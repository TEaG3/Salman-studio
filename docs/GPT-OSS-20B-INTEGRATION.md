# GPT-OSS 20B adoption for TEa.G3-studio

**Decision:** adopt `openai/gpt-oss-20b` as the preferred primary reasoning model for the TEa.G3 AI Director, subject to hardware and runtime validation. This is an integration target, not a claim that the model is already installed, hosted, or connected to the app.

## Why this model

- Open-weight model published by OpenAI under the Apache-2.0 license (verify the model card and license again when pinning a release).
- Intended for reasoning, agentic workflows, tool use, and structured responses.
- The 20B variant is the realistic first candidate for local/self-hosted experimentation. The 120B variant is not the baseline target because its published hardware requirements are far beyond typical free hosting.
- It is a text/reasoning model. It does **not** generate images, video, animation, or audio.

Model card: https://huggingface.co/openai/gpt-oss-20b

## Responsibility boundary

GPT-OSS 20B is the **AI Director**, not the media engine.

It may:
1. Interpret Arabic and English creative briefs.
2. Ask for missing information and produce a structured edit/generation plan.
3. Select only tools advertised by the TEa.G3 capability registry.
4. Propose calls to image, video, audio, asset, and rendering tools.
5. Explain unsupported operations and resource constraints.

Separate components perform the actual work:
- Image generation/editing: a separately selected image model or ComfyUI/Diffusers workflow.
- Video generation/animation: a separately selected video model and available compute.
- Audio: dedicated speech/audio tools.
- Deterministic editing, compositing, subtitles, and export: the editor and media pipeline (for example, FFmpeg where integrated).

Arabic/English text, especially Arabic right-to-left shaping, should remain an editable deterministic text layer and must not rely on text embedded inside generated images.

## Runtime strategy

Initial local evaluation target:
- Ollama model reference: `gpt-oss:20b`
- OpenAI-compatible local endpoint: `http://127.0.0.1:11434/v1`
- Model download/run instructions: see the official model card and Ollama's current documentation.

The model card indicates the quantized 20B model can run within roughly 16 GB of memory, but actual requirements depend on quantization, context length, runtime overhead, and concurrent requests. Treat this as a feasibility guideline, not a guarantee for every device. Benchmark on the target hardware before enabling it.

For a hosted deployment, use only a machine/GPU allocation whose availability, privacy terms, and cost are known. A free CPU web host is not sufficient for dependable model inference. Do not assume free GPU availability.

## Integration contract

Implement GPT-OSS behind a provider-neutral adapter. The app and Android client must not call Ollama or a model vendor directly.

The adapter must:
- Be disabled unless explicitly configured.
- Default to a local endpoint; reject non-local endpoints unless remote inference is deliberately enabled by an administrator.
- Keep endpoint credentials server-side and out of Git, mobile binaries, and client responses.
- Send only the text and project metadata needed for the requested operation. Media files stay local unless the user explicitly opts into a separately disclosed upload workflow.
- Validate every model response against a versioned TEa.G3 plan schema before accepting it.
- Treat model tool calls as proposals. The backend checks tool names, arguments, permissions, capabilities, quotas, and user approval before execution.
- Never allow model output to run arbitrary shell commands, code, URLs, or filesystem paths.
- Require explicit confirmation for destructive actions, external uploads, public sharing, or any paid operation.
- Report model unavailable, timeout, invalid output, and insufficient compute as explicit states; never fabricate a completed job.
- Record model identifier/version and inference mode for reproducibility, without logging private media or secrets.

## Fallback and cost policy

Provider priority:
1. `gpt_oss_local` — optional, when a local runtime is configured and healthy.
2. `rule_based` — always-available deterministic fallback for basic planning and validation.
3. Any remote/paid provider — disabled by default and usable only after explicit user approval and clear disclosure.

No paid API, paid agent subscription, automatic upgrade, or paid fallback is required for normal app operation. Open weights are free to download under their license; inference still consumes hardware, electricity, storage, and potentially hosting resources.

## Delivery stages

1. **Adopted:** select GPT-OSS 20B as the preferred AI Director model.
2. **Adapter:** add a provider-neutral local inference adapter with strict configuration and safe response validation.
3. **Evaluation:** test Arabic/English briefs, schema validity, tool selection, refusal of unsupported actions, latency, memory use, and reliability on actual target hardware.
4. **Tool registry:** connect only implemented and tested media capabilities; expose unavailable tools as unavailable.
5. **App integration:** route approved requests through the backend; retain rule-based/offline operation.
6. **Optional hosting:** enable remote inference only after a real free compute allocation and privacy/security review are confirmed.

## Current status

The repository now contains an optional Ollama adapter and local-only FastAPI endpoints (`GET /v1/ai/status`, `POST /v1/ai/chat`) plus mocked adapter tests. This is not evidence of a real inference run: model weights still need to be downloaded and Ollama must be running on the target computer. No image/video/audio engines are connected. The existing FastAPI backend remains local-development-only until authentication, PostgreSQL, and secure storage are implemented.
