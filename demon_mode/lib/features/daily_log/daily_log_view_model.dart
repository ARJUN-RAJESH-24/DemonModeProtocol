import 'package:flutter/material.dart';
import '../../data/models/daily_log_model.dart';
import '../../data/repositories/daily_log_repository.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class DailyLogViewModel extends ChangeNotifier {
  final DailyLogRepository _repository = DailyLogRepository();
  final ImagePicker _picker = ImagePicker();
  
  DailyLogModel? _currentLog;
  bool _isLoading = false;

  DailyLogModel? get currentLog => _currentLog;
  bool get isLoading => _isLoading;

  Future<void> loadLog(DateTime date) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      _currentLog = await _repository.getLogForDate(date);
    } catch (e) {
      debugPrint("Error loading log: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateWater(int amount) async {
    if (_currentLog == null) return;
    final newAmount = (_currentLog!.waterIntake + amount).clamp(0, 5000); // Max 5L
    _currentLog = _currentLog!.copyWith(waterIntake: newAmount);
    notifyListeners();
    await _save();
  }

  Future<void> toggleWorkout() async {
    if (_currentLog == null) return;
    _currentLog = _currentLog!.copyWith(workoutDone: !_currentLog!.workoutDone);
    notifyListeners();
    await _save();
  }

  Future<void> updateMood(String mood) async {
    if (_currentLog == null) return;
    _currentLog = _currentLog!.copyWith(mood: mood);
    notifyListeners();
    await _save();
  }

  Future<void> updateSleep(double hours) async {
    if (_currentLog == null) return;
    _currentLog = _currentLog!.copyWith(sleepHours: hours);
    await _calculateAndSaveScore();
  }

  Future<void> toggleCustomHabit(String habit, bool value) async {
    if (_currentLog == null) return;
    final newHabits = Map<String, bool>.from(_currentLog!.customHabits);
    newHabits[habit] = value;
    _currentLog = _currentLog!.copyWith(customHabits: newHabits);
    await _calculateAndSaveScore();
  }

  Future<void> _calculateAndSaveScore() async {
    if (_currentLog == null) return;
    
    // Default habits count + custom habits + sleep check
    // Assuming we sync habits from PreferencesRepository eventually, but for now using keys in map
    // The map in _currentLog ONLY has checked/unchecked state for habits that have been toggled? 
    // Or does it contain all?
    // The DemonHabitsScreen has the authority on "All Habits".
    // We should probably rely on the screen to pass the "Total Count" or have a robust way to know total habits.
    // For now, let's just count (True habits / Total Keys in Map) + Sleep Bonus?
    // Actually, to be accurate, we need the total list of habits to know the denominator.
    // But since the View Model doesn't easily access the "Settings" habits without injection,
    // we will assume the map contains all relevant habits for the day once initialized.
    
    int completed = _currentLog!.customHabits.values.where((e) => e).length;
    int total = _currentLog!.customHabits.length;
    
    // Add Sleep
    if (_currentLog!.sleepHours >= 7) {
      completed++;
    }
    total++; // Sleep is a habit

    double score = total > 0 ? (completed / total) * 10 : 0;
    
    _currentLog = _currentLog!.copyWith(demonScore: score);
    notifyListeners();
    await _save();
  }

  Future<void> addPhoto() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image == null || _currentLog == null) return;

      // Save to app directory
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'body_check_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedImage = await File(image.path).copy(path.join(appDir.path, fileName));

      final newPaths = List<String>.from(_currentLog!.photoPaths)..add(savedImage.path);
      _currentLog = _currentLog!.copyWith(photoPaths: newPaths);
      notifyListeners();
      await _save();
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  Future<void> _save() async {
    if (_currentLog != null) {
      await _repository.saveLog(_currentLog!);
    }
  }
}
