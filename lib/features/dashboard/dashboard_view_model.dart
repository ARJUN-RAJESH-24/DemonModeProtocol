import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/daily_log_model.dart';
import '../../data/repositories/daily_log_repository.dart';
import '../daily_log/daily_log_view_model.dart';

class DashboardViewModel extends ChangeNotifier {
  final DailyLogRepository _repository = DailyLogRepository();
  DailyLogViewModel? _logViewModel;
  
  StreamSubscription<StepCount>? _stepSubscription;
  int _steps = 0;
  String _status = 'Stopped';
  
  // Chart Data
  List<DailyLogModel> _weeklyLogs = [];

  int get steps => _logViewModel?.currentLog?.steps ?? _steps;
  String get status => _status;
  List<DailyLogModel> get weeklyLogs => _weeklyLogs;
  DailyLogModel? get todayLog => _weeklyLogs.isNotEmpty ? _weeklyLogs.last : null;

  void updateLogViewModel(DailyLogViewModel vm) {
    _logViewModel = vm;
    // Sync local steps with log VM if available
    if (_logViewModel?.currentLog != null) {
      _steps = _logViewModel!.currentLog!.steps;
    }
    notifyListeners();
  }

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
      
      // Update DailyLogViewModel which handles saving and source of truth
      if (_logViewModel != null) {
         _logViewModel!.updateSteps(_steps);
      }
      
      // Update UI state immediately
      if (_weeklyLogs.isNotEmpty && _isToday(_weeklyLogs.last.date)) {
        _weeklyLogs.last = _weeklyLogs.last.copyWith(steps: _steps);
      }
      
      notifyListeners();
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
        if (log.demonScore >= 4.0 || log.workoutDone || log.customHabits.isNotEmpty) {
            _streak++;
        } else {
            // Allow today to be incomplete without breaking streak if previous days were good
            if (log.date.day == today.day && _streak == 0) continue; 
            break; 
        }
    }

    _weeklyLogs = recentLogs.take(7).toList().reversed.toList();
    
    notifyListeners();
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  @override
  void dispose() {
    _stepSubscription?.cancel();
    super.dispose();
  }
  // Quotes
  final List<String> _quotes = [
    "Hard things, done daily.",
    "Discipline is doing what you hate to do, but doing it like you love it. - Tyson",
    "You don't decide your future. You decide your habits, and your habits decide your future.",
    "The pain of discipline is far less than the pain of regret.",
    "Outwork your doubts.",
    "Your body can stand almost anything. It’s your mind that you have to convince.",
    "Do something today that your future self will thank you for.",
    "Comfort is the enemy of progress.",
  ];
  
  String get randomQuote {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return _quotes[dayOfYear % _quotes.length];
  }
}
