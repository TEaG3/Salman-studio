# TEa.G3 Open Model and Media Engine Strategy

## Architecture

Keep the language-model director separate from media generation and deterministic rendering. The director creates typed plans and calls approved tools. Image, video, and audio engines generate media. FFmpeg and a timeline engine assemble and encode deliverables.

## Candidate components

- ComfyUI: modular local workflow engine with an API and support for image, video, audio and 3D workflows. The application is GPL-3.0; custom nodes and model weights have their own licenses.
- Hugging Face Diffusers: Python building blocks for diffusion pipelines, adapters, quantization and optimized inference. Check each checkpoint and adapter license separately.
- HunyuanVideo, Wan, LTX-Video and CogVideoX: candidates for open-weight video generation. Hardware requirements and model terms vary substantially.
- DeepSeek, Qwen and Kimi open-weight releases: candidates for text planning, structured output and tool routing. Verify the exact release and license before deployment.
- FFmpeg: deterministic media processing, encoding, audio mixing, subtitles and filters. Choose a build whose license and codec terms fit the deployment.

## Quality policy

Store native generation dimensions separately from post-upscale dimensions. Never label an upscaled output as native 4K generation. Benchmark prompt adherence, temporal consistency, identity consistency when requested, text accuracy, artifact rate and human review. Render Arabic and English typography as editable post-production layers rather than relying on image models to spell text correctly.

## Hardware and licensing

Open weights may be free to download, but inference still requires compute, storage and electricity. The router must check hardware before choosing a model. Record model card, weight license, code license, commercial-use limits, attribution, VRAM needs, native resolutions and supported modalities for every model. A repository license does not automatically cover model weights or third-party nodes.

## Status

This is a selection strategy, not evidence that models are installed or hosted. The current app has not yet integrated ComfyUI, Diffusers, video-generation weights or an FFmpeg multi-track render worker.
