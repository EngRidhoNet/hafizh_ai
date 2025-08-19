import 'arabic_normalizer.dart';

class AlignmentResult {
  final int expectedIndex;
  final int totalTokens;
  final double confidence;
  final bool isMatch;
  final List<String> errors;
  final String? currentExpectedToken;

  const AlignmentResult({
    required this.expectedIndex,
    required this.totalTokens,
    required this.confidence,
    required this.isMatch,
    required this.errors,
    this.currentExpectedToken,
  });

  double get progress => totalTokens == 0 ? 0.0 : expectedIndex / totalTokens;
}

class AlignmentEngine {
  final List<String> _expectedTokens;
  int _highestConfirmedIndex = 0;
  
  AlignmentEngine(this._expectedTokens) {
    print('AlignmentEngine initialized with ${_expectedTokens.length} tokens');
    print('Expected tokens: $_expectedTokens');
  }
  
  void reset() {
    _highestConfirmedIndex = 0;
    print('Engine reset: highestConfirmedIndex=$_highestConfirmedIndex');
  }
  
  AlignmentResult processPartialTranscript(String partialText, double confidence) {
    // Clean and normalize input
    final cleanTokens = _cleanAndNormalizeTokens(partialText);
    
    if (cleanTokens.isEmpty) {
      return AlignmentResult(
        expectedIndex: _highestConfirmedIndex,
        totalTokens: _expectedTokens.length,
        confidence: confidence,
        isMatch: true,
        errors: [],
        currentExpectedToken: _getCurrentExpectedToken(),
      );
    }
    
    print('Processing cleaned tokens: $cleanTokens');
    print('Current highest confirmed index: $_highestConfirmedIndex');
    
    final alignmentResult = _findBestAlignment(cleanTokens, confidence);
    
    return AlignmentResult(
      expectedIndex: alignmentResult.newIndex,
      totalTokens: _expectedTokens.length,
      confidence: confidence,
      isMatch: alignmentResult.isMatch,
      errors: alignmentResult.errors,
      currentExpectedToken: _getCurrentExpectedTokenAt(alignmentResult.newIndex),
    );
  }
  
  // FIX: Clean input tokens (remove duplicates, normalize)
  List<String> _cleanAndNormalizeTokens(String input) {
    final tokens = ArabicNormalizer.tokenize(input);
    final cleanTokens = <String>[];
    
    // Remove consecutive duplicates
    for (final token in tokens) {
      if (cleanTokens.isEmpty || cleanTokens.last != token) {
        cleanTokens.add(token);
      }
    }
    
    print('Raw tokens: $tokens');
    print('Cleaned tokens: $cleanTokens');
    
    return cleanTokens;
  }
  
  // FIX: Improved alignment strategies
  ({bool isMatch, List<String> errors, int newIndex}) _findBestAlignment(List<String> spokenTokens, double confidence) {
    // Strategy 1: Complete sequence from beginning
    final fromBeginning = _checkCompleteSequence(spokenTokens);
    
    // Strategy 2: Find longest subsequence match
    final subsequenceMatch = _findLongestSubsequence(spokenTokens);
    
    // Strategy 3: Smart continuation (look for patterns)
    final smartContinuation = _findSmartContinuation(spokenTokens);
    
    print('Alignment strategies:');
    print('  Complete sequence: match=${fromBeginning.isMatch}, index=${fromBeginning.newIndex}');
    print('  Subsequence match: match=${subsequenceMatch.isMatch}, index=${subsequenceMatch.newIndex}');
    print('  Smart continuation: match=${smartContinuation.isMatch}, index=${smartContinuation.newIndex}');
    
    // Choose best strategy
    final strategies = [fromBeginning, subsequenceMatch, smartContinuation];
    final bestStrategy = strategies.where((s) => s.isMatch).fold<({bool isMatch, List<String> errors, int newIndex})?>(
      null,
      (best, current) => best == null || current.newIndex > best.newIndex ? current : best,
    );
    
    if (bestStrategy != null && bestStrategy.newIndex > _highestConfirmedIndex) {
      _highestConfirmedIndex = bestStrategy.newIndex;
      print('✓ Updated to index: $_highestConfirmedIndex');
      return bestStrategy;
    }
    
    print('✗ No progress made, keeping index: $_highestConfirmedIndex');
    return (isMatch: false, errors: ['No matching sequence found'], newIndex: _highestConfirmedIndex);
  }
  
  // Strategy 1: Check complete sequence from start
  ({bool isMatch, List<String> errors, int newIndex}) _checkCompleteSequence(List<String> spokenTokens) {
    int matchedCount = 0;
    final errors = <String>[];
    
    for (int i = 0; i < spokenTokens.length && i < _expectedTokens.length; i++) {
      final spoken = spokenTokens[i];
      final expected = _expectedTokens[i];
      
      if (_tokensMatch(spoken, expected)) {
        matchedCount++;
      } else {
        errors.add('Mismatch at position $i: expected $expected, got $spoken');
        break;
      }
    }
    
    final isMatch = matchedCount > 0 && errors.isEmpty;
    return (isMatch: isMatch, errors: errors, newIndex: matchedCount);
  }
  
  // Strategy 2: Find longest matching subsequence
  ({bool isMatch, List<String> errors, int newIndex}) _findLongestSubsequence(List<String> spokenTokens) {
    int bestMatch = _highestConfirmedIndex;
    int bestLength = 0;
    
    // Try different starting positions in expected tokens
    for (int startPos = 0; startPos <= _expectedTokens.length - spokenTokens.length; startPos++) {
      int matchLength = 0;
      
      for (int i = 0; i < spokenTokens.length; i++) {
        final spokenToken = spokenTokens[i];
        final expectedToken = _expectedTokens[startPos + i];
        
        if (_tokensMatch(spokenToken, expectedToken)) {
          matchLength++;
        } else {
          break;
        }
      }
      
      if (matchLength > bestLength && startPos + matchLength > _highestConfirmedIndex) {
        bestLength = matchLength;
        bestMatch = startPos + matchLength;
      }
    }
    
    final isMatch = bestLength > 0 && bestMatch > _highestConfirmedIndex;
    return (isMatch: isMatch, errors: [], newIndex: bestMatch);
  }
  
  // Strategy 3: Smart continuation based on context
  ({bool isMatch, List<String> errors, int newIndex}) _findSmartContinuation(List<String> spokenTokens) {
    // Look for continuation from current position
    final startPos = _highestConfirmedIndex;
    int matchedTokens = 0;
    
    for (int i = 0; i < spokenTokens.length; i++) {
      final expectedIndex = startPos + i;
      
      if (expectedIndex >= _expectedTokens.length) break;
      
      final spoken = spokenTokens[i];
      final expected = _expectedTokens[expectedIndex];
      
      if (_tokensMatch(spoken, expected)) {
        matchedTokens++;
      } else {
        // Try skipping one token (for ASR errors)
        if (expectedIndex + 1 < _expectedTokens.length && 
            _tokensMatch(spoken, _expectedTokens[expectedIndex + 1])) {
          matchedTokens += 2; // Skip + match
          i++; // Skip next spoken token too
        } else {
          break;
        }
      }
    }
    
    final newIndex = startPos + matchedTokens;
    final isMatch = matchedTokens > 0;
    
    return (isMatch: isMatch, errors: [], newIndex: newIndex);
  }
  
  // Improved token matching with similarity
  bool _tokensMatch(String spoken, String expected) {
    if (spoken == expected) return true;
    
    // Check Levenshtein distance for similar tokens
    return _levenshteinDistance(spoken, expected) <= 1;
  }
  
  int _levenshteinDistance(String a, String b) {
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;
    
    final matrix = List.generate(
      a.length + 1, 
      (i) => List.filled(b.length + 1, 0)
    );
    
    for (int i = 0; i <= a.length; i++) matrix[i][0] = i;
    for (int j = 0; j <= b.length; j++) matrix[0][j] = j;
    
    for (int i = 1; i <= a.length; i++) {
      for (int j = 1; j <= b.length; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j - 1] + cost
        ].reduce((a, b) => a < b ? a : b);
      }
    }
    
    return matrix[a.length][b.length];
  }
  
  double get progress => _expectedTokens.isEmpty ? 1.0 : _highestConfirmedIndex / _expectedTokens.length;
  
  String? _getCurrentExpectedToken() => 
    _highestConfirmedIndex < _expectedTokens.length ? _expectedTokens[_highestConfirmedIndex] : null;
    
  String? _getCurrentExpectedTokenAt(int index) => 
    index < _expectedTokens.length ? _expectedTokens[index] : null;
}