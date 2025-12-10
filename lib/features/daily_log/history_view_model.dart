import 'package:flutter/material.dart';
import '../../data/repositories/daily_log_repository.dart';
import '../../data/models/daily_log_model.dart';

class HistoryViewModel extends ChangeNotifier {
  final DailyLogRepository _repository = DailyLogRepository();
  
  List<DailyLogModel> _history = [];
  bool _isLoading = false;
  
  // Selected Details
  DailyLogModel? _selectedLog;
  List<Map<String, dynamic>> _selectedMeals = [];
  List<Map<String, dynamic>> _selectedMetrics = [];
  bool _isLoadingDetails = false;

  List<DailyLogModel> get history => _history;
  bool get isLoading => _isLoading;
  
  DailyLogModel? get selectedLog => _selectedLog;
  List<Map<String, dynamic>> get selectedMeals => _selectedMeals;
  List<Map<String, dynamic>> get selectedMetrics => _selectedMetrics;
  bool get isLoadingDetails => _isLoadingDetails;

  Future<void> loadHistory() async {
    _isLoading = true;
    notifyListeners();
    try {
      final logs = await _repository.getAllLogs();
      // Sort by date descending
      logs.sort((a, b) => b.date.compareTo(a.date));
      _history = logs;
    } catch (e) {
      debugPrint("Error loading history: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDetails(DailyLogModel log) async {
    _selectedLog = log;
    _isLoadingDetails = true;
    notifyListeners();
    
    try {
      final date = log.date;
      _selectedMeals = await _repository.getMealsForDate(date);
      _selectedMetrics = await _repository.getBodyMetricsForDate(date);
    } catch (e) {
      debugPrint("Error loading details: $e");
    } finally {
      _isLoadingDetails = false;
      notifyListeners();
    }
  }
}
