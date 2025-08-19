import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/surah.dart';

class MushafRepository {
  static const String _basePath = 'assets/data/mushaf';
  
  /// Load Al-Fatihah untuk testing
  static Future<Surah> loadAlFatihah() async {
    try {
      final jsonString = await rootBundle.loadString('$_basePath/al_fatihah.json');
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      return Surah.fromJson(jsonData);
    } catch (e) {
      throw Exception('Failed to load Al-Fatihah: $e');
    }
  }
  
  /// Load surah by name (untuk nanti)
  static Future<Surah> loadSurah(String filename) async {
    try {
      final jsonString = await rootBundle.loadString('$_basePath/$filename.json');
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      return Surah.fromJson(jsonData);
    } catch (e) {
      throw Exception('Failed to load $filename: $e');
    }
  }
}