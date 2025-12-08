import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../data/database/database_service.dart';
import '../../data/repositories/preferences_repository.dart';

class SettingsViewModel extends ChangeNotifier {
  final PreferencesRepository _prefsRepo = PreferencesRepository();
  bool _biometricsEnabled = true;
  String _version = "";
  List<String> _habits = [];
  String _unitSystem = 'metric';

  // Profile
  int? age;
  double? height; // cm
  double? weight; // kg
  String gender = 'male';
  double activityLevel = 1.55;
  String goal = 'maintain'; // cut, bulk, maintain
  double? calorieTargetOverride;
  double? tdee;

  bool get biometricsEnabled => _biometricsEnabled;
  String get version => _version;
  List<String> get habits => _habits;
  String get unitSystem => _unitSystem;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _biometricsEnabled = prefs.getBool('biometrics_enabled') ?? true;
    
    final info = await PackageInfo.fromPlatform();
    _version = "${info.version} (${info.buildNumber})";
    
    _habits = await _prefsRepo.getHabits();
    _unitSystem = await _prefsRepo.getUnitSystem();

    // Load Profile
    age = prefs.getInt('profile_age');
    height = prefs.getDouble('profile_height');
    weight = prefs.getDouble('profile_weight');
    gender = prefs.getString('profile_gender') ?? 'male';
    activityLevel = prefs.getDouble('profile_activity') ?? 1.55;
    goal = prefs.getString('profile_goal') ?? 'maintain';
    calorieTargetOverride = prefs.getDouble('profile_calorie_override');
    
    _calculateTDEE();
    notifyListeners();
  }

  Future<void> toggleBiometrics(bool value) async {
    _biometricsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometrics_enabled', value);
    notifyListeners();
  }

  Future<void> addHabit(String habit) async {
    await _prefsRepo.addHabit(habit.trim());
    _habits = await _prefsRepo.getHabits();
    notifyListeners();
  }

  Future<void> removeHabit(String habit) async {
    await _prefsRepo.removeHabit(habit);
    _habits = await _prefsRepo.getHabits();
    notifyListeners();
  }

  Future<void> toggleUnitSystem(String value) async {
    await _prefsRepo.setUnitSystem(value);
    _unitSystem = value;
    notifyListeners();
  }

  Future<void> clearAllData() async {
    final db = DatabaseService.instance;
    final database = await db.database;
    await database.delete('daily_logs');
    await database.delete('meal_logs');
    debugPrint("All data cleared.");
  }

  Future<void> updateProfile({int? a, double? h, double? w, String? g, String? sex, double? activity, double? calOverride}) async {
    final prefs = await SharedPreferences.getInstance();
    if (a != null) { age = a; await prefs.setInt('profile_age', a); }
    if (h != null) { height = h; await prefs.setDouble('profile_height', h); }
     if (w != null) { weight = w; await prefs.setDouble('profile_weight', w); }
    if (g != null) { goal = g; await prefs.setString('profile_goal', g); }
    if (sex != null) { gender = sex; await prefs.setString('profile_gender', sex); }
    if (activity != null) { activityLevel = activity; await prefs.setDouble('profile_activity', activity); }
    
    if (calOverride != null) {
       // if -1, clear it
       if (calOverride < 0) {
         calorieTargetOverride = null;
         await prefs.remove('profile_calorie_override');
       } else {
         calorieTargetOverride = calOverride;
         await prefs.setDouble('profile_calorie_override', calOverride);
       }
    }
    
    _calculateTDEE();
    notifyListeners();
  }
  
  void _calculateTDEE() {
    if (calorieTargetOverride != null) {
      tdee = calorieTargetOverride;
      return;
    }
  
    if (weight == null || height == null || age == null) return;
    
    // Mifflin-St Jeor
    double bmr = (10 * weight!) + (6.25 * height!) - (5 * age!);
    if (gender == 'male') {
      bmr += 5;
    } else {
      bmr -= 161;
    }
    
    double maintenance = bmr * activityLevel;
    
    if (goal == 'cut') {
      tdee = maintenance - 500;
    } else if (goal == 'bulk') {
      tdee = maintenance + 500;
    } else {
      tdee = maintenance;
    }
  }

  Future<void> exportData() async {
    // Basic export stub
    debugPrint("Exporting data invoked.");
  }

  Future<void> importData() async {
    // Basic import stub
    debugPrint("Importing data invoked.");
  }
}
