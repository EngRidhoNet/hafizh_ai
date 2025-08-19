class Ayah {
  final int number;
  final String uthmani;     // النص العثماني
  final String normalized;  // نص مُطبّع
  final List<String> tokens; // كلمات منفصلة

  const Ayah({
    required this.number,
    required this.uthmani,
    required this.normalized,
    required this.tokens,
  });

  factory Ayah.fromJson(Map<String, dynamic> json) {
    return Ayah(
      number: json['number'] as int,
      uthmani: json['uthmani'] as String,
      normalized: json['normalized'] as String,
      tokens: List<String>.from(json['tokens'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'uthmani': uthmani,
      'normalized': normalized,
      'tokens': tokens,
    };
  }
}