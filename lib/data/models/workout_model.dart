import 'dart:convert';

class WorkoutSet {
  final int reps;
  final double weight;
  
  WorkoutSet({required this.reps, required this.weight});

  Map<String, dynamic> toJson() => {'reps': reps, 'weight': weight};
  factory WorkoutSet.fromJson(Map<String, dynamic> json) => 
      WorkoutSet(reps: json['reps'], weight: (json['weight'] as num).toDouble());
}

class WorkoutExercise {
  final String name;
  final List<WorkoutSet> sets;

  WorkoutExercise({required this.name, required this.sets});

  Map<String, dynamic> toJson() => {
    'name': name,
    'sets': sets.map((s) => s.toJson()).toList(),
  };

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) => WorkoutExercise(
    name: json['name'],
    sets: (json['sets'] as List).map((s) => WorkoutSet.fromJson(s)).toList(),
  );
}

class WorkoutSession {
  final DateTime date;
  final int durationSeconds;
  final List<WorkoutExercise> exercises;

  WorkoutSession({required this.date, required this.durationSeconds, required this.exercises});

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'duration': durationSeconds,
    'exercises': exercises.map((e) => e.toJson()).toList(),
  };

  factory WorkoutSession.fromJson(Map<String, dynamic> json) => WorkoutSession(
    date: DateTime.parse(json['date']),
    durationSeconds: json['duration'],
    exercises: (json['exercises'] as List).map((e) => WorkoutExercise.fromJson(e)).toList(),
  );
}
