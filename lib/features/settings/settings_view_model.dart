import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // For batch
import '../../data/database/database_service.dart';
import '../../data/repositories/preferences_repository.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/theme/app_pallete.dart';

class SettingsViewModel extends ChangeNotifier {
  final PreferencesRepository _prefsRepo = PreferencesRepository();
  bool _biometricsEnabled = true;
  String _version = "";
  List<String> _habits = [];
  String _unitSystem = 'metric';
  Color _accentColor = AppPallete.primaryColor;

  bool get biometricsEnabled => _biometricsEnabled;
  String get version => _version;
  List<String> get habits => _habits;
  String get unitSystem => _unitSystem;
  Color get accentColor => _accentColor;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _biometricsEnabled = prefs.getBool('biometrics_enabled') ?? true;
    
    final info = await PackageInfo.fromPlatform();
    _version = "${info.version} (${info.buildNumber})";
    
    _habits = await _prefsRepo.getHabits();
    _unitSystem = await _prefsRepo.getUnitSystem();

    // Load Accent Color
    final colorVal = prefs.getInt('accent_color');
    if (colorVal != null) {
      _accentColor = Color(colorVal);
    }
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

  Future<void> setAccentColor(Color color) async {
    _accentColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('accent_color', color.value);
    notifyListeners();
  }

  Future<void> clearAllData() async {
    final db = DatabaseService.instance;
    final database = await db.database;
    await database.delete('daily_logs');
    await database.delete('meal_logs');
    debugPrint("All data cleared.");
  }

  Future<void> exportData() async {
    try {
      // Request Storage Permission (for older Android)
      // On Android 13+, this is largely ignored for Share/Pick but good practice for legacy.
      if (Platform.isAndroid) {
        // Simple check, don't block if denied as scoped storage might still work
        await Permission.storage.request(); 
      }

      final db = DatabaseService.instance;
      final database = await db.database;

      // 1. Fetch All Data
      final dailyLogs = await database.query('daily_logs');
      final mealLogs = await database.query('meal_logs');
      final foods = await database.query('foods', where: 'is_custom = ?', whereArgs: [1]); 
      final bodyMetrics = await database.query('body_metrics');
      
      final exportMap = {
        'version': 2,
        'timestamp': DateTime.now().toIso8601String(),
        'daily_logs': dailyLogs,
        'meal_logs': mealLogs,
        'foods': foods,
        'body_metrics': bodyMetrics,
      };

      // 2. Serialize
      final jsonString = jsonEncode(exportMap);

      // 3. Write to Temp File
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/demon_mode_backup_${DateTime.now().millisecondsSinceEpoch}.json');
      await file.writeAsString(jsonString);

      // 4. Share
      await Share.shareXFiles([XFile(file.path)], text: 'Demon Mode Protocol Backup');
      
    } catch (e) {
      debugPrint("Export Error: $e");
    }
  }

  Future<void> importData() async {
    try {
      if (Platform.isAndroid) {
        await Permission.storage.request();
      }

      // 1. Pick File
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final jsonString = await file.readAsString();
        
        // 2. Validate & Parse
        final Map<String, dynamic> importMap = jsonDecode(jsonString);
        if (importMap['version'] == null || importMap['daily_logs'] == null) {
           throw Exception("Invalid Backup File");
        }

        // 3. Restore (Clear & Insert)
        final db = DatabaseService.instance;
        final database = await db.database;
        
        await database.transaction((txn) async {
          // Nuke
          await txn.delete('daily_logs');
          await txn.delete('meal_logs');
          await txn.delete('foods'); 
          await txn.delete('body_metrics');
          
          // Insert
          final Batch batch = txn.batch();
          
          for (var log in (importMap['daily_logs'] as List)) {
            batch.insert('daily_logs', log as Map<String, dynamic>);
          }
          for (var food in (importMap['foods'] as List)) {
             batch.insert('foods', food as Map<String, dynamic>);
          }
           for (var log in (importMap['meal_logs'] as List)) {
            batch.insert('meal_logs', log as Map<String, dynamic>);
          }
           for (var metric in (importMap['body_metrics'] as List)) {
            batch.insert('body_metrics', metric as Map<String, dynamic>);
          }
          
          await batch.commit(noResult: true);
        });
        
        // 4. Notify / Reload
        // We need to tell the app to reload data. 
        // Best way is to restart or have ViewModels listen to this?
        // For now, simpler to just notify and maybe user manually refreshes or we explicitly re-init providers if possible.
        // Or just show success string.
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Import Error: $e");
    }
  }
}
