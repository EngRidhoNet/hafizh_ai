import 'dart:async';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class RecorderService {
  final AudioRecorder _recorder = AudioRecorder();
  String? _currentPath;
  bool _isRecording = false;

  Future<bool> hasPermission() async {
    return await _recorder.hasPermission();
  }

  Future<String> start() async {
    if (!await hasPermission()) {
      throw Exception('Microphone permission denied');
    }

    if (kIsWeb) {
      // For web, use simple path
      _currentPath = 'recording_${DateTime.now().millisecondsSinceEpoch}.wav';
    } else {
      // For mobile/desktop
      final dir = await getTemporaryDirectory();
      _currentPath = '${dir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.wav';
    }

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 16000,
        numChannels: 1,
      ),
      path: _currentPath!,
    );

    _isRecording = true;
    return _currentPath!;
  }

  Future<String?> stop() async {
    final path = await _recorder.stop();
    _isRecording = false;
    return path ?? _currentPath;
  }

  Future<void> dispose() async {
    _isRecording = false;
    await _recorder.dispose();
  }

  // Fix: Buat getter synchronous
  bool get isRecording => _isRecording;
}