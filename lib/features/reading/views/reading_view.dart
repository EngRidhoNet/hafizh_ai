import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/reading_providers.dart';
import '../controllers/reading_controller.dart'; // ← Tambah import ini
import '../widgets/ayah_text_widget.dart';
import '../widgets/recording_controls.dart';
import '../widgets/progress_indicator_widget.dart';

class ReadingView extends ConsumerStatefulWidget {
  const ReadingView({super.key});

  @override
  ConsumerState<ReadingView> createState() => _ReadingViewState();
}

class _ReadingViewState extends ConsumerState<ReadingView> {
  @override
  void initState() {
    super.initState();
    // Load Al-Fatihah saat view dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(readingControllerProvider.notifier).loadAlFatihah();
    });
  }

  @override
  Widget build(BuildContext context) {
    final readingState = ref.watch(readingControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(readingState.surah?.nameArabic ?? 'Loading...'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Progress indicator
          const ProgressIndicatorWidget(),
          
          // Content
          Expanded(
            child: _buildContent(readingState),
          ),
          
          // Recording controls
          const RecordingControls(),
        ],
      ),
    );
  }

  Widget _buildContent(ReadingState state) { // ← Sekarang ReadingState akan dikenali
    if (state.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading Al-Fatihah...'),
          ],
        ),
      );
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Error: ${state.error}',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red.shade700),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(readingControllerProvider.notifier).loadAlFatihah();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.surah == null) {
      return const Center(
        child: Text('No data available'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: state.surah!.ayahs.length,
      itemBuilder: (context, index) {
        final ayah = state.surah!.ayahs[index];
        
        // Hitung global token start index untuk ayat ini
        int globalTokenStartIndex = 0;
        for (int i = 0; i < index; i++) {
          globalTokenStartIndex += state.surah!.ayahs[i].tokens.length;
        }
        
        return AyahTextWidget(
          ayah: ayah,
          globalTokenStartIndex: globalTokenStartIndex,
        );
      },
    );
  }
}