import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Author {
  final int id;
  final String name;
  final int age;

  const Author({
    required this.id,
    required this.name,
    required this.age,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
    };
  }

  @override
  String toString() {
    return 'Author{id: $id, name: $name, age: $age}';
  }
}

class DBHelper {
  static Database? _database;
  static final DBHelper instance = DBHelper._();

  DBHelper._();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), 'authors_database.db');

    return await openDatabase(
      path,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE authors(id INTEGER PRIMARY KEY, name TEXT, age INTEGER)',
        );
      },
      version: 1,
    );
  }

  Future<void> insertAuthor(Author author) async {
    final db = await database;
    await db.insert(
      'authors',
      author.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Author>> authors() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('authors');

    return List.generate(maps.length, (i) {
      return Author(
        id: maps[i]['id'] as int,
        name: maps[i]['name'] as String,
        age: maps[i]['age'] as int,
      );
    });
  }

  Future<void> updateAuthor(Author author) async {
    final db = await database;
    await db.update(
      'authors',
      author.toMap(),
      where: 'id = ?',
      whereArgs: [author.id],
    );
  }

  Future<void> deleteAuthor(int id) async {
    final db = await database;
    await db.delete(
      'authors',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAuthorByName(String name) async {
    final db = await database;
    await db.delete(
      'authors',
      where: 'name = ?',
      whereArgs: [name],
    );
  }

  deleteDatabase() {}
}