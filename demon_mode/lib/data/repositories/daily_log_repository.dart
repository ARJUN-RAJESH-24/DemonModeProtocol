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
}

