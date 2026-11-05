class VideoClip {
  const VideoClip({
    required this.id,
    required this.name,
    required this.path,
    required this.startMs,
    required this.endMs,
    this.sourceDurationMs = 0,
  });

  final String id;
  final String name;
  final String path;
  final int startMs;
  final int endMs;
  final int sourceDurationMs;

  VideoClip copyWith({
    int? startMs,
    int? endMs,
    int? sourceDurationMs,
  }) => VideoClip(
    id: id,
    name: name,
    path: path,
    startMs: startMs ?? this.startMs,
    endMs: endMs ?? this.endMs,
    sourceDurationMs: sourceDurationMs ?? this.sourceDurationMs,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'path': path,
    'startMs': startMs,
    'endMs': endMs,
    'sourceDurationMs': sourceDurationMs,
  };

  factory VideoClip.fromJson(Map<String, dynamic> json) => VideoClip(
    id: json['id'] as String,
    name: json['name'] as String,
    path: json['path'] as String,
    startMs: (json['startMs'] as num).toInt(),
    endMs: (json['endMs'] as num).toInt(),
    sourceDurationMs: (json['sourceDurationMs'] as num?)?.toInt() ?? 0,
  );
}
