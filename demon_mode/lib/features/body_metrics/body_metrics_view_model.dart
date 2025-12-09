import 'dart:math';
import 'package:flutter/material.dart';
import '../../data/database/database_service.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BodyMetricsViewModel extends ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;
  
  // Inputs
  double? weight;
  double? heightCm;
  double? neck;
  double? waist;
  int? age;
  bool isMale = true;
  String activityLevel = "Sedentary";
  String goal = "maintain";
  double? calorieTargetOverride;
  
  // Results
  double? bmi;
  double? bodyFat;
  double? tdee;
  double? maxDailyCaffeine;
  
  // History
  List<Map<String, dynamic>> weightHistory = [];

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    age = prefs.getInt('profile_age');
    heightCm = prefs.getDouble('profile_height');
    isMale = (prefs.getString('profile_gender') ?? 'male') == 'male';
    activityLevel = prefs.getString('profile_activity') ?? 'Sedentary';
    goal = prefs.getString('profile_goal') ?? 'maintain';
    calorieTargetOverride = prefs.getDouble('profile_calorie_override');

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
      // Use latest metrics if available and not overridden by text inputs (managed by UI usually, but here we sync)
    }
    calculateAll();
  }

  void calculateAll() {
    _calculateBMI();
    _calculateBodyFat(); // US Navy
    _calculateTDEE();
    _calculateCaffeineLimit();
    notifyListeners();
  }

  Future<void> updateProfile({int? a, double? h, bool? male, String? act, String? g, double? calOverride}) async {
    final prefs = await SharedPreferences.getInstance();
    if (a != null) { age = a; await prefs.setInt('profile_age', a); }
    if (h != null) { heightCm = h; await prefs.setDouble('profile_height', h); }
    if (male != null) { isMale = male; await prefs.setString('profile_gender', male ? 'male' : 'female'); }
    if (act != null) { activityLevel = act; await prefs.setString('profile_activity', act); }
    if (g != null) { goal = g; await prefs.setString('profile_goal', g); }
    
    if (calOverride != null) {
       if (calOverride < 0) {
         calorieTargetOverride = null;
         await prefs.remove('profile_calorie_override');
       } else {
         calorieTargetOverride = calOverride;
         await prefs.setDouble('profile_calorie_override', calOverride);
       }
    }
    calculateAll();
  }
  
  void _calculateBMI() {
    if (weight != null && heightCm != null && heightCm! > 0) {
      double hM = heightCm! / 100;
      bmi = weight! / (hM * hM);
    }
  }
  
  void _calculateBodyFat() {
    if (waist == null || neck == null || heightCm == null) return;
    // Simple check
    if (waist! <= neck!) return; 
    
    // US Navy Method
    if (isMale) {
      bodyFat = 86.010 * (log10(waist! - neck!) / log10(10)) - 70.041 * (log10(heightCm!) / log10(10)) + 36.76;
    } else {
      // Female calculation requires hips, adding partial support or fallback if hips missing
      // For now, using male formula or just skipping if female specific inputs missing.
      // Let's assume male formula for simplicity unless hips added.
    }
  }
  
  double log10(num x) => (x > 0) ? (log(x) / ln10) : 0;
  
  void _calculateCaffeineLimit() {
    // Safe limit: 400mg or 6mg/kg
    if (weight == null) {
      maxDailyCaffeine = 400;
    } else {
      double weightBased = weight! * 6;
      maxDailyCaffeine = weightBased < 400 ? weightBased : 400;
    }
  }

  void _calculateTDEE() {
      if (calorieTargetOverride != null) {
        tdee = calorieTargetOverride;
        return;
      }
  
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
      
      double maintenance = bmr * multiplier;
      
       if (goal == 'cut') {
        tdee = maintenance - 500;
      } else if (goal == 'bulk') {
        tdee = maintenance + 500;
      } else {
        tdee = maintenance;
      }
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
      'chest': 0, 
      'arms': 0,
      'legs': 0,
    });
    
    await fetchHistory();
  }
}
