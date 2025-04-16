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
    version: 4, // Increase from 3 to 4
    onCreate: _onCreate,
    onUpgrade: _onUpgrade,
  );
}
Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 2) {
    await db.execute('ALTER TABLE users ADD COLUMN isCurrentUser INTEGER DEFAULT 0');
  }
  
  if (oldVersion < 3) {
    // Add these lines to add the missing columns
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
    
    // Add profileImagePath column if it doesn't exist
    try {
      await db.execute('ALTER TABLE users ADD COLUMN profileImagePath TEXT');
    } catch (e) {
      print("Error adding profileImagePath column: $e");
    }
  }
}
  
  Future _onCreate(Database db, int version) async {
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
  
  Future<bool> checkUserCredentials(String email, String password) async {
    Database db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
      limit: 1,
    );
    
    if (results.isNotEmpty) {
      // Set this user as current user
      await setCurrentUser(email);
      return true;
    }
    return false;
  }
  
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    Database db = await database;
    return await db.query('users');
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
  
  Future<int> deleteUser(int id) async {
    Database db = await database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  Future<void> setCurrentUser(String email) async {
  try {
    final db = await database;
    await db.update('users', {'isCurrentUser': 0}); // reset all
    await db.update('users', {'isCurrentUser': 1}, where: 'email = ?', whereArgs: [email]);
  } catch (e) {
    print("Error setting current user: $e");
    // Continue without setting current user
  }
}
  
  Future<Map<String, dynamic>?> getUserData() async {
  try {
    Database db = await database;
    // First try to get by isCurrentUser
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
    
    // Fallback: just get the first user
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
    
    // Get current user
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
  
  // Check if user already exists
  final existingUser = await getUserByEmail(userData['email']);
  if (existingUser != null) {
    throw Exception('User with this email already exists');
  }
  
  // Format data with consistent field names
  final formattedData = {
    'username': userData['username'],
    'dateOfBirth': userData['dateOfBirth'],  // ใช้ dateOfBirth
    'phoneNumber': userData['phoneNumber'],  // ใช้ phoneNumber
    'email': userData['email'],
    'password': userData['password'],
    'isCurrentUser': 1, // Set as current user
  };
  
  // Reset current user flag for all users
  await db.update('users', {'isCurrentUser': 0});
  
  // Insert new user
  return await db.insert('users', formattedData);
}
// แก้ตรงนี้รูป

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
    final db = await _getDatabase();
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      columns: ['profileImagePath'],
      where: 'id = ?',
      whereArgs: [1],  // สมมติว่า id ของผู้ใช้คือ 1
    );
    
    if (result.isNotEmpty) {
      return result.first['profileImagePath'] as String?;
    }
    return null;
  }
  Future<Database> _getDatabase() async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  // Add this method to your DatabaseHelper class
Future<void> ensureProfileImagePathColumn() async {
  try {
    Database db = await database;
    await db.execute('ALTER TABLE users ADD COLUMN profileImagePath TEXT');
    print("Added profileImagePath column");
  } catch (e) {
    // If column already exists, SQLite will throw an error, which is fine
    print("profileImagePath check: $e");
  }
}

}