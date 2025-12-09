import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/daily_log_model.dart';
import '../../data/repositories/daily_log_repository.dart';

class DashboardViewModel extends ChangeNotifier {
  final DailyLogRepository _repository = DailyLogRepository();
  
  StreamSubscription<StepCount>? _stepSubscription;
  int _steps = 0;
  String _status = 'Stopped';
  Timer? _saveTimer;
  
  // Chart Data
  List<DailyLogModel> _weeklyLogs = [];

  int get steps => _steps;
  String get status => _status;
  List<DailyLogModel> get weeklyLogs => _weeklyLogs;
  DailyLogModel? get todayLog => _weeklyLogs.isNotEmpty ? _weeklyLogs.last : null;

  Future<void> init() async {
    await _checkPermissions();
    _initPedometer();
    await _loadWeeklyData();
  }

  Future<void> _checkPermissions() async {
    await Permission.activityRecognition.request();
    await Permission.sensors.request();
  }

  void _initPedometer() {
    _stepSubscription = Pedometer.stepCountStream.listen(
      _onStepCount,
      onError: _onStepError,
      cancelOnError: true,
    );
  }

  Future<void> _onStepCount(StepCount event) async {
    final prefs = await SharedPreferences.getInstance();
    // Use a unique key to track the raw sensor value
    int lastVal = prefs.getInt('last_sensor_step') ?? event.steps;
    
    int delta = event.steps - lastVal;
    
    // If delta is negative, device rebooted or counter reset
    if (delta < 0) {
      delta = event.steps;
    }
    
    // Save current as last
    await prefs.setInt('last_sensor_step', event.steps);
    
    if (delta > 0) {
      _steps += delta;
      
      // Update UI state immediately
      if (_weeklyLogs.isNotEmpty && _isToday(_weeklyLogs.last.date)) {
        _weeklyLogs.last = _weeklyLogs.last.copyWith(steps: _steps);
      }
      
      notifyListeners();
      _debounceSave();
    }
  }

  void _debounceSave() {
    if (_saveTimer?.isActive ?? false) _saveTimer!.cancel();
    _saveTimer = Timer(const Duration(seconds: 10), _saveStepsToDB);
  }

  Future<void> _saveStepsToDB() async {
    try {
      final today = DateTime.now();
      // Fetch fresh to avoid overwriting other fields
      final log = await _repository.getLogForDate(today);
      if (log.steps != _steps) {
        await _repository.saveLog(log.copyWith(steps: _steps));
      }
    } catch (e) {
      debugPrint("Error saving steps: $e");
    }
  }

  void _onStepError(error) {
    debugPrint('Pedometer Error: $error');
    _status = 'Sensor Error';
    notifyListeners();
  }

  int _streak = 0;
  int get streak => _streak;

  Future<void> _loadWeeklyData() async {
    final today = DateTime.now();
    _weeklyLogs = [];
    _streak = 0;
    
    List<DailyLogModel> recentLogs = [];
    for (int i = 0; i < 14; i++) {
      final date = today.subtract(Duration(days: i));
      final log = await _repository.getLogForDate(date);
      recentLogs.add(log);
    }
    
    // Determine streak
    for (var log in recentLogs) {
        if (log.demonScore >= 4.0) {
            _streak++;
        } else {
            if (log.date.day == today.day && _streak == 0) continue; 
            break;
        }
    }

    _weeklyLogs = recentLogs.take(7).toList().reversed.toList();
    
    // Initialize current steps from today's log if available
    if (_weeklyLogs.isNotEmpty && _isToday(_weeklyLogs.last.date)) {
      _steps = _weeklyLogs.last.steps;
    } else {
      _steps = 0;
    }
    
    notifyListeners();
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  @override
  void dispose() {
    _stepSubscription?.cancel();
    _saveTimer?.cancel();
    super.dispose();
  }
}
