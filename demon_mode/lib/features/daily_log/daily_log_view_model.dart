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
    
    double score = 0.0;

    // 1. Workout (2.0)
    bool workoutDone = _currentLog!.workoutDone || _currentLog!.workouts.isNotEmpty;
    if (workoutDone) score += 2.0;

    // 2. Nutrition & Hydration (1.5)
    double calories = await _repository.getDailyCalories(_currentLog!.date);
    bool nourished = calories >= 1800;
    bool hydrated = _currentLog!.waterIntake >= 3000;
    
    if (nourished) score += 1.0;
    if (hydrated) score += 0.5;

    // 3. Habits (2.0)
    if (_currentLog!.customHabits.isNotEmpty) {
      int completed = _currentLog!.customHabits.values.where((e) => e).length;
      score += (completed / _currentLog!.customHabits.length) * 2.0;
    } else {
      // If no habits set, assume free points or encourage setting them? 
      // Let's give points to not punish empty state, or maybe 0 to force user to set habits.
      // Going with 2.0 to be "default good" until they fail a set habit.
      score += 2.0;
    }

    // 4. Sleep (1.5) - Target 8h+ (User Request)
    if (_currentLog!.sleepHours >= 8) {
      score += 1.5;
    } else if (_currentLog!.sleepHours >= 6) {
      score += 0.75;
    }

    // 5. Journaling (1.5)
    if (_currentLog!.journalEntry != null && _currentLog!.journalEntry!.isNotEmpty) {
      score += 1.5;
    }

    // 6. Supplements (1.5)
    if (_currentLog!.supplements.isNotEmpty) {
      score += 1.5;
    }
    
    // Total max: 2 + 1.5 + 2 + 1.5 + 1.5 + 1.5 = 10.0
    
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

  Future<void> updateCoffee(int amount) async {
    if (_currentLog == null) return;
    final newAmount = (_currentLog!.coffeeIntake + amount).clamp(0, 10);
    _currentLog = _currentLog!.copyWith(coffeeIntake: newAmount);
    notifyListeners();
    await _save();
  }

  Future<void> updateMoodScore(int score) async {
    if (_currentLog == null) return;
    _currentLog = _currentLog!.copyWith(moodScore: score);
    notifyListeners();
    await _save();
  }
  
  Future<void> updateJournal(String text) async {
    if (_currentLog == null) return;
    _currentLog = _currentLog!.copyWith(journalEntry: text);
    notifyListeners();
    await _save();
  }

  Future<void> addSupplement(String name) async {
    if (_currentLog == null) return;
    if (_currentLog!.supplements.contains(name)) return;
    
    final newList = List<String>.from(_currentLog!.supplements)..add(name);
    _currentLog = _currentLog!.copyWith(supplements: newList);
    notifyListeners();
    await _save();
  }

  Future<void> removeSupplement(String name) async {
    if (_currentLog == null) return;
    final newList = List<String>.from(_currentLog!.supplements)..remove(name);
    _currentLog = _currentLog!.copyWith(supplements: newList);
    notifyListeners();
    await _save();
  }

  Future<void> _save() async {
    if (_currentLog != null) {
      await _repository.saveLog(_currentLog!);
    }
  }
}
