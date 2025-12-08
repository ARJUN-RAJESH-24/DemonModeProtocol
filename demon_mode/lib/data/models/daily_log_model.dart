import 'dart:convert';
import 'workout_model.dart';

class DailyLogModel {
  final int? id;
  final DateTime date;
  final int waterIntake; // in ml
  final int coffeeIntake; // cups
  final bool workoutDone;
  final String mood;
  final int moodScore; // 1-100
  final List<String> photoPaths;
  final String? notes; // Zen Mode thoughts
  final String? journalEntry; // "What I Conquered Today"
  final Map<String, bool> customHabits;
  final List<String> supplements;
  final List<WorkoutSession> workouts;
  final double sleepHours;
  final double demonScore;

  DailyLogModel({
    this.id,
    required this.date,
    this.waterIntake = 0,
    this.coffeeIntake = 0,
    this.workoutDone = false,
    this.mood = 'Neutral',
    this.moodScore = 50,
    this.photoPaths = const [],
    this.notes,
    this.journalEntry,
    this.customHabits = const {},
    this.supplements = const [],
    this.workouts = const [],
    this.sleepHours = 0.0,
    this.demonScore = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'water_intake': waterIntake,
      'coffee_intake': coffeeIntake,
      'workout_done': workoutDone ? 1 : 0,
      'mood': mood,
      'mood_score': moodScore,
      'photo_paths': jsonEncode(photoPaths),
      'notes': notes,
      'journal_entry': journalEntry,
      'custom_habits': jsonEncode(customHabits),
      'supplements': jsonEncode(supplements),
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
      coffeeIntake: json['coffee_intake'] ?? 0,
      workoutDone: json['workout_done'] == 1,
      mood: json['mood'] ?? 'Neutral',
      moodScore: json['mood_score'] ?? 50,
      photoPaths: List<String>.from(jsonDecode(json['photo_paths'] ?? '[]')),
      notes: json['notes'],
      journalEntry: json['journal_entry'],
      customHabits: Map<String, bool>.from(jsonDecode(json['custom_habits'] ?? '{}')),
      supplements: List<String>.from(jsonDecode(json['supplements'] ?? '[]')),
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
    int? coffeeIntake,
    bool? workoutDone,
    String? mood,
    int? moodScore,
    List<String>? photoPaths,
    String? notes,
    String? journalEntry,
    Map<String, bool>? customHabits,
    List<String>? supplements,
    List<WorkoutSession>? workouts,
    double? sleepHours,
    double? demonScore,
  }) {
    return DailyLogModel(
      id: id ?? this.id,
      date: date ?? this.date,
      waterIntake: waterIntake ?? this.waterIntake,
      coffeeIntake: coffeeIntake ?? this.coffeeIntake,
      workoutDone: workoutDone ?? this.workoutDone,
      mood: mood ?? this.mood,
      moodScore: moodScore ?? this.moodScore,
      photoPaths: photoPaths ?? this.photoPaths,
      notes: notes ?? this.notes,
      journalEntry: journalEntry ?? this.journalEntry,
      customHabits: customHabits ?? this.customHabits,
      supplements: supplements ?? this.supplements,
      workouts: workouts ?? this.workouts,
      sleepHours: sleepHours ?? this.sleepHours,
      demonScore: demonScore ?? this.demonScore,
    );
  }
}
