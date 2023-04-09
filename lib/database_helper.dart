import 'Note.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

//creating a singleton class, so that we dont have to again n again create or configure database
class DatabaseHelper {
//singleton : used to create first nd the only instance
  static DatabaseHelper? _databaseHelper;

//singleton : used to create first nd the only instance
  static Database? _database;

  //create strings that will help in creating the table or database
  String noteTable = "note_table";
  String colId = "id";
  String colTitle = "title";
  String colDescription = "description";
  String colDate = "date";
  String colPriority = "priority";

  //named private constructor
  DatabaseHelper._createInstance();

  // to ensure only one instance is created:
  factory DatabaseHelper() {
    _databaseHelper = DatabaseHelper._createInstance();
    return _databaseHelper as DatabaseHelper;
  }

  //custom getter for database
  Future<Database?> get database async {
    _database ??= await initializeDatabase();
    return _database;
  }

  Future<Database>? initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = "${directory.path}notes.db";

    var notesDatabse = await openDatabase(path, version: 1, onCreate: _createDB);
    return notesDatabse;
  }

//create db:
  void _createDB(Database db, int newVersion) async {
    db.execute('''CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, 
        $colTitle TEXT, $colDescription TEXT, $colPriority INTEGER, $colDate TEXT)''');
  }

  //method to fetch data from table:
  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database db = await database as Database;
    var result = await db.query(noteTable, orderBy: "$colPriority ASC");
    //or we can use:
    //db.rawquerry("SELECT * from $noteTable order by $colPriority ASC")

    return result;
  }

  //method to insert note in table
  Future<int> insertNote(id, title, date, priority, [description]) async {
    Database db = await database as Database;
    var result = await db.insert(noteTable, Note.withId(id, title, date, priority, description).toMap());
    return result;
  }

  //method to update note in table
  Future<int> updateNote(Note note) async {
    Database db = await database as Database;
    var result = await db.update(noteTable, note.toMap(), where: "$colId=?", whereArgs: [note.id]);
    return result;
  }

  //method to delete note in table
  Future<int> deleteNote(int? id) async {
    Database db = await database as Database;
    var result = await db.delete(noteTable, where: "$colId = ?", whereArgs: [id]);
    return result;
  }

  //count the rows or objects:
  Future<int> getCount() async {
    Database db = await database as Database;
    List<Map<String, dynamic>> x = await db.rawQuery("SELECT COUNT (*) from $noteTable");
    int result = Sqflite.firstIntValue(x) as int;
    return result;
  }

  //convert map object list to note object list:
  Future<List<Note>> getNoteList() async {
    var noteMapList = await getNoteMapList();
    int count = noteMapList.length;

    List<Note> noteList = [];
    for (var i = 0; i < count; i++) {
      noteList.add(Note.fromMapObject(noteMapList[i]));
    }
    return noteList;
  }
}
