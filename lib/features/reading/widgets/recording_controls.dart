import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/reading_providers.dart';

class RecordingControls extends ConsumerWidget {
  const RecordingControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readingState = ref.watch(readingControllerProvider);
    final readingController = ref.read(readingControllerProvider.notifier);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                readingState.isRecording ? Icons.mic : Icons.mic_off,
                color: readingState.isRecording ? Colors.red : Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                readingState.isRecording ? 'Recording...' : 'Ready to record',
                style: TextStyle(
                  color: readingState.isRecording ? Colors.red : Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Reset button
              ElevatedButton.icon(
                onPressed: readingState.isRecording ? null : () {
                  readingController.resetEngine();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Reset'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[100],
                  foregroundColor: Colors.grey[700],
                ),
              ),
              
              // Record/Stop button
              ElevatedButton.icon(
                onPressed: readingState.isLoading ? null : () {
                  if (readingState.isRecording) {
                    readingController.stopRecording();
                  } else {
                    readingController.startRecording();
                  }
                },
                icon: Icon(
                  readingState.isRecording ? Icons.stop : Icons.mic,
                ),
                label: Text(
                  readingState.isRecording ? 'Stop' : 'Start',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: readingState.isRecording 
                      ? Colors.red 
                      : Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24, 
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
          
          // Error display
          if (readingState.hasError && readingState.recentErrors.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.red.shade600, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      readingState.recentErrors.first,
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}