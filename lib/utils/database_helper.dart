import 'package:movie_list/models/photo.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';


class DatabaseHelper {

	static DatabaseHelper _databaseHelper;    // Singleton DatabaseHelper
	static Database _database;                // Singleton Database

	String photoTable = 'note_table';
	String colId = 'id';
	String colTitle = 'title';
	String colDirector = 'description';
	String colImage = 'image';
	String colDate = 'date';

	DatabaseHelper._createInstance(); // Named constructor to create instance of DatabaseHelper

	factory DatabaseHelper() {

		if (_databaseHelper == null) {
			_databaseHelper = DatabaseHelper._createInstance(); // This is executed only once, singleton object
		}
		return _databaseHelper;
	}

	Future<Database> get database async {

		if (_database == null) {
			_database = await initializeDatabase();
		}
		return _database;
	}

	Future<Database> initializeDatabase() async {
		// Get the directory path for both Android and iOS to store database.
		Directory directory = await getApplicationDocumentsDirectory();
		String path = directory.path + 'notes.db';

		// Open/create the database at a given path
		var photoDatabase = await openDatabase(path, version: 1, onCreate: _createDb);
		return photoDatabase;
	}

	void _createDb(Database db, int newVersion) async {

		await db.execute('CREATE TABLE $photoTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, '
					'$colDirector TEXT, $colImage String, $colDate TEXT)');
	}

	// Fetch Operation: Get all photo objects from database
	Future<List<Map<String, dynamic>>> getPhotoMapList() async {
		Database db = await this.database;

  //		var result = await db.rawQuery('SELECT * FROM $noteTable order by $colPriority ASC');

		//Old statement
		// 	var result = await db.query(photoTable, orderBy: '$colImage ASC');

		var result = await db.query(photoTable);
		return result;
	}

	// Insert Operation: Insert a Photo object to database
	Future<int> insertNote(Photo note) async {
		Database db = await this.database;
		var result = await db.insert(photoTable, note.toMap());
		return result;
	}

	// Update Operation: Update a Note object and save it to database
	Future<int> updateNote(Photo note) async {
		var db = await this.database;
		var result = await db.update(photoTable, note.toMap(), where: '$colId = ?', whereArgs: [note.id]);
		return result;
	}

	// Delete Operation: Delete a Note object from database
	Future<int> deletePhoto(int id) async {
		var db = await this.database;
		int result = await db.rawDelete('DELETE FROM $photoTable WHERE $colId = $id');
		return result;
	}

	// Get number of Note objects in database
	Future<int> getCount() async {
		Database db = await this.database;
		List<Map<String, dynamic>> x = await db.rawQuery('SELECT COUNT (*) from $photoTable');
		int result = Sqflite.firstIntValue(x);
		return result;
	}

	// Get the 'Map List' [ List<Map> ] and convert it to 'Note List' [ List<Note> ]
	Future<List<Photo>> getNoteList() async {

		var noteMapList = await getPhotoMapList(); // Get 'Map List' from database
		int count = noteMapList.length;         // Count the number of map entries in db table

		List<Photo> photoList = List<Photo>();
		// For loop to create a 'Note List' from a 'Map List'
		for (int i = 0; i < count; i++) {
			photoList.add(Photo.fromMapObject(noteMapList[i]));
		}

		return photoList;
	}

}







