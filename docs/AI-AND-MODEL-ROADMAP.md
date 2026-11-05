# TEa.G3 AI and custom model roadmap

## Chosen approach: hybrid, staged

TEa.G3 starts as an orchestration system over existing models and evolves toward a specialized model only after collecting permissioned, high-quality training and evaluation data.

## Stage A — model-agnostic AI gateway

The gateway owns:
- provider selection and configuration;
- authentication and server-side secret handling;
- prompt templates and structured response validation;
- tool routing and capability checks;
- rate limits, usage accounting, and error handling;
- user consent checks before any user content is sent externally.

The Android and web clients call TEa.G3 endpoints. They never contain provider API keys.

## Stage B — editing agent

The agent translates a natural-language brief into a typed edit plan. The plan must use the shared EDL schema and only operations supported by the installed media engine.

Example intent:
- "Make a 30-second vertical highlight from these selected clips."

Expected response:
- target aspect ratio and duration;
- ordered clip references;
- proposed in/out points;
- caption and audio instructions;
- warnings and missing information;
- explicit status: proposal, approved, rendering, or verified.

The agent cannot mark a project as rendered. Only the render service can do so after output verification.

## Stage C — custom model research

Do not train from scratch initially. Evaluate small and medium open-weight models that can be served within the available hardware and budget.

Potential specialization techniques, in order:
1. Prompting and structured output.
2. Retrieval over TEa.G3 editing documentation and capability registry.
3. Tool-use examples and supervised fine-tuning.
4. Preference optimization only if there is a reviewed preference dataset and a measurable need.

Training data must be licensed or user-contributed with explicit permission. Remove personal media and sensitive details unless specifically necessary and consented to. Keep a held-out evaluation set that is not used for training.

## Evaluation gates

A model is eligible for production only after it passes:
- valid EDL/schema rate;
- correct tool selection;
- edit-plan quality reviewed by people;
- Arabic and English instruction handling;
- refusal of unsupported operations;
- privacy and destructive-action safeguards;
- latency and cost budgets.

## Model deployment

The custom model is an optional provider behind the same gateway. If unavailable, route to an approved external provider or return a clear offline response. Never silently upload media.

## Not promised yet

No custom model has been trained, hosted, or benchmarked at this stage. This document is a build plan, not evidence of a deployed model.
