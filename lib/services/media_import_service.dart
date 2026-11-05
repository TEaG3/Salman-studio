import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ImportedMedia {
  const ImportedMedia({required this.name, required this.path});
  final String name;
  final String path;
}

class MediaImportService {
  final _uuid = const Uuid();

  Future<ImportedMedia?> pickVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
      withData: false,
    );
    if (result == null || result.files.isEmpty) return null;

    final picked = result.files.single;
    final sourcePath = picked.path;
    if (sourcePath == null) throw Exception('تعذر الوصول إلى الملف المحدد.');
    final source = File(sourcePath);
    if (!await source.exists()) throw Exception('ملف الفيديو غير موجود.');

    final docs = await getApplicationDocumentsDirectory();
    final folder = Directory('${docs.path}/media');
    if (!await folder.exists()) await folder.create(recursive: true);

    final ext = picked.name.contains('.') ? picked.name.split('.').last : 'mp4';
    final target = File('${folder.path}/${_uuid.v4()}.$ext');
    await source.copy(target.path);
    return ImportedMedia(name: picked.name, path: target.path);
  }
}
