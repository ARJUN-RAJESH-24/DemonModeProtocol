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

  Future<void> loadLogForToday() async {
    _isLoading = true;
    notifyListeners();
    
    final today = DateTime.now();
    _currentLog = await _repository.getLogForDate(today);
    
    _isLoading = false;
    notifyListeners();
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
