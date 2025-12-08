import 'dart:convert';
import 'dart:math';
import 'package:path/path.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;
  final _storage = const FlutterSecureStorage();

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('demon_mode.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    final password = await _getEncryptionKey();

    try {
      return await openDatabase(
        path,
        version: 7,
        password: password,
        onCreate: _createDB,
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            try {
              await db.execute("ALTER TABLE daily_logs ADD COLUMN custom_habits TEXT");
            } catch (_) {}
          }
          if (oldVersion < 3) {
            // Version 3: Full V2.0 Schema
            await _createV2Tables(db);
          }
          if (oldVersion < 4) {
             try {
              await db.execute("ALTER TABLE daily_logs ADD COLUMN workout_details TEXT");
            } catch (_) {}
          }
           if (oldVersion < 5) {
             try {
              await db.execute("ALTER TABLE daily_logs ADD COLUMN sleep_hours REAL DEFAULT 0");
              await db.execute("ALTER TABLE daily_logs ADD COLUMN demon_score REAL DEFAULT 0");
            } catch (_) {}
          }
           if (oldVersion < 6) {
             try {
              await db.execute("ALTER TABLE daily_logs ADD COLUMN coffee_intake INTEGER DEFAULT 0");
              await db.execute("ALTER TABLE daily_logs ADD COLUMN mood_score INTEGER DEFAULT 50");
              await db.execute("ALTER TABLE daily_logs ADD COLUMN journal_entry TEXT");
              await db.execute("ALTER TABLE daily_logs ADD COLUMN supplements TEXT");
            } catch (_) {}
          }
           if (oldVersion < 7) {
             try {
              await db.execute("ALTER TABLE daily_logs ADD COLUMN steps INTEGER DEFAULT 0");
            } catch (_) {}
          }
        },
      );
    } catch (e) {
      // If DB is corrupted or password wrong, delete and recreate
      print("Database corruption detected ($e). Deleting and recreating...");
      await deleteDatabase(path);
      return await openDatabase(
        path,
        version: 7,
        password: password,
        onCreate: _createDB,
        onUpgrade: (_, __, ___) {},
      );
    }
  }

  Future<String> _getEncryptionKey() async {
    String? key = await _storage.read(key: 'db_key');
    if (key == null) {
      final random = Random.secure();
      final values = List<int>.generate(32, (i) => random.nextInt(256));
      key = base64UrlEncode(values);
      await _storage.write(key: 'db_key', value: key);
    }
    return key;
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const blobType = 'BLOB';

    await db.execute('''
      CREATE TABLE daily_logs (
        id $idType,
        date $textType,
        water_intake $intType,
        coffee_intake INTEGER DEFAULT 0,
        workout_done $intType,
        mood $textType,
        mood_score INTEGER DEFAULT 50,
        photo_paths $textType,
        notes TEXT,
        journal_entry TEXT,
        custom_habits TEXT,
        supplements TEXT,
        workout_details TEXT,
        sleep_hours REAL DEFAULT 0,
        demon_score REAL DEFAULT 0,
        steps INTEGER DEFAULT 0,
        updated_at $textType
      )
    ''');
    
    await _createV2Tables(db);
  }

  Future<void> _createV2Tables(Database db) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textNullable = 'TEXT';
    const intType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL';
    const boolType = 'INTEGER NOT NULL DEFAULT 0'; // 0 or 1

    // Nutrition
    await db.execute('''
      CREATE TABLE IF NOT EXISTS foods (
        id $idType,
        name $textType,
        brand $textNullable,
        kcal $realType,
        protein $realType,
        carbs $realType,
        fats $realType,
        fiber $realType,
        sodium $realType,
        serving_unit $textType,
        serving_quantity $realType,
        is_custom $boolType
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS meal_logs (
        id $idType,
        date $textType, -- YYYY-MM-DD
        meal_type $textType, -- Breakfast, Lunch, Dinner, Snack
        food_id $intType,
        serving_multiplier $realType,
        created_at $textType,
        FOREIGN KEY(food_id) REFERENCES foods(id)
      )
    ''');

    // Body Metrics
    await db.execute('''
      CREATE TABLE IF NOT EXISTS body_metrics (
        id $idType,
        date $textType,
        weight $realType,
        body_fat $realType,
        waist $realType,
        neck $realType,
        chest $realType,
        arms $realType,
        legs $realType,
        photo_path $textNullable
      )
    ''');

    // Detailed Habits & Demon Score
    await db.execute('''
      CREATE TABLE IF NOT EXISTS user_habits (
        id $idType,
        date $textType,
        no_sugar $boolType,
        no_oil $boolType,
        creatine $boolType,
        chia_seeds $boolType,
        morning_run $boolType,
        evening_gym $boolType,
        sleep_time $textNullable,
        is_perfect_day $boolType,
        demon_score $realType
      )
    ''');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
