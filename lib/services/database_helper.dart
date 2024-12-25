import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../modal/note.dart';


class DatabaseHelper {

  static  DatabaseHelper? _databaseHelper; // Singleton DatabaseHelper, now you can use this in entire application.....A singleton pattern ensures that only one instance of a class exists throughout the application.
  static  Database? _database; // Singleton Database


  String noteTable = 'note_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colPriority = 'priority';
  String colDate = 'date';
  String passwordTable = 'passwords_table';
  String colPassword = 'password'; // Hashed password storage
  String colSalt = 'salt';

  DatabaseHelper._createInstance(); // Named constructor to create instance of DatabaseHelper

  factory DatabaseHelper() {
    _databaseHelper ??= DatabaseHelper._createInstance();
    return _databaseHelper!;
  }

  static DatabaseHelper get instance {
    _databaseHelper ??= DatabaseHelper._createInstance();
    return _databaseHelper!;
  }

  Future<Database> get database async {
    _database ??= await initializeDatabase();
    return _database!;
  }

  Future<Database> initializeDatabase() async {
    // Get the directory path for both Android and iOS to store database.
    Directory directory = await getApplicationDocumentsDirectory();
    String path = '${directory.path}/notes.db'; // Use proper file separator

    // Open/create the database at a given path
    var notesDatabase = await openDatabase(path, version: 1, onCreate: _createDb);
    return notesDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, '
            '$colDescription TEXT, $colPriority INTEGER, $colDate TEXT)'
    );
    await db.execute(
        'CREATE TABLE $passwordTable($colPassword TEXT, $colSalt TEXT)'
    );
  }

  Future<void> storePassword(String password) async {

    final salt = generateSalt();
    final hashedPassword = hashPassword(password, salt);

    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(passwordTable);  //ensures only one password exists
      await txn.insert(passwordTable, {'password': hashedPassword, 'salt': salt});
    });
  }

  String generateSalt() {
    final randomBytes = List<int>.generate(16, (index) => Random().nextInt(256));
    return base64Encode(randomBytes);
  }
  String hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<bool> authenticatePassword(String password) async {
    final db = await database;
    final result = await db.query(passwordTable);

    if (result.isNotEmpty) {
      final storedPassword = result.first[colPassword];
      final storedSalt = result.first[colSalt] as String;

      final hashedEnteredPassword = hashPassword(password, storedSalt);
      return hashedEnteredPassword == storedPassword;
    }

    return false;
  }

  // Fetch Operation: Get all note objects from database
  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database db = await database;
    try {
      var result = await db.query(noteTable, orderBy: '$colPriority ASC');
      return result;
    } catch (e) {
      print("Error fetching notes: $e");
      return [];
    }
  }

  // Insert Operation: Insert a Note object to database
  Future<int> insertNote(Note note) async {
    Database db = await database;
    try {
      var result = await db.insert(noteTable, note.toMap());
      return result;
    } catch (e) {
      print("Error inserting note: $e");
      return -1;
    }
  }

  // Update Operation: Update a Note object and save it to database
  Future<int> updateNote(Note note) async {
    var db = await database;
    try {
      var result = await db.update(noteTable, note.toMap(), where: '$colId = ?', whereArgs: [note.id]);
      return result;
    } catch (e) {
      print("Error updating note: $e");
      return -1;
    }
  }

  // Delete Operation: Delete a Note object from database
  Future<int> deleteNote(int id) async {
    var db = await database;
    try {
      int result = await db.rawDelete('DELETE FROM $noteTable WHERE $colId = $id');
      return result;
    } catch (e) {
      print("Error deleting note: $e");
      return -1;
    }
  }

  // Get number of Note objects in database
  Future<int> getCount() async {
    Database db = await database;
    try {
      List<Map<String, dynamic>> x = await db.rawQuery('SELECT COUNT(*) from $noteTable');
      int? result = Sqflite.firstIntValue(x);
      return result ?? 0;
    } catch (e) {
      print("Error getting count: $e");
      return -1;
    }
  }

  // Get the 'Map List' [ List<Map> ] and convert it to 'Note List' [ List<Note> ]
  Future<List<Note>> getNoteList() async {
    var noteMapList = await getNoteMapList(); // Get 'Map List' from database
    int count = noteMapList.length; // Count the number of map entries in db table

    List<Note> noteList = List<Note>.from(noteMapList.map((map) => Note.fromMapObject(map)));

    return noteList;
  }
}
