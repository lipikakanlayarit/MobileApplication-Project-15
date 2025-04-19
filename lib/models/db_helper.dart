import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'dart:async';
import 'dart:convert';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;
  static final _lock = Object();

  Future<Database> get database async {
    if (_database != null && _database!.isOpen) return _database!;
    
    // Use simpler locking approach
    if (_database == null || !_database!.isOpen) {
      _database = await _initDatabase();
    }
    
    return _database!;
  }


  Future<Database> _initDatabase() async {
    String path = p.join(await getDatabasesPath(), 'chat_app.db');
    
    // Make sure to open with readOnly: false explicitly
    return await openDatabase(
      path, 
      version: 1, 
      onCreate: _onCreate,
      readOnly: false,
      singleInstance: true // Ensure only one connection
    );
  }
  Future<void> resetDatabase() async {
    if (_database != null) {
      try {
        await _database!.close();
      } catch (e) {
        print('Error closing database: $e');
      }
      _database = null;
    }
  }
  
  Future _onCreate(Database db, int version) async {
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
    await db.execute('''
      CREATE TABLE daily_message_stats (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      date TEXT NOT NULL,
      message_count INTEGER NOT NULL,
      emoji_usage TEXT,
      created_at TEXT NOT NULL
    )
  ''');
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
    // Get a fresh database connection for this operation
    Database db = await database;
    try {
      int result = await db.delete('messages', where: 'id = ?', whereArgs: [id]);
      await db.close(); // Important: close this connection when done
      return result;
    } catch (e) {
      print('Error deleting message: $e');
      await db.close(); // Make sure to close even on error
      rethrow;
    }
  }

Future<int> clearAllMessages() async {
    // Get a fresh database connection for this operation
    Database db = await database;
    try {
      int result = await db.delete('messages');
      await db.close(); // Important: close this connection when done
      return result;
    } catch (e) {
      print('Error clearing messages: $e');
      await db.close(); // Make sure to close even on error
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getMessagesForToday() async {
    Database db = await database;

    // Create current date in YYYY-MM-DD format
    final DateTime now = DateTime.now();
    final String todayStart = DateTime(now.year, now.month, now.day).toIso8601String();
    final String todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59, 999).toIso8601String();

    return await db.query(
      'messages',
      where: 'timestamp BETWEEN ? AND ?',
      whereArgs: [todayStart, todayEnd],
      orderBy: 'timestamp ASC',
    );
  }
  
  Future<List<Map<String, dynamic>>> getMessagesBetween(
    DateTime startDate,
    DateTime endDate,
  ) async {
    Database db = await database;
    final startDateStr = startDate.toIso8601String();
    final endDateStr = endDate.toIso8601String();

    return await db.query(
      'messages',
      where: "timestamp >= ? AND timestamp <= ?",
      whereArgs: [startDateStr, endDateStr],
      orderBy: 'timestamp ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getMessagesForDate(DateTime date) async {
    final startOfDay =
        DateTime(date.year, date.month, date.day).toIso8601String();
    final startOfNextDay =
        DateTime(date.year, date.month, date.day + 1).toIso8601String();

    Database db = await database;
    return await db.query(
      'messages',
      where: "timestamp >= ? AND timestamp < ?",
      whereArgs: [startOfDay, startOfNextDay],
      orderBy: 'timestamp ASC',
    );
  }

  Future<void> archiveAndClearOldMessages() async {
    final db = await database;
    final now = DateTime.now();

    // กำหนดช่วงของ "เมื่อวาน"
    final yesterdayStart = DateTime(now.year, now.month, now.day - 1);
    final yesterdayEnd = DateTime(now.year, now.month, now.day, 0, 0, 0, 0);

    final startStr = yesterdayStart.toIso8601String();
    final endStr = yesterdayEnd.toIso8601String();

    // ดึงข้อความเมื่อวาน
    final yesterdayMessages = await db.query(
      'messages',
      where: 'timestamp >= ? AND timestamp < ?',
      whereArgs: [startStr, endStr],
    );

    if (yesterdayMessages.isNotEmpty) {
      final messageCount = yesterdayMessages.length;

      // ตัวอย่างนับ emoji แบบง่าย
      final Map<String, int> emojiCount = {};
      for (var msg in yesterdayMessages) {
        final emoji = msg['emoji_path'] as String? ?? '';
        if (emoji.isNotEmpty) {
          emojiCount[emoji] = (emojiCount[emoji] ?? 0) + 1;
        }
      }

      // เก็บสถิติลงตาราง
      await db.insert('daily_message_stats', {
        'date': startStr.split('T').first,
        'message_count': messageCount,
        'emoji_usage': jsonEncode(emojiCount),
        'created_at': DateTime.now().toIso8601String(),
      });

      // ลบข้อความเมื่อวานออก
      await db.delete(
        'messages',
        where: 'timestamp >= ? AND timestamp < ?',
        whereArgs: [startStr, endStr],
      );
    }
  }
  
}
