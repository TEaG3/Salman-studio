import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/video_clip.dart';

/// Stores the project locally and keeps compatibility with the original MVP file.
class ProjectStore {
  static const _fileName = 'tea_g3_studio_project.json';
  static const _legacyFileName = 'frame_studio_project.json';

  Future<Directory> _projectsDirectory() async {
    final docs = await getApplicationDocumentsDirectory();
    final folder = Directory('${docs.path}/projects');
    if (!await folder.exists()) await folder.create(recursive: true);
    return folder;
  }

  Future<File> _file() async {
    final folder = await _projectsDirectory();
    return File('${folder.path}/$_fileName');
  }

  Future<void> save(List<VideoClip> clips) async {
    final file = await _file();
    final temporary = File('${file.path}.tmp');
    final data = clips.map((clip) => clip.toJson()).toList(growable: false);
    await temporary.writeAsString(
      const JsonEncoder.withIndent('  ').convert(data),
      flush: true,
    );
    await temporary.rename(file.path);
  }

  Future<List<VideoClip>> load() async {
    final folder = await _projectsDirectory();
    final current = File('${folder.path}/$_fileName');
    final legacy = File('${folder.path}/$_legacyFileName');
    final source = await current.exists() ? current : legacy;
    if (!await source.exists()) return [];

    final decoded = jsonDecode(await source.readAsString());
    if (decoded is! List) {
      throw const FormatException('Project file must contain a list of clips.');
    }
    final clips = <VideoClip>[];
    for (final item in decoded) {
      if (item is! Map<String, dynamic>) continue;
      try {
        final clip = VideoClip.fromJson(item);
        if (await File(clip.path).exists()) clips.add(clip);
      } on Object {
        // Ignore a damaged clip entry without losing the remaining project.
      }
    }

    if (source.path == legacy.path && !await current.exists()) {
      await save(clips);
    }
    return clips;
  }
}
