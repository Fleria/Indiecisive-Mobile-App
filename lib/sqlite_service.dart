import 'package:camera/camera.dart'; //used for Xfile
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

//database that will function as global variable
//import this file
SqliteService mySqliteService = SqliteService();
//late Database myDatabase;

//whenever the database is used, we must have created a SqliteService object
//and run initializeDB() on it
//database is located only at global variable myDatabase at each time
class SqliteService {
  final String? myPath = "indiecisive.db";
  late final String defaultPath;
  static late final Database myDatabase;

  //initialization function, called just once for this app
  void initializeDB() async {
    defaultPath = await getDatabasesPath();
    //this deletes the database
    //databaseFactory.deleteDatabase(join(defaultPath, myPath));
    myDatabase = await openDatabase(
      join(defaultPath, myPath),
      onCreate: (Database database, version) async {
        //create database table for entries
        await database.execute(
          "CREATE TABLE Master(ID INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,Type INTEGER NOT NULL,Title TEXT NOT NULL, Category TEXT NOT NULL,Choices INTEGER NOT NULL,Image TEXT)",
        );
        //create database table for configuration categories
        await database.execute(
            "CREATE TABLE Categories(ID INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,Category TEXT NOT NULL UNIQUE)");

        //await database.execute(
        //    "CREATE TABLE ImageChoices(ID INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,Choice1 TEXT,Choice2 TEXT,Choice3 TEXT,Choice4 TEXT,Choice5 TEXT,Choice6 TEXT,Choice7 TEXT,Choice8 TEXT,Choice9 TEXT,Choice10 TEXT,)");
      },
      version: 1,
    );
  }

  //Function that inserts an entry into the database
  //returns id(primary key) to be used to get particular entry
  //to pass through buttons to diplay(choice page)
  Future<int> insertEntry(Entry entry) async {
    final int id = await myDatabase.insert(
      'Master',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    return id;
  }

  Future<int> insertCategory(String category) async {
    final int id = await myDatabase.insert(
      'Categories',
      {'Category': category},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    return id;
  }

// A method that retrieves all entries from the Master table
  Future<List<Entry>> getAllEntries() async {
    // Query the table for all entries
    final List<Map<String, dynamic>> maps = await myDatabase.query('Master');

    // Convert the List<Map<String, dynamic> into a List<Entry>
    return List.generate(maps.length, (i) {
      return Entry(
        type: (maps[i]['Type'].toInt()),
        title: maps[i]['Title'],
        category: maps[i]['Category'],
        choices: maps[i]['Choices'],
        imageChoices: null,
        image: maps[i]['Image'],
      );
    });
  }

// Convert the List<Map<String, dynamic> into a List<String>
  Future<List<String>> getAllCategories() async {
    final List<Map<String, dynamic>> maps =
        await myDatabase.query('Categories');

    return List.generate(maps.length, (i) {
      String tmp = maps[i]['Category'];
      return tmp;
    });
  }

//returns an entry class with data from the single query
  Future<Entry> getOneEntry(int id) async {
    List<String> columnsToSelect = [
      'ID',
      'Type',
      'Title',
      'Category',
      'Choices',
      'Image'
    ];
    final List<Map<String, dynamic>> maps = await myDatabase.query('Master',
        columns: columnsToSelect, where: 'ID = ?', whereArgs: [id]);
    //SOS RETURNS EVERYTHING AS STRING TYPE
    return Entry(
        type: (maps[0]['Type'].toInt()),
        title: maps[0]['Title'],
        category: maps[0]['Category'],
        choices: maps[0]['Choices'],
        imageChoices: null,
        image: maps[0]['Image']);
  }

  Future<void> deleteEntry(int id) async {
    // Remove an Entry from the database.
    await myDatabase.delete(
      'Master',
      // Use a `where` clause to delete a specific entry.
      where: 'ID = ?',
      // Pass the Entry's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
  }

  Future<void> deleteCategory(String category) async {
    // Remove an Entry from the database.
    await myDatabase.delete(
      'Categories',
      // Use a `where` clause to delete a specific entry.
      where: 'Category = ?',
      // Pass the Entry's id as a whereArg to prevent SQL injection.
      whereArgs: [category],
    );
  }

  /*Future<int> insertImageChoice(ImageEntry imageentry) async {
    final int id = await myDatabase.insert(
      'ImageChoices',
      imageentry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    return id;
  }*/
}

//class that contain all data, will be used as unit for I/O
class Entry {
  //data fields
  int type;
  String title;
  String category;
  int choices;
  //XFile? image;
  List<String>? imageChoices;
  //int? imageChoices;
  String? image;

  //constructor
  Entry(
      {required this.type,
      required this.title,
      required this.category,
      required this.choices,
      required this.imageChoices,
      required this.image});

  Map<String, dynamic> toMap() {
    return {
      'Type': type,
      'Title': title,
      'Category': category,
      'Choices': choices,
      'Image': image
    };
  }

  //override method to make it easier to print as string
  @override
  String toString() {
    return 'Entry{Type: $type, Title: $title, Category: $category, Choices: $choices}';
  }
}

/*class ImageEntry {
  List<String?>? imageEntries = List<String?>.generate(10, (index) => null);

  Map<String, dynamic> toMap() {
    return {
      'Choice1': imageEntries![0],
      'Choice2': imageEntries![1],
      'Choice3': imageEntries![2],
      'Choice4': imageEntries![3],
      'Choice5': imageEntries![4],
      'Choice6': imageEntries![5],
      'Choice7': imageEntries![6],
      'Choice8': imageEntries![7],
      'Choice9': imageEntries![8],
      'Choice10': imageEntries![9],
    };
  }
}*/
