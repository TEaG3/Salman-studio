# TEa.G3 creative production algorithm

1. **Brief intake:** accept Arabic or English instructions, selected assets, output profile and local/cloud preference.
2. **Asset inspection:** read only permitted metadata such as type, dimensions, duration, frame rate and audio streams.
3. **Intent extraction:** classify the task as personal montage, portrait enhancement, social video, motion graphics, subtitles, audio processing or image work.
4. **Capability matching:** check installed engines, model modality, license, hardware, provider availability and output constraints.
5. **Plan generation:** create a versioned edit decision list and scene plan. Unsupported operations become warnings, not fabricated results.
6. **Validation:** verify asset references, source ranges, timeline intervals, caption timing, aspect ratio, codecs, memory and storage.
7. **Approval:** show the plan and disclose external processing or costs. Require approval before paid calls, cloud uploads or destructive edits.
8. **Execution:** route generation tasks to image/video/audio models and deterministic editing to the media renderer.
9. **Quality control:** verify file readability, dimensions, frame rate, duration, audio streams and caption bounds.
10. **Delivery:** provide the verified output, provenance and editable project.

## Model router

Reject a candidate when its license is incompatible, modality is missing, hardware is insufficient or it cannot satisfy required native output constraints. Rank eligible candidates by benchmarked task quality, prompt adherence, temporal consistency, native resolution, latency and estimated cost. Scores are routing aids, not guarantees.

Arabic and English text should remain editable Unicode layers with explicit RTL/LTR direction and correct font shaping. Render typography after image/video generation to preserve spelling accuracy.

Native generation dimensions and post-upscale dimensions must be stored separately. A renderer may mark a job complete only after it verifies the output.
