import 'dart:convert';
import 'workout_model.dart';

class DailyLogModel {
  final int? id;
  final DateTime date;
  final int waterIntake;
  final bool workoutDone;
  final String mood;
  final List<String> photoPaths;
  final String? notes; // Zen Mode thoughts
  final Map<String, bool> customHabits;
  final List<WorkoutSession> workouts;
  final double sleepHours;
  final double demonScore;

  DailyLogModel({
    this.id,
    required this.date,
    this.waterIntake = 0,
    this.workoutDone = false,
    this.mood = 'Neutral',
    this.photoPaths = const [],
    this.notes,
    this.customHabits = const {},
    this.workouts = const [],
    this.sleepHours = 0.0,
    this.demonScore = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'water_intake': waterIntake,
      'workout_done': workoutDone ? 1 : 0,
      'mood': mood,
      'photo_paths': jsonEncode(photoPaths),
      'notes': notes,
      'custom_habits': jsonEncode(customHabits),
      'workout_details': jsonEncode(workouts.map((e) => e.toJson()).toList()),
      'sleep_hours': sleepHours,
      'demon_score': demonScore,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  factory DailyLogModel.fromJson(Map<String, dynamic> json) {
    return DailyLogModel(
      id: json['id'],
      date: DateTime.parse(json['date']),
      waterIntake: json['water_intake'] ?? 0,
      workoutDone: json['workout_done'] == 1,
      mood: json['mood'] ?? 'Neutral',
      photoPaths: List<String>.from(jsonDecode(json['photo_paths'] ?? '[]')),
      notes: json['notes'],
      customHabits: Map<String, bool>.from(jsonDecode(json['custom_habits'] ?? '{}')),
      workouts: (jsonDecode(json['workout_details'] ?? '[]') as List)
          .map((e) => WorkoutSession.fromJson(e))
          .toList(),
      sleepHours: (json['sleep_hours'] as num?)?.toDouble() ?? 0.0,
      demonScore: (json['demon_score'] as num?)?.toDouble() ?? 0.0,
    );
  }

  DailyLogModel copyWith({
    int? id,
    DateTime? date,
    int? waterIntake,
    bool? workoutDone,
    String? mood,
    List<String>? photoPaths,
    String? notes,
    Map<String, bool>? customHabits,
    List<WorkoutSession>? workouts,
    double? sleepHours,
    double? demonScore,
  }) {
    return DailyLogModel(
      id: id ?? this.id,
      date: date ?? this.date,
      waterIntake: waterIntake ?? this.waterIntake,
      workoutDone: workoutDone ?? this.workoutDone,
      mood: mood ?? this.mood,
      photoPaths: photoPaths ?? this.photoPaths,
      notes: notes ?? this.notes,
      customHabits: customHabits ?? this.customHabits,
      workouts: workouts ?? this.workouts,
      sleepHours: sleepHours ?? this.sleepHours,
      demonScore: demonScore ?? this.demonScore,
    );
  }
}
