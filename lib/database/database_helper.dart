import 'dart:io';
import 'dart:typed_data';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
class DatabaseHelper {
  static const _databaseName = 'bug_identification.db';
  static const _databaseVersion = 4;
  static const table = 'bug_identification_history';
  static const columnId = 'id';
  static const columnName = 'name';
  static const columnImagePath = 'image_path';
  static const columnResult = 'result';
  static const columnTimestamp = 'timestamp';
  static const columnSpecies = 'species';
  static const columnDangerLevel = 'danger_level';
  static const columnVenomous = 'venomous';
  static const columnDiseases = 'diseases';
  static const columnHabitat = 'habitat';
  static const columnSafetyTips = 'safety_tips';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnName TEXT NOT NULL,
        $columnImagePath TEXT NOT NULL,
        $columnResult TEXT NOT NULL,
        $columnTimestamp INTEGER NOT NULL,
        $columnSpecies TEXT,
        $columnDangerLevel TEXT,
        $columnVenomous TEXT,
        $columnDiseases TEXT,
        $columnHabitat TEXT,
        $columnSafetyTips TEXT
      )
    ''');

  }
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE ${table}_new (
          $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
          $columnName TEXT NOT NULL,
          $columnImagePath TEXT NOT NULL,
          $columnResult TEXT NOT NULL,
          $columnTimestamp INTEGER NOT NULL,
          $columnSpecies TEXT,
          $columnDangerLevel TEXT
        )
      ''');
      await db.execute('''
        INSERT INTO ${table}_new 
        SELECT $columnId, $columnName, '', $columnResult, $columnTimestamp, $columnSpecies, $columnDangerLevel
        FROM $table
      ''');
      await db.execute('DROP TABLE $table');
      await db.execute('ALTER TABLE ${table}_new RENAME TO $table');
    }
    if (oldVersion < 3) {
      // Venom and disease fields
      await db.execute('ALTER TABLE $table ADD COLUMN $columnVenomous TEXT');
      await db.execute('ALTER TABLE $table ADD COLUMN $columnDiseases TEXT');
    }
    if (oldVersion < 4) {
      // Habitat and safety tips fields
      await db.execute('ALTER TABLE $table ADD COLUMN $columnHabitat TEXT');
      await db.execute('ALTER TABLE $table ADD COLUMN $columnSafetyTips TEXT');
    }
  }
  Future<int> insertIdentification(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert(table, row);
  }
  Future<List<Map<String, dynamic>>> getAllIdentifications() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      table,
      orderBy: '$columnTimestamp DESC',
    );
    return maps;
  }

  Future<List<Map<String, dynamic>>> getRecentIdentifications(int limit) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      table,
      orderBy: '$columnTimestamp DESC',
      limit: limit,
    );
    return maps;
  }
  Future<Map<String, dynamic>?> getIdentification(int id) async {
    final db = await instance.database;
    final results = await db.query(
      table,
      where: '$columnId = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }
  Future<void> deleteIdentification(int id) async {
    final db = await instance.database;
    await db.delete(
      table,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }
  Future<Uint8List?> getIdentificationImage(int id) async {
    final identification = await getIdentification(id);
    if (identification != null) {
      final imagePath = identification[columnImagePath] as String?;
      if (imagePath != null) {
        final file = File(imagePath);
        if (await file.exists()) {
          return await file.readAsBytes();
        }
      }
    }
    return null;
  }
  Future<void> clearAllData() async {
    final db = await instance.database;
    await db.delete(table);
  }
} 

