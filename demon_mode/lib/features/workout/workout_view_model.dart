import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:spotify_sdk/models/player_state.dart' as spotify_player;
import 'package:spotify_sdk/models/image_uri.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/workout_model.dart';
import '../../data/repositories/daily_log_repository.dart';

class WorkoutViewModel extends ChangeNotifier {
  // Timer State
  Timer? _timer;
  int _seconds = 0;
  bool _isWorkingOut = false;
  
  // GPS State
  StreamSubscription<Position>? _positionStream;
  double _totalDistance = 0; // in meters
  double _currentPace = 0; // min/km
  Position? _lastPosition;

  // Spotify State
  bool _isConnected = false;
  String _currentTrack = "Not Connected";
  bool _isPaused = true;

  // Workout Types
  String _workoutType = 'Gym';
  final List<String> workoutTypes = ['Gym', 'Run', 'Cycling', 'Calisthenics', 'Sports'];

  String get workoutType => _workoutType;

  // Gym State
  List<WorkoutExercise> _exercises = [];
  int get seconds => _seconds;
  bool get isWorkingOut => _isWorkingOut;
  String get currentTrack => _currentTrack;
  bool get isPaused => _isPaused;
  double get totalDistance => _totalDistance / 1000.0; // convert to km
  String get currentPace => _currentPace.toStringAsFixed(2);
  List<WorkoutExercise> get exercises => _exercises;

  final DailyLogRepository _logRepo = DailyLogRepository();

  WorkoutViewModel() {
    _restoreState();
  }

  Future<void> _restoreState() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonStr = prefs.getString('current_workout_exercises');
    
    if (jsonStr != null) {
      final List<dynamic> list = jsonDecode(jsonStr);
      _exercises = list.map((e) => WorkoutExercise.fromJson(e)).toList();
    }
    
    _isWorkingOut = prefs.getBool('current_workout_active') ?? false;
    _seconds = prefs.getInt('current_workout_seconds') ?? 0;
    _workoutType = prefs.getString('current_workout_type') ?? 'Gym';

    if (_isWorkingOut) {
      _startTimer();
    }
    notifyListeners();
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('current_workout_exercises', jsonEncode(_exercises.map((e) => e.toJson()).toList()));
    prefs.setBool('current_workout_active', _isWorkingOut);
    prefs.setInt('current_workout_seconds', _seconds);
    prefs.setString('current_workout_type', _workoutType);
  }

  Future<void> _clearResultState() async {
     final prefs = await SharedPreferences.getInstance();
     prefs.remove('current_workout_exercises');
     prefs.remove('current_workout_active');
     prefs.remove('current_workout_seconds');
     prefs.remove('current_workout_type');
  }

  void addExercise(WorkoutExercise exercise) {
    _exercises.add(exercise);
    _saveState();
    notifyListeners();
  }

  void logSet(String exerciseName, int reps, double weight) {
    final existingIndex = _exercises.indexWhere((e) => e.name == exerciseName);
    if (existingIndex != -1) {
      // Add to existing
      final existing = _exercises[existingIndex];
      final newSets = List<WorkoutSet>.from(existing.sets)..add(WorkoutSet(reps: reps, weight: weight));
      _exercises[existingIndex] = WorkoutExercise(name: existing.name, sets: newSets);
    } else {
      // Create new
      _exercises.add(WorkoutExercise(name: exerciseName, sets: [WorkoutSet(reps: reps, weight: weight)]));
    }
    _saveState();
    notifyListeners();
  }

  // --- Timer Logic ---
  void setWorkoutType(String type) {
    _workoutType = type;
    _saveState();
    notifyListeners();
  }

  void toggleWorkout() {
    if (_isWorkingOut) {
      _stopWorkout();
    } else {
      _startWorkout();
    }
  }

  void _startWorkout() {
    _isWorkingOut = true;
    _seconds = 0;
    _totalDistance = 0;
    _currentPace = 0;
    _lastPosition = null;
    
    _startTimer();
    
    // Start GPS only for outdoor activities
    if (['Run', 'Cycling', 'Sports'].contains(_workoutType)) {
      _initGPS();
    }
    _saveState();
    notifyListeners();
  }

  void _startTimer() {
     _timer?.cancel();
     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _seconds++;
      if (_seconds % 5 == 0) _saveState(); // Save every 5s
      notifyListeners();
    });
  }

  void _stopWorkout() async {
    _isWorkingOut = false;
    _timer?.cancel();
    _positionStream?.cancel();
    
    // Save session to DB
    if (_exercises.isNotEmpty || _seconds > 60) {
       final session = WorkoutSession(
         date: DateTime.now(),
         durationSeconds: _seconds,
         exercises: _exercises
       );
       
       final today = await _logRepo.getLogForDate(DateTime.now());
       final updatedLog = today.copyWith(
         workoutDone: true,
         workouts: [...today.workouts, session]
       );
       await _logRepo.saveLog(updatedLog);
    }

    // Clear local state
    _exercises = [];
    _seconds = 0;
    _clearResultState();
    
    notifyListeners();
  }

  // --- GPS Logic ---
  Future<void> _initGPS() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint("Location services are disabled.");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    
    if (permission == LocationPermission.deniedForever) return;

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    );

    _positionStream = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      if (_lastPosition != null) {
        final distance = Geolocator.distanceBetween(
          _lastPosition!.latitude,
          _lastPosition!.longitude,
          position.latitude,
          position.longitude,
        );
        _totalDistance += distance;
        
        // Calculate Pace (min/km)
        // Speed is in m/s. 
        // Pace = (1 / speed) * (1000 / 60)
        if (position.speed > 0.5) { // Threshold to avoid noise when standing still
             double speedMps = position.speed; // m/s
             double paceMinPerKm = (1000 / speedMps) / 60;
             _currentPace = paceMinPerKm;
        } else {
            _currentPace = 0;
        }
      }
      _lastPosition = position;
      notifyListeners();
    });
  }

  // --- Spotify Logic ---
  Future<void> connectSpotify() async {
    try {
      final res = await SpotifySdk.connectToSpotifyRemote(
        clientId: "4b92c4731f8742718137357c91c071d0", // Included a default/demo ID if possible or user's placeholder
        redirectUrl: "demonmode://callback",
      );
      if (res) {
        _isConnected = true;
        _subscribeToPlayerState();
        // Also fetch current state immediately
        await SpotifySdk.resume(); 
      }
    } catch (e) {
      debugPrint("Spotify Connect Error: $e");
    }
    notifyListeners();
  }

  void _subscribeToPlayerState() {
    SpotifySdk.subscribePlayerState().listen((state) {
      if (state.track != null) {
        _currentTrack = "${state.track!.name} • ${state.track!.artist.name}";
        _isPaused = state.isPaused;
        notifyListeners();
      }
    });
  }

  Future<void> play() async { 
    await SpotifySdk.resume(); 
    _isPaused = false;
    notifyListeners();
  }
  Future<void> pause() async { 
    await SpotifySdk.pause();
    _isPaused = true;
    notifyListeners();
  }
  Future<void> skipNext() async { 
    await SpotifySdk.skipNext(); 
  }
  Future<void> skipPrevious() async { 
    await SpotifySdk.skipPrevious(); 
  }

  @override
  void dispose() {
    _timer?.cancel();
    _positionStream?.cancel();
    super.dispose();
  }
}
