import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/models/surah.dart';
import '../../../core/data/repositories/mushaf_repository.dart';
import '../../../core/nlp/alignment_engine.dart';
import '../../../core/audio/recorder_service.dart';
import '../../../core/audio/asr_service.dart';

class ReadingState {
  final Surah? surah;
  final AlignmentEngine? engine;
  final bool isRecording;
  final bool isLoading;
  final String partialTranscript;
  final String? error;
  final int currentTokenIndex;
  final double progress;
  final bool hasError;
  final List<String> recentErrors;
  final bool asrInitialized;

  const ReadingState({
    this.surah,
    this.engine,
    this.isRecording = false,
    this.isLoading = false,
    this.partialTranscript = '',
    this.error,
    this.currentTokenIndex = 0,
    this.progress = 0.0,
    this.hasError = false,
    this.recentErrors = const [],
    this.asrInitialized = false,
  });

  ReadingState copyWith({
    Surah? surah,
    AlignmentEngine? engine,
    bool? isRecording,
    bool? isLoading,
    String? partialTranscript,
    String? error,
    int? currentTokenIndex,
    double? progress,
    bool? hasError,
    List<String>? recentErrors,
    bool? asrInitialized,
  }) {
    return ReadingState(
      surah: surah ?? this.surah,
      engine: engine ?? this.engine,
      isRecording: isRecording ?? this.isRecording,
      isLoading: isLoading ?? this.isLoading,
      partialTranscript: partialTranscript ?? this.partialTranscript,
      error: error ?? this.error,
      currentTokenIndex: currentTokenIndex ?? this.currentTokenIndex,
      progress: progress ?? this.progress,
      hasError: hasError ?? this.hasError,
      recentErrors: recentErrors ?? this.recentErrors,
      asrInitialized: asrInitialized ?? this.asrInitialized,
    );
  }
}

class ReadingController extends StateNotifier<ReadingState> {
  final RecorderService _recorderService;
  final ASRService _asrService;
  Timer? _simulationTimer;
  StreamSubscription<String>? _transcriptSubscription;
  
  ReadingController(this._recorderService, this._asrService) : super(const ReadingState());

  @override
  void dispose() {
    _simulationTimer?.cancel();
    _transcriptSubscription?.cancel();
    _recorderService.dispose();
    _asrService.dispose();
    super.dispose();
  }

  Future<void> initializeASR() async {
    try {
      state = state.copyWith(isLoading: true);
      await _asrService.initialize();
      state = state.copyWith(asrInitialized: true, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> loadAlFatihah() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final surah = await MushafRepository.loadAlFatihah();
      final engine = AlignmentEngine(surah.getAllTokens());
      
      state = state.copyWith(
        surah: surah,
        engine: engine,
        isLoading: false,
      );
      
      // Initialize ASR after loading data
      if (!state.asrInitialized) {
        await initializeASR();
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> startRecording() async {
    if (state.engine == null || !state.asrInitialized) return;
    
    try {
      // Start recording audio
      await _recorderService.start();
      
      // Start ASR listening
      await _asrService.startListening();
      
      // Listen to ASR stream
      _transcriptSubscription = _asrService.transcriptStream.listen(
        (transcript) {
          processPartialTranscript(transcript);
        },
        onError: (error) {
          state = state.copyWith(error: error.toString());
        },
      );
      
      state = state.copyWith(isRecording: true, hasError: false);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> stopRecording() async {
    try {
      // Cancel subscription
      await _transcriptSubscription?.cancel();
      _transcriptSubscription = null;
      
      // Stop ASR
      await _asrService.stopListening();
      
      // Stop recording
      await _recorderService.stop();
      
      state = state.copyWith(isRecording: false);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void processPartialTranscript(String transcript) {
    if (state.engine == null) return;
    
    final result = state.engine!.processPartialTranscript(transcript, 0.9);
    
    state = state.copyWith(
      partialTranscript: transcript,
      currentTokenIndex: result.expectedIndex,
      progress: result.progress,
      hasError: !result.isMatch,
      recentErrors: result.isMatch ? [] : result.errors,
    );
  }

  void resetEngine() {
    _transcriptSubscription?.cancel();
    state.engine?.reset();
    state = state.copyWith(
      currentTokenIndex: 0,
      progress: 0.0,
      partialTranscript: '',
      hasError: false,
      recentErrors: [],
    );
  }
}