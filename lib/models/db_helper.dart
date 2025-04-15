import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'dart:async';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Use p.join instead of join to avoid conflicts
    String path = p.join(await getDatabasesPath(), 'chat_app.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    // Create users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        password TEXT NOT NULL,
        date_of_birth TEXT,
        phone TEXT,
        email TEXT
      )
    ''');

    // Create messages table
    await db.execute('''
      CREATE TABLE messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        text TEXT NOT NULL,
        emoji_path TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        is_user_message TEXT NOT NULL,
        user_id INTEGER,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
  }

  // User operations
  Future<int> insertUser(Map<String, dynamic> user) async {
    Database db = await database;
    return await db.insert('users', user);
  }

  Future<Map<String, dynamic>?> getUser(
    String username,
    String password,
  ) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<bool> checkUserExists(String username) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    return result.isNotEmpty;
  }

  Future<int> updateUser(Map<String, dynamic> user) async {
    Database db = await database;
    return await db.update(
      'users',
      user,
      where: 'id = ?',
      whereArgs: [user['id']],
    );
  }

  // Message operations
  Future<int> insertMessage(Map<String, dynamic> message) async {
    Database db = await database;
    return await db.insert('messages', message);
  }

  Future<List<Map<String, dynamic>>> getMessages() async {
    Database db = await database;
    return await db.query('messages', orderBy: 'timestamp ASC');
  }

  Future<int> deleteMessage(int id) async {
    Database db = await database;
    return await db.delete('messages', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> clearAllMessages() async {
    Database db = await database;
    return await db.delete('messages');
  }

  Future<List<Map<String, dynamic>>> getMessagesForToday() async {
    Database db = await database;

    // สร้างวันที่ปัจจุบันในรูปแบบ YYYY-MM-DD (ต้นวัน)
    final DateTime now = DateTime.now();
    final String todayStart =
        DateTime(now.year, now.month, now.day).toIso8601String();
    final String todayEnd =
        DateTime(
          now.year,
          now.month,
          now.day,
          23,
          59,
          59,
          999,
        ).toIso8601String();

    // ดึงข้อความในวันปัจจุบัน
    return await db.query(
      'messages',
      where: 'timestamp BETWEEN ? AND ?',
      whereArgs: [todayStart, todayEnd],
      orderBy: 'timestamp ASC',
    );
  }
}
