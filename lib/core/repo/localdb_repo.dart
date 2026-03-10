import 'dart:io';
import 'package:hrm/core/config/config.dart';
import 'package:hrm/core/model/attances_model.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';

class LocalDBRepository {
  LocalDBRepository._internal();

  static final LocalDBRepository _instance = LocalDBRepository._internal();
  static LocalDBRepository get instance => _instance;

  Database? _database;
  final _store = intMapStoreFactory.store(Config.DBCONFIG.TABLENAME);

  Future<void> init() async {
    if (_database != null) return;
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = join(dir.path, Config.DBCONFIG.DBNAME);
    _database = await databaseFactoryIo.openDatabase(dbPath);
  }

   Future<Database> get _db async {
    if (_database != null) return _database!;
    await init();
    return _database!;
  }

  Future<int> addData(AttendanceModel model) async {
    return await _store.add(await _db, model.toJson());
  }

  Future<void> updateData(int key, AttendanceModel model) async {
    await _store.update(
      await _db,
      model.toJson(),
      finder: Finder(filter: Filter.byKey(key)),
    );
  }

  Future<List<AttendanceModel>> getAllData() async {
    final records = await _store.find(await _db);
    return records
        .map(
          (snap) =>
              AttendanceModel.fromJson(Map<String, dynamic>.from(snap.value)),
        )
        .toList();
  }

  Future<void> clearAll() async {
    await _store.delete(await _db);
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
