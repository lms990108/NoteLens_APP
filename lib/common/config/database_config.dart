import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:notelens_app/src/model/category.dart';
import 'package:notelens_app/src/model/qna.dart';

class DatabaseConfig {
  static final DatabaseConfig instance = DatabaseConfig._instance();

  Database? _database;

  DatabaseConfig._instance() {
    _initDataBase();
  }

  factory DatabaseConfig() {
    return instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    await _initDataBase();
    return _database!;
  }

  Future<void> _initDataBase() async {
    var databasePath = await getDatabasesPath();
    String path = join(databasePath, 'notelens.db');
    _database = await openDatabase(path, version: 1, onCreate: _databaseCreate);
  }

  void _databaseCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${Category.tableName} (
        ${CategoryFields.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${CategoryFields.title} TEXT NOT NULL,
        ${CategoryFields.description} TEXT,
        ${CategoryFields.createdAt} TEXT NOT NULL,
        ${CategoryFields.deletedAt} TEXT,
        ${CategoryFields.isDeleted} INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${QnA.tableName} (
        ${QnAFields.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${QnAFields.title} TEXT NOT NULL,
        ${QnAFields.qContent} TEXT NOT NULL,
        ${QnAFields.aContent} TEXT NOT NULL,
        ${QnAFields.memo} TEXT,
        ${QnAFields.createdAt} TEXT NOT NULL,
        ${QnAFields.deletedAt} TEXT,
        ${QnAFields.isDeleted} INTEGER NOT NULL,
        ${QnAFields.categoryId} INTEGER NOT NULL,
        FOREIGN KEY (${QnAFields.categoryId}) REFERENCES ${Category.tableName} (${CategoryFields.id}) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> closeDatabase() async {
    if (_database != null) await _database!.close();
  }
}
