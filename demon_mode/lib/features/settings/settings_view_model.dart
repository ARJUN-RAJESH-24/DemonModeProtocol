import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../data/database/database_service.dart';

class SettingsViewModel extends ChangeNotifier {
  bool _biometricsEnabled = true; // Default to true for security
  String _version = "";

  bool get biometricsEnabled => _biometricsEnabled;
  String get version => _version;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _biometricsEnabled = prefs.getBool('biometrics_enabled') ?? true;
    
    final info = await PackageInfo.fromPlatform();
    _version = "${info.version} (${info.buildNumber})";
    notifyListeners();
  }

  Future<void> toggleBiometrics(bool value) async {
    _biometricsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometrics_enabled', value);
    notifyListeners();
  }

  Future<void> clearAllData() async {
    final db = DatabaseService.instance;
    // In a real app, you might drop tables or delete the file
    // Here we just delete all logs
    final database = await db.database;
    await database.delete('daily_logs');
    debugPrint("All data cleared.");
  }
}
