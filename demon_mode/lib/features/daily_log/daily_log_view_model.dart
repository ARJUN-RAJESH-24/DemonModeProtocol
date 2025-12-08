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

    // 1. Workout (20%)
    bool workoutDone = _currentLog!.workoutDone || _currentLog!.workouts.isNotEmpty;
    if (workoutDone) score += 2.0;

    // 2. Meal / Nutrition (20%) - Check if user is fueling
    double calories = await _repository.getDailyCalories(_currentLog!.date);
    if (calories >= 1800) {
      score += 2.0;
    } else if (calories >= 1000) {
      score += 1.0;
    }

    // 3. Task / Habits (20%)
    if (_currentLog!.customHabits.isNotEmpty) {
      int completed = _currentLog!.customHabits.values.where((e) => e).length;
      score += (completed / _currentLog!.customHabits.length) * 2.0;
    } else {
      score += 2.0;
    }

    // 4. Sleep (20%) - Target 7h
    if (_currentLog!.sleepHours >= 7) {
      score += 2.0;
    } else if (_currentLog!.sleepHours >= 5) {
      score += 1.0;
    }

    // 5. Hydration (20%) - Target 3000ml (3L)
    double hydrationScore = (_currentLog!.waterIntake / 3000).clamp(0.0, 1.0) * 2.0;
    score += hydrationScore;
    
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
