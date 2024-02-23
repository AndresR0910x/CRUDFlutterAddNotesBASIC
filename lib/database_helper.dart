import 'package:crud_lab_1_3p/note_model.dart';
import 'package:sqflite/sqflite.dart' as sql;
//import 'package:sqflite_common_ffi/sqflite_common_ffi.dart';
import 'package:sqflite_common/sqlite_api.dart';

class DatabaseHelper {
  static const int _version = 1;
  static const String _dbName = "Notes.db";
  static Future<void> createTables(sql.Database database) async {
    await database.execute(""" CREATE TABLE Note(
          id INTEGER PRIMARY KEY, title TEXT NOT NULL, description TEXT NOT NULL, 
          createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP);
          """);
  }

  static Future<sql.Database> _getDB() async {
    return sql.openDatabase(_dbName, version: _version,
        onCreate: (sql.Database database, int version) async {
      await createTables(database);
    });
  }

  static Future<int> addNote(Note note) async {
    final db = await _getDB();
    return await db.insert("Note", note.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<int> updateNote(Note note) async {
    final db = await _getDB();
    return await db.update("Note", note.toJson(),
        where: 'id =?',
        whereArgs: [note.id],
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<int> deleteNote(Note note) async {
    final db = await _getDB();
    return await db.delete(
      "Note",
      where: 'id =?',
      whereArgs: [note.id],
    );
  }

  static Future<List<Note>?> getAllNotes() async {
    final db = await _getDB();

    final List<Map<String, dynamic>> maps = await db.query("Note");
    if (maps.isEmpty) {
      return null;
    }
    return List.generate(maps.length, (index) => Note.fromJson(maps[index]));
  }
}
