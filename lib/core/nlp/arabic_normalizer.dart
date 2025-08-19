class ArabicNormalizer {
  // Daftar harakat dan tanda baca yang akan dihapus
  static const String _harakats = 'ًٌٍَُِّْٰٱ';
  static const String _punctuation = '۞۩،؍؎؏؛؞؟﴾﴿';
  
  /// Menormalkan teks Arab: hapus harakat, tanda baca, dll
  static String normalize(String text) {
    String result = text;
    
    // 1. Hapus harakat
    for (int i = 0; i < _harakats.length; i++) {
      result = result.replaceAll(_harakats[i], '');
    }
    
    // 2. Hapus tanda baca
    for (int i = 0; i < _punctuation.length; i++) {
      result = result.replaceAll(_punctuation[i], '');
    }
    
    // 3. Normalisasi huruf spesifik
    result = result
        .replaceAll('أ', 'ا')  // Alif with hamza above
        .replaceAll('إ', 'ا')  // Alif with hamza below
        .replaceAll('آ', 'ا')  // Alif with madda
        .replaceAll('ة', 'ه')  // Ta marbuta -> Ha
        .replaceAll('ى', 'ي'); // Alif maksura -> Ya
    
    // 4. Bersihkan spasi berlebih
    result = result.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    return result;
  }
  
  /// Tokenisasi sederhana berdasarkan spasi
  static List<String> tokenize(String text) {
    return normalize(text)
        .split(' ')
        .where((token) => token.isNotEmpty)
        .toList();
  }
}