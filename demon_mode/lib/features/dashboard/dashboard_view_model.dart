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

  Future<void> _loadWeeklyData() async {
    final today = DateTime.now();
    _weeklyLogs = [];
    // Load last 7 days
    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final log = await _repository.getLogForDate(date);
      _weeklyLogs.add(log);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _stepSubscription?.cancel();
    super.dispose();
  }
}
