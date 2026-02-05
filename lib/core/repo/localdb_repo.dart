import 'package:hrm/core/model/attances_model.dart';
import 'package:hrm/core/model/login_model.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:logger/logger.dart';

class LocalDBRepository {
  static final LocalDBRepository _instance = LocalDBRepository._internal();
  static Database? _database;

  final Logger log = Logger();

  factory LocalDBRepository() => _instance;
  LocalDBRepository._internal();

  // ───────────────── DB INIT ─────────────────
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'hrm.db');

    return openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // ───────────────── CREATE ─────────────────
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        username TEXT,
        employee_id INTEGER,
        company_id INTEGER,
        user_role TEXT,
        email_id TEXT,
        access_token TEXT,
        token_type TEXT,
        is_logged_in INTEGER DEFAULT 1,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE attendance(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        employee_id TEXT,
        attendance_date TEXT,

        checkin_time TEXT,
        checkin_latitude REAL,
        checkin_longitude REAL,
        checkin_image TEXT,

        checkout_time TEXT,
        checkout_latitude REAL,
        checkout_longitude REAL,
        checkout_image TEXT,

        status TEXT,
        created_at TEXT,
        updated_at TEXT,
        
        UNIQUE(employee_id, attendance_date)
      )
    ''');

    log.i('✅ Database created');
  }

  // ───────────────── MIGRATION ─────────────────
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    log.i('⬆️ DB upgrade $oldVersion → $newVersion');

    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE users ADD COLUMN is_logged_in INTEGER DEFAULT 1',
      );
    }

    if (oldVersion < 3) {
      await db.execute(
        'ALTER TABLE users ADD COLUMN created_at TEXT',
      );
      await db.execute(
        'ALTER TABLE users ADD COLUMN updated_at TEXT',
      );
    }

    if (oldVersion < 4) {
      await db.execute(
        'ALTER TABLE users ADD COLUMN user_role TEXT',
      );
      await db.execute(
        'ALTER TABLE users ADD COLUMN email_id TEXT',
      );
      await db.execute(
        'ALTER TABLE users ADD COLUMN token_type TEXT',
      );
      await db.execute(
        'ALTER TABLE attendance ADD COLUMN created_at TEXT',
      );
      await db.execute(
        'ALTER TABLE attendance ADD COLUMN updated_at TEXT',
      );
    }
  }

  // ═══════════════════════════════════════════════════════════
  // USER METHODS
  // ═══════════════════════════════════════════════════════════

  Future<int> saveUser(LoginData loginData) async {
    final db = await database;

    await db.delete('users');

    final data = loginData.toJson()
      ..['is_logged_in'] = 1
      ..['created_at'] = DateTime.now().toIso8601String()
      ..['updated_at'] = DateTime.now().toIso8601String();

    final id = await db.insert(
      'users',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    log.i('✅ User saved (id=$id)');
    return id;
  }

  Future<LoginData?> getUser() async {
    final db = await database;

    final rows = await db.query(
      'users',
      where: 'is_logged_in = ?',
      whereArgs: [1],
      orderBy: 'id DESC',
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return LoginData.fromJson(rows.first);
  }

  Future<bool> isLoggedIn() async {
    final db = await database;

    final rows = await db.query(
      'users',
      where: 'is_logged_in = 1',
      limit: 1,
    );

    return rows.isNotEmpty;
  }

  Future<int> logout() async {
    final db = await database;
    final count = await db.delete('users');
    log.i('🚪 Logged out');
    return count;
  }

  // ───────────────── TOKEN ─────────────────

  Future<void> updateAccessToken(String token) async {
    final db = await database;

    await db.update(
      'users',
      {
        'access_token': token,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = (SELECT MAX(id) FROM users)',
    );
  }

  Future<String?> getAccessToken() async {
    final user = await getUser();
    return user?.accessToken;
  }

  // ───────────────── USER HELPERS ─────────────────

  Future<int?> getEmployeeId() async {
    final user = await getUser();
    return user?.employeeId;
  }

  Future<int?> getUserId() async {
    final user = await getUser();
    return user?.userId;
  }

  Future<int?> getCompanyId() async {
    final user = await getUser();
    return user?.companyId;
  }

  // ═══════════════════════════════════════════════════════════
  // ATTENDANCE METHODS
  // ═══════════════════════════════════════════════════════════

  /// Save attendance record (insert or replace)
  Future<int> save(AttendanceModel model) async {
    try {
      final db = await database;

      final data = model.toJson()
        ..['created_at'] = DateTime.now().toIso8601String()
        ..['updated_at'] = DateTime.now().toIso8601String();

      final id = await db.insert(
        'attendance',
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      log.i('✅ Attendance saved (id=$id)');
      return id;
    } catch (e) {
      log.e('Failed to save attendance', error: e);
      rethrow;
    }
  }

  /// Update existing attendance record
  Future<int> update(AttendanceModel attendance) async {
    try {
      final db = await database;

      final data = attendance.toJson()
        ..['updated_at'] = DateTime.now().toIso8601String();

      final count = await db.update(
        'attendance',
        data,
        where: 'employee_id = ? AND attendance_date = ?',
        whereArgs: [attendance.employeeId, attendance.attendanceDate],
      );

      log.i('✅ Attendance updated ($count rows)');
      return count;
    } catch (e) {
      log.e('Failed to update attendance', error: e);
      rethrow;
    }
  }

  /// Get attendance record by employee ID and date
  Future<AttendanceModel?> getByDate(String employeeId, String date) async {
    try {
      final db = await database;

      final maps = await db.query(
        'attendance',
        where: 'employee_id = ? AND attendance_date = ?',
        whereArgs: [employeeId, date],
        limit: 1,
      );

      if (maps.isEmpty) return null;
      return AttendanceModel.fromJson(maps.first);
    } catch (e) {
      log.e('Failed to get attendance by date', error: e);
      return null;
    }
  }

  /// Get today's attendance for an employee
  Future<AttendanceModel?> getToday(int employeeId) async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return getByDate(employeeId.toString(), today);
  }

  /// Get active session (checked in but not checked out)
  Future<AttendanceModel?> getActiveSession(int employeeId) async {
    try {
      final db = await database;

      final res = await db.query(
        'attendance',
        where:
            'employee_id = ? AND checkin_time IS NOT NULL AND checkout_time IS NULL',
        whereArgs: [employeeId.toString()],
        orderBy: 'checkin_time DESC',
        limit: 1,
      );

      if (res.isEmpty) return null;
      return AttendanceModel.fromJson(res.first);
    } catch (e) {
      log.e('Failed to get active session', error: e);
      return null;
    }
  }

  /// Get all attendance records for an employee
  Future<List<AttendanceModel>> getAllByEmployeeId(String employeeId) async {
    try {
      final db = await database;

      final maps = await db.query(
        'attendance',
        where: 'employee_id = ?',
        whereArgs: [employeeId],
        orderBy: 'attendance_date DESC',
      );

      return maps.map((map) => AttendanceModel.fromJson(map)).toList();
    } catch (e) {
      log.e('Failed to get all attendance records', error: e);
      return [];
    }
  }

  /// Get attendance records for a date range
  Future<List<AttendanceModel>> getByDateRange({
    required String employeeId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final db = await database;

      final start = DateFormat('yyyy-MM-dd').format(startDate);
      final end = DateFormat('yyyy-MM-dd').format(endDate);

      final maps = await db.query(
        'attendance',
        where: 'employee_id = ? AND attendance_date BETWEEN ? AND ?',
        whereArgs: [employeeId, start, end],
        orderBy: 'attendance_date DESC',
      );

      return maps.map((map) => AttendanceModel.fromJson(map)).toList();
    } catch (e) {
      log.e('Failed to get attendance by date range', error: e);
      return [];
    }
  }

  /// Get attendance count for current month
  Future<int> getMonthlyAttendanceCount(int employeeId) async {
    try {
      final db = await database;
      final now = DateTime.now();
      final firstDay = DateTime(now.year, now.month, 1);
      final lastDay = DateTime(now.year, now.month + 1, 0);

      final start = DateFormat('yyyy-MM-dd').format(firstDay);
      final end = DateFormat('yyyy-MM-dd').format(lastDay);

      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM attendance '
        'WHERE employee_id = ? AND attendance_date BETWEEN ? AND ?',
        [employeeId.toString(), start, end],
      );

      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      log.e('Failed to get monthly attendance count', error: e);
      return 0;
    }
  }

  /// Delete old attendance records (for cleanup)
  Future<int> deleteOlderThan(DateTime date) async {
    try {
      final db = await database;
      final dateStr = DateFormat('yyyy-MM-dd').format(date);

      final count = await db.delete(
        'attendance',
        where: 'attendance_date < ?',
        whereArgs: [dateStr],
      );

      log.i('🧹 Deleted $count old attendance records');
      return count;
    } catch (e) {
      log.e('Failed to delete old records', error: e);
      return 0;
    }
  }

  /// Delete attendance record by ID
  Future<int> deleteAttendance(int id) async {
    try {
      final db = await database;
      final count = await db.delete(
        'attendance',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      log.i('🗑️ Deleted attendance record (id=$id)');
      return count;
    } catch (e) {
      log.e('Failed to delete attendance', error: e);
      return 0;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // CLEANUP METHODS
  // ═══════════════════════════════════════════════════════════

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('users');
    await db.delete('attendance');
    log.w('🧹 Local DB cleared');
  }

  Future<void> clearAttendanceData() async {
    final db = await database;
    await db.delete('attendance');
    log.w('🧹 Attendance data cleared');
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      log.i('🔒 DB closed');
    }
  }

  // ───────────────── NUCLEAR RESET ─────────────────
  Future<void> resetDatabase() async {
    final path = join(await getDatabasesPath(), 'hrm.db');

    if (_database != null) {
      await _database!.close();
      _database = null;
    }

    await deleteDatabase(path);
    log.w('🔥 DB deleted');

    _database = await _initDB();
    log.i('✅ DB recreated');
  }

  // ═══════════════════════════════════════════════════════════
  // UTILITY METHODS
  // ═══════════════════════════════════════════════════════════

  /// Get database statistics
  Future<Map<String, int>> getStats() async {
    try {
      final db = await database;

      final userCount = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM users'),
          ) ??
          0;

      final attendanceCount = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM attendance'),
          ) ??
          0;

      return {
        'users': userCount,
        'attendance': attendanceCount,
      };
    } catch (e) {
      log.e('Failed to get stats', error: e);
      return {'users': 0, 'attendance': 0};
    }
  }

  /// Check if database is initialized
  bool get isInitialized => _database != null;

  /// Get database path
  Future<String> getDatabasePath() async {
    return join(await getDatabasesPath(), 'hrm.db');
  }
}