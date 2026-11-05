---
name: video-edit
description: Plan and assist with video-editing projects in Frame Studio, including clip organization, trimming plans, captions, audio, color, and export checks.
---

# Video Editing Skill — Frame Studio

Use this skill when the user asks to plan, organize, or perform video-editing work in Frame Studio.

## Core behavior

- Treat Frame Studio as a local-first editor. Keep editing workflows usable offline whenever possible.
- First inspect the available project files and the actual capabilities implemented in the current app version.
- Never claim that a trim, transition, filter, caption, or export has been rendered unless the app or media engine confirms it.
- In the current MVP, in/out points are project metadata only. Do not describe them as an exported trim.
- Preserve original media. Work on copies or non-destructive project metadata unless the user explicitly asks otherwise.
- Before replacing or deleting a project/media file, explain what will change and obtain confirmation.
- Do not upload media, transcripts, or project files to an AI provider without explicit user consent.
- If cloud AI is unavailable or declined, continue with offline editing guidance.

## Editing workflow

1. **Understand the target**
   - Identify the desired platform/aspect ratio (for example 16:9, 9:16, or 1:1), approximate duration, language, and intended audience.
   - Ask only for missing information that materially affects the edit.

2. **Inspect source media**
   - List the clips and their durations, dimensions, frame rates, and audio presence when these details are available.
   - Keep source filenames and original files intact.
   - Flag unsupported or unreadable media rather than guessing.

3. **Build an edit plan**
   - Arrange clips in narrative order.
   - Record proposed in/out points in milliseconds.
   - Include a short purpose for each cut and note any continuity issue.
   - Keep a clear distinction between a proposed edit decision list and a rendered output.

4. **Captions and titles**
   - Support Arabic right-to-left text and English left-to-right text.
   - Check spelling, punctuation, line length, safe margins, and timing.
   - Do not invent spoken words. Mark uncertain transcription for review.

5. **Audio**
   - Note dialogue, music, and effects as separate elements when the editor supports tracks.
   - Recommend intelligible dialogue levels and smooth fades.
   - Do not imply that audio has been mixed or normalized unless processing has actually run.

6. **Color and framing**
   - Recommend exposure, contrast, saturation, white balance, and crop adjustments based on the footage.
   - Preserve the original aspect ratio unless the user requests a different output.
   - Avoid destructive changes to the source.

7. **Export verification**
   - Confirm target resolution, frame rate, container, codec, and audio format before export.
   - Verify that the output file exists and can be opened before reporting success.
   - If rendering is not implemented in the current build, state that clearly and provide the edit plan instead.

## Output format

When preparing an edit plan, use a concise table with:
- Order
- Source clip
- In point
- Out point
- Intended action
- Caption/audio notes

End with:
- What is ready
- What still needs rendering or user approval
- Export settings, if known

## Safety and privacy

- Do not expose API keys, credentials, or private local paths in generated reports.
- Never send a user's video to a remote AI service silently.
- Keep local project data private and explain when a requested feature requires internet access.
