import 'package:flutter/material.dart';
import '../../data/database/database_service.dart';
import 'package:intl/intl.dart';

class BodyMetricsViewModel extends ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;
  
  // Inputs
  double? weight;
  double? heightCm;
  double? neck;
  double? waist;
  double? hips; // For women mostly, but RFM uses it? No, Navy uses waist/neck for men.
  int? age;
  bool isMale = true;
  String activityLevel = "Sedentary";
  
  // Results
  double? bmi;
  double? bodyFat;
  double? tdee;
  
  // History
  List<Map<String, dynamic>> weightHistory = [];

  Future<void> init() async {
    await fetchHistory();
  }

  Future<void> fetchHistory() async {
    final db = await _db.database;
    final res = await db.query(
      'body_metrics', 
      orderBy: 'date DESC',
      limit: 30
    );
    weightHistory = res;
    
    if (res.isNotEmpty) {
      weight = res.first['weight'] as double?;
      // Others...
    }
    calculateAll();
  }

  void calculateAll() {
    _calculateBMI();
    _calculateBodyFat(); // US Navy
    _calculateTDEE();
    notifyListeners();
  }
  
  void _calculateBMI() {
    if (weight != null && heightCm != null && heightCm! > 0) {
      double hM = heightCm! / 100;
      bmi = weight! / (hM * hM);
    }
  }
  
  void _calculateBodyFat() {
    // US Navy Method
    // Men: 86.010 * log10(abdomen - neck) - 70.041 * log10(height) + 36.76
    if (!isMale || waist == null || neck == null || heightCm == null) return;
    
    // Simple check
    if (waist! <= neck!) return; 
    
    bodyFat = 86.010 * (log10(waist! - neck!) / log10(10)) - 70.041 * (log10(heightCm!) / log10(10)) + 36.76;
  }
  
  double log10(num x) => (x > 0) ? (log(x) / ln10) : 0;
  double log(num x) => 2.302585092994046 * log10(x); // dart math log is base e
  double get ln10 => 2.302585092994046;

  void _calculateTDEE() {
      // Mifflin-St Jeor
      if (weight == null || heightCm == null || age == null) return;
      
      double s = isMale ? 5 : -161;
      double bmr = (10 * weight!) + (6.25 * heightCm!) - (5 * age!) + s;
      
      double multiplier = 1.2;
      switch (activityLevel) {
        case "Sedentary": multiplier = 1.2; break;
        case "Light": multiplier = 1.375; break;
        case "Moderate": multiplier = 1.55; break;
        case "Active": multiplier = 1.725; break;
        case "Very Active": multiplier = 1.9; break;
      }
      
      tdee = bmr * multiplier;
  }
  
  Future<void> saveLog() async {
    if (weight == null) return;
    final db = await _db.database;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    await db.insert('body_metrics', {
      'date': today,
      'weight': weight,
      'body_fat': bodyFat ?? 0,
      'waist': waist ?? 0,
      'neck': neck ?? 0,
      'chest': 0, // TODO
      'arms': 0,
      'legs': 0,
    });
    
    await fetchHistory();
  }
}
