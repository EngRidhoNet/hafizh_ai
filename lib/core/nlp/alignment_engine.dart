class AlignmentResult {
  final int expectedIndex;     // Index kata yang seharusnya
  final double confidence;     // Confidence dari ASR
  final bool isMatch;         // Apakah cocok dengan expected
  final List<String> errors;  // Daftar kata yang salah

  const AlignmentResult({
    required this.expectedIndex,
    required this.confidence,
    required this.isMatch,
    required this.errors,
  });
}

class AlignmentEngine {
  final List<String> _expectedTokens;
  int _currentIndex = 0;
  
  AlignmentEngine(this._expectedTokens);
  
  /// Reset pointer ke awal
  void reset() {
    _currentIndex = 0;
  }
  
  /// Proses partial transcript dari ASR
  AlignmentResult processPartialTranscript(
    String partialText, 
    double confidence
  ) {
    final tokens = ArabicNormalizer.tokenize(partialText);
    
    if (tokens.isEmpty) {
      return AlignmentResult(
        expectedIndex: _currentIndex,
        confidence: confidence,
        isMatch: true,
        errors: [],
      );
    }
    
    // Cek alignment dengan algoritma prefix matching
    final alignmentResult = _alignTokens(tokens);
    
    return AlignmentResult(
      expectedIndex: _currentIndex,
      confidence: confidence,
      isMatch: alignmentResult.isMatch,
      errors: alignmentResult.errors,
    );
  }
  
  /// Algoritma alignment sederhana
  ({bool isMatch, List<String> errors}) _alignTokens(List<String> spokenTokens) {
    final errors = <String>[];
    bool isMatch = true;
    
    // Prefix matching: cek apakah spoken tokens cocok dengan expected
    for (int i = 0; i < spokenTokens.length && _currentIndex + i < _expectedTokens.length; i++) {
      final spoken = spokenTokens[i];
      final expected = _expectedTokens[_currentIndex + i];
      
      if (spoken != expected) {
        // Hitung Levenshtein distance untuk toleransi kecil
        if (_levenshteinDistance(spoken, expected) > 1) {
          errors.add('Expected: $expected, Got: $spoken');
          isMatch = false;
        }
      }
    }
    
    // Update current index jika matching
    if (isMatch && spokenTokens.isNotEmpty) {
      _currentIndex = (_currentIndex + spokenTokens.length).clamp(0, _expectedTokens.length);
    }
    
    return (isMatch: isMatch, errors: errors);
  }
  
  /// Levenshtein distance untuk toleransi typo
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
          matrix[i - 1][j] + 1,      // deletion
          matrix[i][j - 1] + 1,      // insertion  
          matrix[i - 1][j - 1] + cost // substitution
        ].reduce((a, b) => a < b ? a : b);
      }
    }
    
    return matrix[a.length][b.length];
  }
  
  /// Getter untuk progress
  double get progress => _expectedTokens.isEmpty ? 1.0 : _currentIndex / _expectedTokens.length;
  
  String? get currentExpectedToken => 
    _currentIndex < _expectedTokens.length ? _expectedTokens[_currentIndex] : null;
}