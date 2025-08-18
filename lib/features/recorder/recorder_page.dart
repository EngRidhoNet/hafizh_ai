import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/audio/recorder_service.dart';

class RecorderPage extends StatefulWidget {
  const RecorderPage({super.key});
  @override
  State<RecorderPage> createState() => _RecorderPageState();
}

class _RecorderPageState extends State<RecorderPage> {
  final _rec = RecorderService();
  bool _isRecording = false;
  String? _lastPath;
  String? _error;

  Future<void> _start() async {
    setState(() => _error = null);
    try {
      HapticFeedback.lightImpact();
      final p = await _rec.start();
      setState(() {
        _isRecording = true;
        _lastPath = p;
      });
    } catch (e) {
      setState(() => _error = '$e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mulai: $e')));
    }
  }

  Future<void> _stop() async {
    HapticFeedback.lightImpact();
    final p = await _rec.stop();
    setState(() {
      _isRecording = false;
      _lastPath = p;
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tersimpan: $p')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rekam 16 kHz Mono')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Status: ${_isRecording ? "Recording…" : "Idle"}'),
          const SizedBox(height: 12),
          Wrap(spacing: 12, children: [
            ElevatedButton(onPressed: _isRecording ? null : _start, child: const Text('Start')),
            ElevatedButton(onPressed: _isRecording ? _stop : null, child: const Text('Stop')),
          ]),
          const SizedBox(height: 16),
          Text('File terakhir: ${_lastPath ?? "-"}', maxLines: 3),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text('Error: $_error', style: const TextStyle(color: Colors.red)),
          ],
        ]),
      ),
    );
  }
}
