import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:uuid/uuid.dart';

import '../models/video_clip.dart';
import '../services/ai_assistant_service.dart';
import '../services/media_import_service.dart';
import '../services/project_store.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final _importer = MediaImportService();
  final _store = ProjectStore();
  final _ai = AiAssistantService();
  final _uuid = const Uuid();
  final List<VideoClip> _clips = [];

  VideoPlayerController? _player;
  String? _selectedId;
  int _inMs = 0;
  int _outMs = 0;
  bool _busy = false;

  VideoClip? get _selected {
    for (final clip in _clips) {
      if (clip.id == _selectedId) return clip;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    try {
      final clips = await _store.load();
      if (!mounted) return;
      setState(() {
        _clips.addAll(clips);
        if (_clips.isNotEmpty) _selectedId = _clips.first.id;
      });
      if (_selected != null) await _open(_selected!);
    } catch (error) {
      _message('تعذر فتح المشروع: $error');
    }
  }

  Future<void> _import() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final media = await _importer.pickVideo();
      if (media == null || !mounted) return;
      final clip = VideoClip(
        id: _uuid.v4(),
        name: media.name,
        path: media.path,
        startMs: 0,
        endMs: 0,
      );
      setState(() {
        _clips.add(clip);
        _selectedId = clip.id;
      });
      await _open(clip);
      await _save(showMessage: false);
    } catch (error) {
      _message('تعذر استيراد الفيديو: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _open(VideoClip clip) async {
    await _player?.dispose();
    final controller = VideoPlayerController.file(File(clip.path));
    _player = controller;
    try {
      await controller.initialize();
      final duration = controller.value.duration.inMilliseconds;
      final updated = clip.copyWith(
        endMs: clip.endMs == 0 ? duration : clip.endMs.clamp(0, duration).toInt(),
        sourceDurationMs: duration,
      );
      final index = _clips.indexWhere((item) => item.id == clip.id);
      if (index >= 0) _clips[index] = updated;
      if (!mounted) return;
      setState(() {
        _inMs = updated.startMs.clamp(0, duration).toInt();
        _outMs = updated.endMs.clamp(0, duration).toInt();
      });
      await controller.seekTo(Duration(milliseconds: _inMs));
      if (mounted) setState(() {});
    } catch (error) {
      _message('تعذرت معاينة الفيديو: $error');
    }
  }

  Future<void> _save({bool showMessage = true}) async {
    await _store.save(_clips);
    if (showMessage) _message('تم حفظ المشروع محلياً.');
  }

  Future<void> _savePoints() async {
    final clip = _selected;
    if (clip == null) return;
    final index = _clips.indexWhere((item) => item.id == clip.id);
    if (index < 0) return;
    setState(() {
      _clips[index] = clip.copyWith(startMs: _inMs, endMs: _outMs);
    });
    await _save();
  }

  Future<void> _remove(VideoClip clip) async {
    setState(() {
      _clips.removeWhere((item) => item.id == clip.id);
      _selectedId = _clips.isEmpty ? null : _clips.first.id;
    });
    if (_selected == null) {
      await _player?.dispose();
      _player = null;
      if (mounted) setState(() {});
    } else {
      await _open(_selected!);
    }
    await _save(showMessage: false);
  }

  Future<void> _showAi() async {
    final response = await _ai.reply('اقترح تحسينات للمقطع الحالي');
    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مساعد TEa.G3-studio'),
        content: Text(response),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  String _time(int ms) {
    final seconds = ms ~/ 1000;
    return '${(seconds ~/ 60).toString().padLeft(2, '0')}:'
        '${(seconds % 60).toString().padLeft(2, '0')}';
  }

  void _message(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clip = _selected;
    final duration = clip?.sourceDurationMs ?? 0;
    final maxValue = duration > 0 ? duration.toDouble() : 1.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('TEa.G3-studio'),
        actions: [
          IconButton(onPressed: _showAi, icon: const Icon(Icons.auto_awesome), tooltip: 'مساعد AI'),
          IconButton(onPressed: _save, icon: const Icon(Icons.save_outlined), tooltip: 'حفظ'),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final preview = _preview();
            final timeline = _timeline(clip, maxValue);
            if (constraints.maxWidth > 760) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  Expanded(flex: 3, child: preview),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: timeline),
                ]),
              );
            }
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                Expanded(flex: 5, child: preview),
                const SizedBox(height: 12),
                Expanded(flex: 4, child: timeline),
              ]),
            );
          },
        ),
      ),
    );
  }

  Widget _preview() {
    final player = _player;
    return Column(children: [
      Expanded(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(18),
          ),
          clipBehavior: Clip.antiAlias,
          child: player != null && player.value.isInitialized
              ? Center(
                  child: AspectRatio(
                    aspectRatio: player.value.aspectRatio,
                    child: VideoPlayer(player),
                  ),
                )
              : const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.movie_outlined, size: 54, color: Colors.white38),
                      SizedBox(height: 10),
                      Text('استورد فيديو لبدء التحرير'),
                    ],
                  ),
                ),
        ),
      ),
      const SizedBox(height: 12),
      Row(children: [
        FilledButton.icon(
          onPressed: _busy ? null : _import,
          icon: const Icon(Icons.add),
          label: Text(_busy ? 'جارٍ الاستيراد' : 'إضافة فيديو'),
        ),
        const SizedBox(width: 8),
        IconButton.filledTonal(
          onPressed: player != null && player.value.isInitialized
              ? () => setState(() {
                    player.value.isPlaying ? player.pause() : player.play();
                  })
              : null,
          icon: Icon(player?.value.isPlaying == true ? Icons.pause : Icons.play_arrow),
        ),
      ]),
    ]);
  }

  Widget _timeline(VideoClip? clip, double maxValue) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const Text('المقاطع', style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Expanded(
        child: _clips.isEmpty
            ? const Center(child: Text('لا توجد مقاطع بعد'))
            : ListView.builder(
                itemCount: _clips.length,
                itemBuilder: (context, index) {
                  final item = _clips[index];
                  return ListTile(
                    selected: item.id == _selectedId,
                    leading: const Icon(Icons.video_file_outlined),
                    title: Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text('${_time(item.startMs)} – ${_time(item.endMs)}'),
                    onTap: () async {
                      setState(() => _selectedId = item.id);
                      await _open(item);
                    },
                    trailing: IconButton(
                      onPressed: () => _remove(item),
                      icon: const Icon(Icons.close),
                    ),
                  );
                },
              ),
      ),
      const Divider(),
      const Text('نقاط القصّ', style: TextStyle(fontWeight: FontWeight.bold)),
      if (clip == null)
        const Padding(
          padding: EdgeInsets.all(12),
          child: Text('اختر مقطعاً لتعديل البداية والنهاية.'),
        )
      else ...[
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('البداية'),
          Text(_time(_inMs)),
        ]),
        Slider(
          value: _inMs.clamp(0, maxValue.toInt()).toDouble(),
          min: 0,
          max: maxValue,
          onChanged: (value) => setState(() {
            _inMs = value.round().clamp(0, _outMs).toInt();
          }),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('النهاية'),
          Text(_time(_outMs)),
        ]),
        Slider(
          value: _outMs.clamp(0, maxValue.toInt()).toDouble(),
          min: 0,
          max: maxValue,
          onChanged: (value) => setState(() {
            _outMs = value.round().clamp(_inMs, maxValue.toInt()).toInt();
          }),
        ),
        FilledButton.icon(
          onPressed: _savePoints,
          icon: const Icon(Icons.check),
          label: const Text('حفظ نقاط القصّ'),
        ),
        const SizedBox(height: 6),
        const Text(
          'هذه النسخة تحفظ نقاط القصّ كبيانات فقط؛ التصدير الفعلي سيضاف في المرحلة التالية.',
          style: TextStyle(fontSize: 11, color: Colors.white60),
        ),
      ],
    ]);
  }
}
