import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/models/ayah.dart';
import '../controllers/reading_providers.dart';

class AyahTextWidget extends ConsumerWidget {
  final Ayah ayah;
  final int globalTokenStartIndex;

  const AyahTextWidget({
    super.key,
    required this.ayah,
    required this.globalTokenStartIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readingState = ref.watch(readingControllerProvider);
    final currentTokenIndex = readingState.currentTokenIndex;
    final hasError = readingState.hasError;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Nomor ayat
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ayat ${ayah.number}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${ayah.number}',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Text Arab dengan highlighting
            Directionality(
              textDirection: TextDirection.rtl,
              child: Wrap(
                children: _buildHighlightedTokens(
                  context,
                  ayah.tokens,
                  currentTokenIndex,
                  globalTokenStartIndex,
                  hasError,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildHighlightedTokens(
    BuildContext context,
    List<String> tokens,
    int currentTokenIndex,
    int globalStartIndex,
    bool hasError,
  ) {
    final List<Widget> widgets = [];

    for (int i = 0; i < tokens.length; i++) {
      final globalIndex = globalStartIndex + i;
      final token = tokens[i];
      
      // Tentukan status highlighting
      Color? backgroundColor;
      Color? textColor;
      
      if (globalIndex < currentTokenIndex) {
        // Token yang sudah dibaca (hijau)
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
      } else if (globalIndex == currentTokenIndex) {
        // Token yang sedang dibaca
        if (hasError) {
          // Error (merah)
          backgroundColor = Colors.red.shade100;
          textColor = Colors.red.shade800;
        } else {
          // Current (biru)
          backgroundColor = Colors.blue.shade100;
          textColor = Colors.blue.shade800;
        }
      } else {
        // Token yang belum dibaca (default)
        textColor = Colors.black87;
      }

      widgets.add(
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: backgroundColor != null
              ? BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(6),
                )
              : null,
          child: Text(
            token,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ),
      );
      
      // Tambah spasi antar kata
      if (i < tokens.length - 1) {
        widgets.add(const SizedBox(width: 8));
      }
    }

    return widgets;
  }
}