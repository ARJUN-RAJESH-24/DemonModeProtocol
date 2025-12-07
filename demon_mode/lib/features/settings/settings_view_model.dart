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
    debugPrint("All data cleared.");
  }
}
