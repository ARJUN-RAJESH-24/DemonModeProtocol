import 'dart:convert';

class DailyLogModel {
  final int? id;
  final DateTime date;
  final int waterIntake;
  final bool workoutDone;
  final String mood;
  final List<String> photoPaths;
  final String? notes; // Zen Mode thoughts

  DailyLogModel({
    this.id,
    required this.date,
    this.waterIntake = 0,
    this.workoutDone = false,
    this.mood = 'Neutral',
    this.photoPaths = const [],
    this.notes,
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
  }) {
    return DailyLogModel(
      id: id ?? this.id,
      date: date ?? this.date,
      waterIntake: waterIntake ?? this.waterIntake,
      workoutDone: workoutDone ?? this.workoutDone,
      mood: mood ?? this.mood,
      photoPaths: photoPaths ?? this.photoPaths,
      notes: notes ?? this.notes,
    );
  }
}
