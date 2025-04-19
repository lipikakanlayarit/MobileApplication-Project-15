import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;
  
  factory DatabaseHelper() => _instance;
  
  DatabaseHelper._internal();
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    String dbPath = join(await getDatabasesPath(), 'app_database.db');
    return await openDatabase(
      dbPath,
      version: 4, 
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE users ADD COLUMN isCurrentUser INTEGER DEFAULT 0');
    }
    
    if (oldVersion < 3) {
      try {
        await db.execute('ALTER TABLE users ADD COLUMN dateOfBirth TEXT');
      } catch (e) {
        print("Error adding dateOfBirth column: $e");
      }
      
      try {
        await db.execute('ALTER TABLE users ADD COLUMN phoneNumber TEXT');
      } catch (e) {
        print("Error adding phoneNumber column: $e");
      }
      
      try {
        await db.execute('ALTER TABLE users ADD COLUMN profileImagePath TEXT');
      } catch (e) {
        print("Error adding profileImagePath column: $e");
      }
    }
  }
    
  Future _onCreate(Database db, int version) async {
    // Create users table
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        dateOfBirth TEXT,
        phoneNumber TEXT,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        profileImagePath TEXT,
        isCurrentUser INTEGER DEFAULT 0
      )
    ''');
  }
  // User methods (existing)
  Future<bool> checkUserCredentials(String email, String password) async {
    Database db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
      limit: 1,
    );
    
    if (results.isNotEmpty) {
      await setCurrentUser(email);
      return true;
    }
    return false;
  }
  
  Future<void> setCurrentUser(String email) async {
    try {
      final db = await database;
      await db.update('users', {'isCurrentUser': 0}); // reset all
      await db.update('users', {'isCurrentUser': 1}, where: 'email = ?', whereArgs: [email]);
    } catch (e) {
      print("Error setting current user: $e");
    }
  }
  
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      Database db = await database;
      try {
        List<Map<String, dynamic>> result = await db.query(
          'users',
          where: 'isCurrentUser = ?',
          whereArgs: [1],
        );
        
        if (result.isNotEmpty) {
          return result.first;
        }
      } catch (e) {
        print("Could not query by isCurrentUser: $e");
      }
      
      List<Map<String, dynamic>> allUsers = await db.query('users', limit: 1);
      if (allUsers.isNotEmpty) {
        return allUsers.first;
      }
      return {};
    } catch (e) {
      print("Database error: $e");
      return {};
    }
  }
  
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }
  
  Future<void> updateUserData(Map<String, dynamic> userData) async {
    Database db = await database;
 
    final currentUser = await getUserData();
    if (currentUser != null) {
      await db.update(
        'users',
        userData,
        where: 'id = ?',
        whereArgs: [currentUser['id']],
      );
    }
  }
  
  Future<int> insertUser(Map<String, dynamic> userData) async {
    final db = await database;
    
    final existingUser = await getUserByEmail(userData['email']);
    if (existingUser != null) {
      throw Exception('User with this email already exists');
    }
    
    final formattedData = {
      'username': userData['username'],
      'dateOfBirth': userData['dateOfBirth'],
      'phoneNumber': userData['phoneNumber'],
      'email': userData['email'],
      'password': userData['password'],
      'isCurrentUser': 1,
    };
    
    await db.update('users', {'isCurrentUser': 0});
    
    return await db.insert('users', formattedData);
  }
  
  Future<void> updateUserProfileImage(String imagePath) async {
    final db = await database;
    final currentUser = await getUserData();
    
    if (currentUser != null) {
      await db.update(
        'users',
        {'profileImagePath': imagePath},
        where: 'id = ?',
        whereArgs: [currentUser['id']],
      );
    }
  }
  
  Future<void> deleteUserProfileImage() async {
    final db = await database;
    final currentUser = await getUserData();
    
    if (currentUser != null) {
      await db.update(
        'users',
        {'profileImagePath': null},
        where: 'id = ?',
        whereArgs: [currentUser['id']],
      );
    }
  }
  
  Future<String?> getUserProfileImage() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      columns: ['profileImagePath'],
      where: 'id = ?',
      whereArgs: [1],
    );
    
    if (result.isNotEmpty) {
      return result.first['profileImagePath'] as String?;
    }
    return null;
  }
  
  Future<void> ensureProfileImagePathColumn() async {
    try {
      Database db = await database;
      await db.execute('ALTER TABLE users ADD COLUMN profileImagePath TEXT');
      print("Added profileImagePath column");
    } catch (e) {
      print("profileImagePath check: $e");
    }
  }

}