import 'package:flutter/material.dart';
import '../../data/database/database_service.dart';
import '../../data/models/food_model.dart';
import 'package:intl/intl.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import '../settings/settings_view_model.dart';
import '../body_metrics/body_metrics_view_model.dart';

class NutritionViewModel extends ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;
  
  List<MealLog> _todayLogs = [];
  List<FoodItem> _foodSearchResults = [];
  
  // Daily Totals
  double _totalKCal = 0;
  double _totalProtein = 0;
  double _totalCarbs = 0;
  double _totalFats = 0;
  double _totalCaffeine = 0;
  
  // Targets (Hardcoded for now/User pref later)
  double targetKCal = 2500;
  double targetProtein = 180;
  
  BodyMetricsViewModel? _bodyMetrics;
  
  List<MealLog> get todayLogs => _todayLogs;
  List<FoodItem> get foodSearchResults => _foodSearchResults;
  double get totalKCal => _totalKCal;
  double get totalProtein => _totalProtein;
  double get totalCarbs => _totalCarbs;
  double get totalFats => _totalFats;
  double get totalCaffeine => _totalCaffeine;

  String? get safetyWarning {
    if (_bodyMetrics?.maxDailyCaffeine != null) {
      if (_totalCaffeine > _bodyMetrics!.maxDailyCaffeine!) {
        return "CRITICAL: Caffeine limit exceeded (${_totalCaffeine.toInt()}mg / ${_bodyMetrics!.maxDailyCaffeine!.toInt()}mg)";
      }
    } else {
       if (_totalCaffeine > 400) {
         return "WARNING: High caffeine intake (${_totalCaffeine.toInt()}mg)";
       }
    }
    return null;
  }

  Future<void> init(BodyMetricsViewModel bodyMetrics) async {
    _bodyMetrics = bodyMetrics;
    // Update targets based on settings
    if (bodyMetrics.tdee != null) {
      targetKCal = bodyMetrics.tdee!;
    }
    await fetchTodayLogs();
  }

  Future<void> fetchTodayLogs() async {
    final db = await _db.database;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    final maps = await db.rawQuery('''
      SELECT 
        m.id as log_id, m.date, m.meal_type, m.serving_multiplier,
        f.id as food_id, f.name, f.kcal, f.protein, f.carbs, f.fats, f.serving_unit, f.serving_quantity, f.is_custom, f.caffeine
      FROM meal_logs m
      INNER JOIN foods f ON m.food_id = f.id
      WHERE m.date = ?
    ''', [today]);
    
    _todayLogs = maps.map((map) {
      final foodMap = {
        'id': map['food_id'],
        'name': map['name'],
        'kcal': map['kcal'],
        'protein': map['protein'],
        'carbs': map['carbs'],
        'fats': map['fats'],
        'serving_unit': map['serving_unit'],
        'serving_quantity': map['serving_quantity'],
        'is_custom': map['is_custom'],
        'caffeine': map['caffeine']
      };
      
      final food = FoodItem.fromMap(foodMap);
      return MealLog(
        id: map['log_id'] as int,
        date: map['date'] as String,
        mealType: map['meal_type'] as String,
        foodId: map['food_id'] as int,
        servingMultiplier: map['serving_multiplier'] as double,
        food: food,
      );
    }).toList();
    
    _calculateTotals();
    notifyListeners();
  }
  
  void _calculateTotals() {
    _totalKCal = 0;
    _totalProtein = 0;
    _totalCarbs = 0;
    _totalFats = 0;
    _totalCaffeine = 0;
    
    for (var log in _todayLogs) {
      _totalKCal += log.totalKCal;
      _totalProtein += log.totalProtein;
      _totalCarbs += log.totalCarbs;
      _totalFats += log.totalFats;
      _totalCaffeine += log.totalCaffeine;
    }
  }

  Future<void> searchFood(String query) async {
    final db = await _db.database;
    final results = await db.query(
      'foods',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      limit: 20
    );
    
    _foodSearchResults = results.map((e) => FoodItem.fromMap(e)).toList();
    notifyListeners();
  }
  
  Future<void> logFood(FoodItem food, String mealType, double quantityMultiplier) async {
    final db = await _db.database;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    await db.insert('meal_logs', {
      'date': today,
      'meal_type': mealType,
      'food_id': food.id,
      'serving_multiplier': quantityMultiplier,
      'created_at': DateTime.now().toIso8601String(),
    });
    
    await fetchTodayLogs();
  }

  Future<int> addCustomFood(FoodItem food) async {
    final db = await _db.database;
    return await db.insert('foods', food.toMap());
  }

  bool _isSeeded = false;

  Future<void> seedIndianDatabase() async {
    if (_isSeeded) return;

    final db = await _db.database;
    // Check if empty
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM foods'));
    if ((count ?? 0) > 0) {
      _isSeeded = true;
      return;
    }

    // Seed Data
    final foods = [
      FoodItem(name: "Chicken Breast (Cooked)", kCal: 165, protein: 31, carbs: 0, fats: 3.6, servingUnit: "100g", servingQuantity: 100),
      FoodItem(name: "White Rice (Cooked)", kCal: 130, protein: 2.7, carbs: 28, fats: 0.3, servingUnit: "100g", servingQuantity: 100),
      FoodItem(name: "Chapati (Medium)", kCal: 104, protein: 3, carbs: 17, fats: 3, servingUnit: "pc", servingQuantity: 1),
      FoodItem(name: "Dal Tadka", kCal: 156, protein: 6, carbs: 18, fats: 7, servingUnit: "bowl (150g)", servingQuantity: 150),
      FoodItem(name: "Paneer (Raw)", kCal: 265, protein: 18, carbs: 1.2, fats: 20, servingUnit: "100g", servingQuantity: 100),
      FoodItem(name: "Egg (Large)", kCal: 72, protein: 6, carbs: 0.4, fats: 5, servingUnit: "pc", servingQuantity: 1),
      FoodItem(name: "Whey Protein", kCal: 120, protein: 24, carbs: 3, fats: 1, servingUnit: "scoop", servingQuantity: 30),
      FoodItem(name: "Banana", kCal: 105, protein: 1.3, carbs: 27, fats: 0.4, servingUnit: "medium", servingQuantity: 118),
      FoodItem(name: "Oats", kCal: 389, protein: 16.9, carbs: 66, fats: 6.9, servingUnit: "100g", servingQuantity: 100),
      FoodItem(name: "Dosa (Plain)", kCal: 133, protein: 4, carbs: 23, fats: 3, servingUnit: "medium", servingQuantity: 1),
      FoodItem(name: "Idli", kCal: 39, protein: 2, carbs: 8, fats: 0, servingUnit: "pc", servingQuantity: 1),
      FoodItem(name: "Greek Yogurt", kCal: 59, protein: 10, carbs: 3.6, fats: 0.4, servingUnit: "100g", servingQuantity: 100),
      FoodItem(name: "Peanut Butter", kCal: 588, protein: 25, carbs: 20, fats: 50, servingUnit: "tbsp (15g)", servingQuantity: 15),
      FoodItem(name: "Almonds", kCal: 579, protein: 21, carbs: 22, fats: 50, servingUnit: "100g", servingQuantity: 100),
      FoodItem(name: "Milk (Whole)", kCal: 61, protein: 3.2, carbs: 4.8, fats: 3.3, servingUnit: "100ml", servingQuantity: 100),
      FoodItem(name: "Soya Chunks", kCal: 345, protein: 52, carbs: 33, fats: 0.5, servingUnit: "100g", servingQuantity: 100),
      FoodItem(name: "Fish Curry", kCal: 300, protein: 25, carbs: 10, fats: 15, servingUnit: "bowl", servingQuantity: 250),
      FoodItem(name: "Mutton Curry", kCal: 450, protein: 30, carbs: 10, fats: 30, servingUnit: "bowl", servingQuantity: 250),
      FoodItem(name: "Brown Rice", kCal: 111, protein: 2.6, carbs: 23, fats: 0.9, servingUnit: "100g", servingQuantity: 100),
      FoodItem(name: "Coffee (Black)", kCal: 2, protein: 0, carbs: 0, fats: 0, servingUnit: "cup", servingQuantity: 200),
    ];

    for (var f in foods) {
      await db.insert('foods', f.toMap());
    }
    _isSeeded = true;
  }
}
