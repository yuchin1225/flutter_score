import 'dart:async';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/**
 * 資料庫格式
 * id, username, score, datetime, rmk
 */

class DBHelper {
  static const String _dbName = 'score.db', _dbTable = 'score';
  static List<Map<String, dynamic>>? rows;
  static Database? _database;
  Future<Database> get database async => _database ??= await _openDb();
  static final DBHelper _dbHelper = DBHelper._privConstructor();
  factory DBHelper() => _dbHelper;
  DBHelper._privConstructor();
  static Future<Database> _openDb() async {
    var dbpath = await getDatabasesPath();
    String path = join(dbpath, _dbName);
    var db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      db.execute(
          "CREATE TABLE $_dbTable(id INTEGER PRIMARY KEY, username VARCHAR(20) DEFAULT 'guest', score INTEGER, datetime DATETIME, rmk VARCHAR(255) DEFAULT '')");
    });

    return db;
  }

  // 關閉
  closeDb() async {
    final db = await database;
    await db.close();
  }

  // 新增
  insertDb(int score) async {
    DateTime nowTime = DateTime.now();
    String formattedDateTime =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(nowTime);
    final db = await database;
    await db.insert(_dbTable, {"score": score, "datetime": formattedDateTime});
  }

  // 查詢所有
  queryDb() async {
    final db = await database;
    rows = await db.query(_dbTable, orderBy: "datetime DESC");
    return rows;
  }

  // 查詢時間
  queryTimeDb(String startDate, String endDate) async {
    final db = await database;
    rows = await db.query(_dbTable,
        where: "datetime BETWEEN ? AND ?",
        whereArgs: ["$startDate 00:00:00", "$endDate 23:59:59"],
        orderBy: "datetime DESC");
    return rows;
  }

  // 刪除
  deleteDb() async {
    final db = await database;
    await db.delete(_dbTable);
  }
}
