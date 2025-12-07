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

    return await openDatabase(
      path,
      version: 1,
      password: password,
      onCreate: _createDB,
      onOpen: (db) async {
         try {
           await db.execute("ALTER TABLE daily_logs ADD COLUMN notes TEXT");
         } catch (_) { }
      }
    );
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
    const blobType = 'BLOB'; // For small data or if needed later

    await db.execute('''
      CREATE TABLE daily_logs (
        id $idType,
        date $textType,
        water_intake $intType,
        workout_done $intType,
        mood $textType,
        photo_paths $textType,
        notes TEXT,
        updated_at $textType
      )
    ''');
    
    // Future expansion: Workout details, etc.
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
