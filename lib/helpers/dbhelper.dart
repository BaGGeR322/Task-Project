import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;

enum DataBase {
  users,
  news,
}

class DBHelper {
  static Future<sql.Database> database(
      String nameDatabase, String createTable) async {
    final dbPath = await sql.getDatabasesPath();
    return sql.openDatabase(
      path.join(dbPath, '$nameDatabase.db'),
      onCreate: (db, version) {
        return db.execute('CREATE TABLE $createTable');
      },
      version: 1,
    );
  }

  static Future<void> insert(DataBase db, Map<String, Object> data) async {
    final _table = getParamsFor(db);
    final chooseDB = await DBHelper.database(
      _table['nameDatabase']!,
      _table['nameTable']! + _table['createTable']!,
    );
    chooseDB.insert(
      _table['nameTable']!,
      data,
      conflictAlgorithm: sql.ConflictAlgorithm.replace,
    );
  }

  static Future<void> update(
      String id, String changeData, List<Object> args) async {
    final _table = getParamsFor(DataBase.news);
    final chooseDB = await DBHelper.database(
      _table['nameDatabase']!,
      _table['nameTable']! + _table['createTable']!,
    );
    args.add(id);
    await chooseDB.rawUpdate(
      'UPDATE ${_table['nameTable']!} SET $changeData WHERE id = ?',
      args,
    );
  }

  static Future<void> delete(String id) async {
    final _table = getParamsFor(DataBase.news);
    final chooseDB = await DBHelper.database(
      _table['nameDatabase']!,
      _table['nameTable']! + _table['createTable']!,
    );
    await chooseDB.delete(
      _table['nameTable']!,
      where: 'id = ',
      whereArgs: [id],
    );
  }

  static Future<List<Map<String, dynamic>>?> getData(DataBase db) async {
    final _table = getParamsFor(db);
    final chooseDB = await DBHelper.database(
      _table['nameDatabase']!,
      _table['nameTable']! + _table['createTable']!,
    );
    final count = sql.Sqflite.firstIntValue(
      await chooseDB.rawQuery('SELECT COUNT(*) FROM ${_table['nameTable']!}'),
    );
    if (count == 0) return null;
    return chooseDB.query(_table['nameTable']!);
  }

  static Map<String, String> getParamsFor(DataBase db) {
    late String _nameDatabase;
    late String _nameTable;
    late String _createTable;
    switch (db) {
      case DataBase.users:
        _nameDatabase = 'users';
        _nameTable = 'user';
        _createTable = '(userName TEXT, image TEXT, email TEXT, password TEXT)';
        break;
      case DataBase.news:
        _nameDatabase = 'news';
        _nameTable = 'block_news';
        _createTable =
            '(id TEXT PRIMARY KEY, title TEXT, image TEXT, body TEXT, date TEXT, author TEXT, usersWhoAddToFavorite TEXT, commentUser TEXT)';
        break;
    }
    return {
      'nameDatabase': _nameDatabase,
      'nameTable': _nameTable,
      'createTable': _createTable,
    };
  }
  // final String id = const Uuid().v4();
  // final String title;
  // final File image;
  // final String body;
  // final DateTime date;
  // List<String> usersWhoAddToFavorite;
  // List<CommentUser> commentUser;
}
