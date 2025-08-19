import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/audio/recorder_service.dart';
import '../../../core/audio/asr_service.dart';
import 'reading_controller.dart';

// Provider untuk services
final recorderServiceProvider = Provider<RecorderService>((ref) {
  return RecorderService();
});

final asrServiceProvider = Provider<ASRService>((ref) {
  return ASRService();
});

// Provider untuk ReadingController
final readingControllerProvider = StateNotifierProvider<ReadingController, ReadingState>((ref) {
  final recorderService = ref.watch(recorderServiceProvider);
  final asrService = ref.watch(asrServiceProvider);
  return ReadingController(recorderService, asrService);
});

// Computed providers untuk UI
final currentSurahProvider = Provider<String?>((ref) {
  final state = ref.watch(readingControllerProvider);
  return state.surah?.nameArabic;
});

final isRecordingProvider = Provider<bool>((ref) {
  final state = ref.watch(readingControllerProvider);
  return state.isRecording;
});

final progressProvider = Provider<double>((ref) {
  final state = ref.watch(readingControllerProvider);
  return state.progress;
});

final hasErrorProvider = Provider<bool>((ref) {
  final state = ref.watch(readingControllerProvider);
  return state.hasError;
});