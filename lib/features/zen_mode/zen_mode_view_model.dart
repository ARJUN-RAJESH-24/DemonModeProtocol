import 'package:flutter/material.dart';
import '../../data/repositories/daily_log_repository.dart';

class ZenModeViewModel extends ChangeNotifier {
  final DailyLogRepository _repo = DailyLogRepository();
  String _thoughts = "";
  bool _isSaving = false;

  String get thoughts => _thoughts;
  bool get isSaving => _isSaving;

  Future<void> loadThoughts() async {
    final log = await _repo.getLogForDate(DateTime.now());
    _thoughts = log.notes ?? "";
    notifyListeners();
  }

  void updateThoughts(String val) {
    _thoughts = val;
    // Debounce saving could be added here, but manual save is fine for Zen Mode
    notifyListeners();
  }

  Future<void> saveThoughts() async {
    _isSaving = true;
    notifyListeners();

    try {
      final now = DateTime.now();
      final log = await _repo.getLogForDate(now);
      await _repo.saveLog(log.copyWith(notes: _thoughts));
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
