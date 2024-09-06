import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('items.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE items (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      brand TEXT NOT NULL,
      category TEXT NOT NULL,
      gstPrice REAL NOT NULL,
      cashPrice REAL NOT NULL
    )
    ''');
  }

  Future<int> createItem(Map<String, dynamic> item) async {
    final db = await instance.database;
    return await db.insert('items', item);
  }

  Future<List<Map<String, dynamic>>> readAllItems() async {
    final db = await instance.database;
    return await db.query('items');
  }

  Future<int> updateItem(int id, Map<String, dynamic> item) async {
    final db = await instance.database;

    return await db.update(
      'items',
      item,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteItem(int id) async {
    final db = await instance.database;

    return await db.delete(
      'items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}