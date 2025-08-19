import 'ayah.dart';

class Surah {
  final int number;
  final String name;
  final String nameArabic;
  final int totalAyahs;
  final List<Ayah> ayahs;

  const Surah({
    required this.number,
    required this.name,
    required this.nameArabic,
    required this.totalAyahs,
    required this.ayahs,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      number: json['number'] as int,
      name: json['name'] as String,
      nameArabic: json['name_arabic'] as String,
      totalAyahs: json['total_ayahs'] as int,
      ayahs: (json['ayahs'] as List)
          .map((ayah) => Ayah.fromJson(ayah as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Get all tokens dari semua ayat - Method ini yang missing!
  List<String> getAllTokens() {
    return ayahs.expand((ayah) => ayah.tokens).toList();
  }

  /// Get specific ayah
  Ayah? getAyah(int number) {
    try {
      return ayahs.firstWhere((ayah) => ayah.number == number);
    } catch (e) {
      return null;
    }
  }
}