import '../../data/models/daily_log_model.dart';
import '../../data/repositories/daily_log_repository.dart';

class DemonScoreLogic {
  static Future<double> calculate(DailyLogModel log) async {
    final DailyLogRepository repo = DailyLogRepository();
    double score = 0.0;

    // 1. Workout (2.0)
    bool workoutDone = log.workoutDone || log.workouts.isNotEmpty;
    if (workoutDone) score += 2.0;

    // 2. Nutrition & Hydration (1.5)
    double calories = await repo.getDailyCalories(log.date);
    bool nourished = calories >= 1800;
    bool hydrated = log.waterIntake >= 3000;
    
    if (nourished) score += 1.0;
    if (hydrated) score += 0.5;

    // 3. Habits (2.0)
    if (log.customHabits.isNotEmpty) {
      int completed = log.customHabits.values.where((e) => e).length;
      score += (completed / log.customHabits.length) * 2.0;
    } else {
      score += 2.0; // Default if no habits
    }

    // 4. Sleep (1.5)
    if (log.sleepHours >= 8) {
      score += 1.5;
    } else if (log.sleepHours >= 6) {
      score += 0.75;
    }

    // 5. Journaling (1.5)
    if (log.journalEntry != null && log.journalEntry!.isNotEmpty) {
      score += 1.5;
    }

    // 6. Supplements (1.5)
    if (log.supplements.isNotEmpty) {
      score += 1.5;
    }
    
    // Cap at 10.0 (just in case)
    if (score > 10.0) score = 10.0;

    return score;
  }
}
