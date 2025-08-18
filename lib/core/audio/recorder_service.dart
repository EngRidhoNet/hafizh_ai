import 'dart:io' show Directory, Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class RecorderService {
  final _rec = AudioRecorder();
  String? _path;

  Future<bool> hasPermission() => _rec.hasPermission();

  Future<String> start() async {
    if (!await hasPermission()) {
      throw Exception('Izin mikrofon ditolak.');
    }

    if (kIsWeb) {
      // Untuk web, gunakan path sederhana
      _path = 'rec_${DateTime.now().millisecondsSinceEpoch}.wav';
    } else {
      // Untuk mobile/desktop
      final dir = await _safeBaseDir();
      _path = '${dir.path}/rec_${DateTime.now().millisecondsSinceEpoch}.wav';
    }

    await _rec.start(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 16000,
        numChannels: 1,
      ),
      path: _path!,
    );
    return _path!;
  }

  Future<String?> stop() async {
    await _rec.stop();
    return _path;
  }

  // Fallback yang lebih robust
  Future<Directory> _safeBaseDir() async {
    if (kIsWeb) {
      // Web tidak memerlukan directory path
      throw UnsupportedError('Directory operations not needed for web');
    }
    
    try {
      // Coba temporary directory dulu
      return await getTemporaryDirectory();
    } catch (e) {
      // Fallback ke direktori aplikasi jika path_provider gagal
      if (Platform.isAndroid) {
        return Directory('/data/data/${_getPackageName()}/cache');
      } else if (Platform.isIOS) {
        return Directory.systemTemp;
      } else {
        // macOS/Linux/Windows fallback
        return Directory.systemTemp;
      }
    }
  }
  
  String _getPackageName() {
    return 'com.example.hafizh_ai';
  }
}