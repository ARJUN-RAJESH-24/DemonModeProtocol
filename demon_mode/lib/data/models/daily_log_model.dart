import 'dart:convert';

class DailyLogModel {
  final int? id;
  final DateTime date;
  final int waterIntake;
  final bool workoutDone;
  final String mood;
  final List<String> photoPaths;
  final String? notes; // Zen Mode thoughts
  final Map<String, bool> customHabits;

  DailyLogModel({
    this.id,
    required this.date,
    this.waterIntake = 0,
    this.workoutDone = false,
    this.mood = 'Neutral',
    this.photoPaths = const [],
    this.notes,
    this.customHabits = const {},
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
    );
  }
}
