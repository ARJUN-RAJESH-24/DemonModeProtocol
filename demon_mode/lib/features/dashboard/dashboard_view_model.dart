import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../data/models/daily_log_model.dart';
import '../../data/repositories/daily_log_repository.dart';

class DashboardViewModel extends ChangeNotifier {
  final DailyLogRepository _repository = DailyLogRepository();
  
  StreamSubscription<StepCount>? _stepSubscription;
  int _steps = 0;
  String _status = 'Stopped';
  
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

  void _onStepCount(StepCount event) {
    _steps = event.steps;
    notifyListeners();
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
    
    // Load last 30 days for better streak calc (or just 7 for now)
    // Let's load 14 days
    List<DailyLogModel> recentLogs = [];
    for (int i = 0; i < 14; i++) {
      final date = today.subtract(Duration(days: i));
      final log = await _repository.getLogForDate(date);
      recentLogs.add(log);
    }
    
    // Determine streak (consecutive days with score > 0 or just created entries?)
    // For now, let's say "Streak" is just days logged in a row.
    // Or simpler: Random 14 for demo? No, let's try to be real.
    // Iterate from today (index 0) backwards.
    for (var log in recentLogs) {
        if (log.demonScore >= 4.0) { // arbitrary threshold for "Good Day"
            _streak++;
        } else {
            // Check if it's today and we just started, don't break yet?
            if (log.date.day == today.day && _streak == 0) continue; 
            break;
        }
    }

    // Weekly logs for charts (Last 7 days reversed for graph)
    _weeklyLogs = recentLogs.take(7).toList().reversed.toList();
    
    notifyListeners();
  }

  @override
  void dispose() {
    _stepSubscription?.cancel();
    super.dispose();
  }
}
