import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class ASRService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  StreamController<String>? _transcriptController;
  List<stt.LocaleName> _availableLocales = [];
  
  // Stream untuk partial results
  Stream<String> get transcriptStream => _transcriptController!.stream;
  
  Future<bool> initialize() async {
    // Request microphone permission
    final permission = await Permission.microphone.request();
    if (!permission.isGranted) {
      throw Exception('Microphone permission denied');
    }
    
    // Initialize speech recognition
    final available = await _speech.initialize(
      onError: (error) {
        print('Speech recognition error: $error');
        _transcriptController?.addError(error);
      },
      onStatus: (status) {
        print('Speech recognition status: $status');
      },
    );
    
    if (!available) {
      throw Exception('Speech recognition not available');
    }
    
    // Load available locales
    _availableLocales = await _speech.locales();
    
    _transcriptController = StreamController<String>.broadcast();
    return true;
  }
  
  Future<void> startListening() async {
    if (_isListening) return;
    
    await _speech.listen(
      onResult: (result) {
        final transcript = result.recognizedWords;
        print('ASR Result: $transcript (${result.confidence})');
        _transcriptController?.add(transcript);
      },
      listenFor: const Duration(minutes: 5), // Max 5 minutes
      pauseFor: const Duration(seconds: 3),   // Pause detection
      partialResults: true,                   // Enable partial results
      cancelOnError: false,
      listenMode: stt.ListenMode.confirmation,
      localeId: 'ar-SA', // Arabic Saudi Arabia
    );
    
    _isListening = true;
  }
  
  Future<void> stopListening() async {
    if (!_isListening) return;
    
    await _speech.stop();
    _isListening = false;
  }
  
  Future<void> dispose() async {
    await stopListening();
    await _transcriptController?.close();
    _transcriptController = null;
  }
  
  bool get isListening => _isListening;
  bool get isAvailable => _speech.isAvailable;
  List<stt.LocaleName> get locales => _availableLocales; // Fix: use cached locales
  
  // Helper method to get Arabic locales
  List<stt.LocaleName> get arabicLocales {
    return _availableLocales.where((locale) => 
      locale.localeId.startsWith('ar')).toList();
  }
}