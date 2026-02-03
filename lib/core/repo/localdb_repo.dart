import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:hrm/core/model/login_model.dart';
import 'package:logger/logger.dart';

class LocalDBrepostiory {
  static final LocalDBrepostiory _instance = LocalDBrepostiory._internal();
  static Database? _database;
  final log = Logger();

  factory LocalDBrepostiory() {
    return _instance;
  }

  LocalDBrepostiory._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'hrm_database.db');

    log.d('Initializing database at: $path');

    return await openDatabase(
      path,
      version: 2, // Incremented version for new columns
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    log.d('Creating database tables...');

    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        username TEXT NOT NULL,
        employee_id INTEGER NOT NULL,
        user_role TEXT NOT NULL,
        company_id INTEGER NOT NULL,
        email_id TEXT NOT NULL,
        access_token TEXT NOT NULL,
        token_type TEXT NOT NULL,
        is_logged_in INTEGER DEFAULT 1,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    log.d('Database tables created successfully');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    log.d('Upgrading database from version $oldVersion to $newVersion');

    if (oldVersion < 2) {
      // Add is_logged_in column if upgrading from version 1
      await db.execute(
        'ALTER TABLE users ADD COLUMN is_logged_in INTEGER DEFAULT 1',
      );
      log.d('Added is_logged_in column to users table');
    }
  }

  /// Save user login data to SQLite
  /// Replaces any existing user data (single user session)
  Future<int> saveUser(LoginData loginData) async {
    try {
      final db = await database;

      // Clear existing user data (single session)
      await db.delete('users');

      // Insert new user data with logged in status
      final userData = loginData.toMap();
      userData['is_logged_in'] = 1; // Set logged in to true

      final id = await db.insert(
        'users',
        userData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      log.d('User saved to database with id: $id');
      return id;
    } catch (e) {
      log.e('Error saving user to database: $e');
      rethrow;
    }
  }

  /// Get the current logged-in user
  Future<LoginData?> getUser() async {
    try {
      final db = await database;

      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'is_logged_in = ?',
        whereArgs: [1],
        orderBy: 'id DESC',
        limit: 1,
      );

      if (maps.isEmpty) {
        log.d('No user found in database');
        return null;
      }

      log.d('User retrieved from database');
      return LoginData.fromMap(maps.first);
    } catch (e) {
      log.e('Error getting user from database: $e');
      return null;
    }
  }

  /// Save token separately (optional, token is also saved with user data)
  Future<int> saveToken(String token) async {
    try {
      final db = await database;

      final count = await db.update('users', {
        'access_token': token,
        'updated_at': DateTime.now().toIso8601String(),
      }, where: 'id = (SELECT MAX(id) FROM users)');

      log.d('Token saved/updated for $count user(s)');
      return count;
    } catch (e) {
      log.e('Error saving token: $e');
      rethrow;
    }
  }

  /// Save user ID separately (optional, already saved with user data)
  Future<int> saveUserId(String userId) async {
    try {
      final db = await database;

      final count = await db.update('users', {
        'user_id': int.parse(userId),
        'updated_at': DateTime.now().toIso8601String(),
      }, where: 'id = (SELECT MAX(id) FROM users)');

      log.d('User ID updated for $count user(s)');
      return count;
    } catch (e) {
      log.e('Error saving user ID: $e');
      rethrow;
    }
  }

  /// Set logged in status
  Future<int> setLoggedIn(bool isLoggedIn) async {
    try {
      final db = await database;

      final count = await db.update('users', {
        'is_logged_in': isLoggedIn ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      }, where: 'id = (SELECT MAX(id) FROM users)');

      log.d('Login status set to $isLoggedIn for $count user(s)');
      return count;
    } catch (e) {
      log.e('Error setting login status: $e');
      rethrow;
    }
  }

  /// Update the access token for the current user
  Future<int> updateAccessToken(String newToken) async {
    try {
      final db = await database;

      final count = await db.update('users', {
        'access_token': newToken,
        'updated_at': DateTime.now().toIso8601String(),
      }, where: 'id = (SELECT MAX(id) FROM users)');

      log.d('Access token updated for $count user(s)');
      return count;
    } catch (e) {
      log.e('Error updating access token: $e');
      rethrow;
    }
  }

  /// Check if user is logged in (has data in database with is_logged_in = 1)
  Future<bool> isLoggedIn() async {
    try {
      final db = await database;

      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'is_logged_in = ?',
        whereArgs: [1],
        limit: 1,
      );

      return maps.isNotEmpty;
    } catch (e) {
      log.e('Error checking login status: $e');
      return false;
    }
  }

  /// Get the access token for API calls
  Future<String?> getAccessToken() async {
    try {
      final user = await getUser();
      return user?.accessToken;
    } catch (e) {
      log.e('Error getting access token: $e');
      return null;
    }
  }

  /// Get user ID
  Future<int?> getUserId() async {
    try {
      final user = await getUser();
      return user?.userId;
    } catch (e) {
      log.e('Error getting user ID: $e');
      return null;
    }
  }

  /// Get employee ID
  Future<int?> getEmployeeId() async {
    try {
      final user = await getUser();
      return user?.employeeId;
    } catch (e) {
      log.e('Error getting employee ID: $e');
      return null;
    }
  }

  /// Get company ID
  Future<int?> getCompanyId() async {
    try {
      final user = await getUser();
      return user?.companyId;
    } catch (e) {
      log.e('Error getting company ID: $e');
      return null;
    }
  }

  /// Logout user (clear all user data from database)
  Future<int> logout() async {
    try {
      final db = await database;
      final count = await db.delete('users');

      log.d('User logged out, $count record(s) deleted');
      return count;
    } catch (e) {
      log.e('Error during logout: $e');
      rethrow;
    }
  }

  /// Close database connection
  Future<void> close() async {
    try {
      final db = await database;
      await db.close();
      _database = null;
      log.d('Database connection closed');
    } catch (e) {
      log.e('Error closing database: $e');
    }
  }

  /// Clear all data (useful for testing)
  Future<void> clearAllData() async {
    try {
      final db = await database;
      await db.delete('users');
      log.d('All data cleared from database');
    } catch (e) {
      log.e('Error clearing database: $e');
    }
  }

  /// Get user info as a map (for debugging)
  Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      final db = await database;

      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        orderBy: 'id DESC',
        limit: 1,
      );

      if (maps.isEmpty) {
        return null;
      }

      return maps.first;
    } catch (e) {
      log.e('Error getting user info: $e');
      return null;
    }
  }
}
