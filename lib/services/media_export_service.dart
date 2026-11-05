import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../models/video_clip.dart';

/// Android-native MP4 trimming through Jetpack Media3 Transformer.
class MediaExportService {
  static const _methods = MethodChannel('com.teag3.studio/media_export');
  static const progressEvents = EventChannel('com.teag3.studio/media_export/progress');

  Future<File> exportTrim(VideoClip clip) async {
    if (!Platform.isAndroid) {
      throw UnsupportedError('MP4 export is currently supported on Android only.');
    }
    final input = File(clip.path);
    if (!await input.exists()) {
      throw ArgumentError('The source video no longer exists.');
    }
    final endMs = clip.endMs == 0 ? clip.sourceDurationMs : clip.endMs;
    if (clip.startMs < 0 || endMs <= clip.startMs) {
      throw ArgumentError('Choose a valid start and end point before exporting.');
    }

    final documents = await getApplicationDocumentsDirectory();
    final exportDirectory = Directory('${documents.path}/exports');
    if (!await exportDirectory.exists()) {
      await exportDirectory.create(recursive: true);
    }
    final output = File(
      '${exportDirectory.path}/teag3_${clip.id}_${DateTime.now().millisecondsSinceEpoch}.mp4',
    );

    try {
      await _methods.invokeMapMethod<String, dynamic>('exportTrim', {
        'inputPath': input.path,
        'outputPath': output.path,
        'startMs': clip.startMs,
        'endMs': endMs,
      });
      if (!await output.exists() || await output.length() == 0) {
        throw StateError('The export finished without a valid MP4 file.');
      }
      return output;
    } catch (_) {
      if (await output.exists()) await output.delete();
      rethrow;
    }
  }

  Future<void> cancel() => _methods.invokeMethod<void>('cancelExport');
}
