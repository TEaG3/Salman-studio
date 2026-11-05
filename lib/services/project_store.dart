import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import '../models/video_clip.dart';

class ProjectStore {
  Future<File> _file() async {
    final docs = await getApplicationDocumentsDirectory();
    final folder = Directory('${docs.path}/projects');
    if (!await folder.exists()) await folder.create(recursive: true);
    return File('${folder.path}/frame_studio_project.json');
  }

  Future<void> save(List<VideoClip> clips) async {
    final file = await _file();
    final data = clips.map((clip) => clip.toJson()).toList();
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data), flush: true);
  }

  Future<List<VideoClip>> load() async {
    final file = await _file();
    if (!await file.exists()) return [];
    final data = jsonDecode(await file.readAsString()) as List<dynamic>;
    return data
        .map((item) => VideoClip.fromJson(item as Map<String, dynamic>))
        .where((clip) => File(clip.path).existsSync())
        .toList();
  }
}
