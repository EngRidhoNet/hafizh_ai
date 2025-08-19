import 'package:flutter_test/flutter_test.dart';
import 'package:hafizh_ai/core/nlp/alignment_engine.dart';
import 'package:hafizh_ai/core/nlp/arabic_normalizer.dart';

void main() {
  group('Arabic Normalizer Tests', () {
    test('should normalize Arabic text correctly', () {
      const input = 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ';
      const expected = 'بسم الله الرحمن الرحيم';
      
      final result = ArabicNormalizer.normalize(input);
      expect(result, equals(expected));
    });

    test('should tokenize Arabic text correctly', () {
      const input = 'بسم الله الرحمن الرحيم';
      final expected = ['بسم', 'الله', 'الرحمن', 'الرحيم'];
      
      final result = ArabicNormalizer.tokenize(input);
      expect(result, equals(expected));
    });
  });

  group('Alignment Engine Tests', () {
    late AlignmentEngine engine;
    
    setUp(() {
      final expectedTokens = ['بسم', 'الله', 'الرحمن', 'الرحيم'];
      engine = AlignmentEngine(expectedTokens);
    });

    test('should match single token', () {
      final result = engine.processPartialTranscript('بسم', 0.9);
      print('Test result: isMatch=${result.isMatch}, index=${result.expectedIndex}');
      expect(result.isMatch, isTrue);
      expect(result.expectedIndex, equals(1));
    });

    test('should match multiple tokens', () {
      // Reset engine untuk test bersih
      engine.reset();
      
      final result = engine.processPartialTranscript('بسم الله', 0.9);
      print('Test result: isMatch=${result.isMatch}, index=${result.expectedIndex}');
      expect(result.isMatch, isTrue);
      expect(result.expectedIndex, equals(2));
    });

    test('should detect mismatch', () {
      engine.reset();
      
      final result = engine.processPartialTranscript('بسم الله الغفور', 0.9);
      expect(result.isMatch, isFalse);
      expect(result.errors.isNotEmpty, isTrue);
    });

    test('should reset correctly', () {
      engine.processPartialTranscript('بسم الله', 0.9);
      expect(engine.progress, greaterThan(0));
      
      engine.reset();
      expect(engine.progress, equals(0));
    });
  });
}