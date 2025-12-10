import '../database/database_service.dart';
import '../models/daily_log_model.dart';

class DailyLogRepository {
  final DatabaseService _dbService = DatabaseService.instance;

  Future<DailyLogModel> getLogForDate(DateTime date) async {
    final db = await _dbService.database;
    // Format date to YYYY-MM-DD to query
    final dateStr = date.toIso8601String().split('T')[0];
    
    // We search for logs that start with this date string
    final result = await db.query(
      'daily_logs',
      where: 'date LIKE ?',
      whereArgs: ['$dateStr%'],
    );

    if (result.isNotEmpty) {
      return DailyLogModel.fromJson(result.first);
    } else {
      // Return a fresh empty log for today if none exists
      return DailyLogModel(date: date);
    }
  }

  Future<void> saveLog(DailyLogModel log) async {
    final db = await _dbService.database;
    
    // Check if log exists
    if (log.id != null) {
      await db.update(
        'daily_logs',
        log.toJson(),
        where: 'id = ?',
        whereArgs: [log.id],
      );
    } else {
      // If no ID, check if we already have a log for this date to avoid dupes (double safety)
      final existing = await getLogForDate(log.date);
      if (existing.id != null) {
         await db.update(
          'daily_logs',
          log.copyWith(id: existing.id).toJson(),
          where: 'id = ?',
          whereArgs: [existing.id],
        );
      } else {
        await db.insert('daily_logs', log.toJson());
      }
    }
  }
  Future<List<DailyLogModel>> getAllLogs() async {
    final db = await _dbService.database;
    final result = await db.query('daily_logs');
    return result.map((e) => DailyLogModel.fromJson(e)).toList();
  }

  Future<double> getDailyCalories(DateTime date) async {
    final db = await _dbService.database;
    final dateStr = date.toIso8601String().split('T')[0];
    
    final result = await db.rawQuery('''
      SELECT SUM(f.kcal * m.serving_multiplier) as total_kcal
      FROM meal_logs m
      JOIN foods f ON m.food_id = f.id
      WHERE m.date = ?
    ''', [dateStr]);

    if (result.isNotEmpty && result.first['total_kcal'] != null) {
      return (result.first['total_kcal'] as num).toDouble();
    }
    return 0.0;
  }

  Future<List<Map<String, dynamic>>> getMealsForDate(DateTime date) async {
    final db = await _dbService.database;
    final dateStr = date.toIso8601String().split('T')[0];
    
    return await db.rawQuery('''
      SELECT m.*, f.name as food_name, f.kcal, f.protein, f.carbs, f.fats 
      FROM meal_logs m
      JOIN foods f ON m.food_id = f.id
      WHERE m.date = ?
    ''', [dateStr]);
  }

  Future<List<Map<String, dynamic>>> getBodyMetricsForDate(DateTime date) async {
    final db = await _dbService.database;
    final dateStr = date.toIso8601String().split('T')[0];
    
    return await db.query(
      'body_metrics',
      where: 'date = ?',
      whereArgs: [dateStr],
    );
  }
}

