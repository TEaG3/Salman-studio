import 'video_clip.dart';

/// A deterministic, provider-independent description of an edit.
class EditDecisionList {
  const EditDecisionList({
    required this.projectId,
    required this.timeline,
    this.schemaVersion = '1.0',
    this.status = 'draft',
  });

  final String schemaVersion;
  final String projectId;
  final String status;
  final List<EditDecisionClip> timeline;

  Map<String, dynamic> toJson() => {
        'schemaVersion': schemaVersion,
        'projectId': projectId,
        'status': status,
        'timeline': timeline.map((item) => item.toJson()).toList(),
      };

  /// Builds a sequential timeline from the saved source ranges.
  factory EditDecisionList.fromClips({
    required String projectId,
    required Iterable<VideoClip> clips,
  }) {
    final timeline = <EditDecisionClip>[];
    var cursorMs = 0;
    for (final clip in clips) {
      final end = clip.endMs == 0 ? clip.sourceDurationMs : clip.endMs;
      if (clip.startMs < 0 || end <= clip.startMs) {
        throw ArgumentError('Invalid source range for clip ${clip.id}.');
      }
      timeline.add(EditDecisionClip(
        clipId: clip.id,
        sourceInMs: clip.startMs,
        sourceOutMs: end,
        timelineStartMs: cursorMs,
      ));
      cursorMs += end - clip.startMs;
    }
    final result = EditDecisionList(projectId: projectId, timeline: timeline);
    final errors = result.validate();
    if (errors.isNotEmpty) throw ArgumentError(errors.join(' '));
    return result;
  }

  List<String> validate() {
    final errors = <String>[];
    if (schemaVersion != '1.0') errors.add('Unsupported schema version.');
    if (projectId.trim().isEmpty) errors.add('Project ID is required.');
    if (!const {'draft', 'validated', 'approved', 'rendering', 'rendered', 'failed'}
        .contains(status)) {
      errors.add('Invalid edit status.');
    }
    final ids = <String>{};
    for (final item in timeline) {
      if (item.clipId.trim().isEmpty) errors.add('Clip ID is required.');
      if (!ids.add(item.clipId)) errors.add('Duplicate clip ID: ${item.clipId}.');
      if (item.sourceInMs < 0 ||
          item.sourceOutMs <= item.sourceInMs ||
          item.timelineStartMs < 0) {
        errors.add('Invalid timing for clip ${item.clipId}.');
      }
    }
    return errors;
  }
}

class EditDecisionClip {
  const EditDecisionClip({
    required this.clipId,
    required this.sourceInMs,
    required this.sourceOutMs,
    required this.timelineStartMs,
  });

  final String clipId;
  final int sourceInMs;
  final int sourceOutMs;
  final int timelineStartMs;

  Map<String, dynamic> toJson() => {
        'clipId': clipId,
        'sourceInMs': sourceInMs,
        'sourceOutMs': sourceOutMs,
        'timelineStartMs': timelineStartMs,
      };
}
