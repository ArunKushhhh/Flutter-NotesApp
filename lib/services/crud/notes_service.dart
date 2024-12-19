import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;
import 'package:mynotes/services/crud/crud_exceptions.dart';

// class DatabaseAlreadyOpenException implements Exception {}

// class UnableToGetDocumentsDirectory implements Exception {}

// class DatabaseIsNotOpen implements Exception {}

// class CouldNotDeleteUser implements Exception {}

// class UserAlreadyExists implements Exception {}

// class CouldNotFindUser implements Exception {}

// class CouldNotDeleteNote implements Exception {}

// class CouldNotFindNote implements Exception {}

// class CouldNotUpdateNote implements Exception {}

//opening our Database
class NotesService {
  Database? _db;
  //Chap: Catching Data
  List<DatabaseNote> _notes = [];
  //when the list of notes changes, we need to tell our stream that something has changed which allows the UI to reactively listen to the updates
  //we do this using stream controller
  final _notesStreamController =
      StreamController<List<DatabaseNote>>.broadcast();

  // Chap:Caching notes
  //currently the notes-view has no contact with the notes-services
  Future<DatabaseUser> getOrCreateUser({required String email}) async {
    try {
      final user = await getUser(email: email);
      return user;
    } on CouldNotFindUser {
      final createdUser = await createUser(email: email);
      return createdUser;
    } catch (e) {
      rethrow;
    }
  }

  //read and cache notes
  //using _ before a function makes it private
  Future<void> _cacheNotes() async {
    final allNotes = await getAllNotes();

    //converting iterable notes to list
    _notes = allNotes.toList();
    _notesStreamController.add(_notes);
  }

//CHAP: CRUD Operations
  //update existing notes
  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    required String text,
  }) async {
    final db = _getDatabaseOrThrow();

    //make sure the note exists
    await getNote(id: note.id);

    //update db
    final updatesCount = await db.update(noteTable, {
      textColumn: text,
      isSyncedWithCloudColumn: 0,
    });

    if (updatesCount == 0) {
      throw CouldNotUpdateNote();
    } else {
      // return await getNote(id: note.id);

      //chap: caching data
      final updatedNote = await getNote(id: note.id);
      //remove the existing note with the new note
      _notes.removeWhere((note) => note.id == updatedNote.id);
      //add the note to the note array
      _notes.add(updatedNote);
      //update the stream
      _notesStreamController.add(_notes);
      return updatedNote;
    }
  }

  //fetching all notes
  Future<Iterable<DatabaseNote>> getAllNotes() async {
    final db = _getDatabaseOrThrow();

    final notes = await db.query(
      noteTable,
    );

    return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
  }

  //fetching a specific note
  Future<DatabaseNote> getNote({required int id}) async {
    final db = _getDatabaseOrThrow();

    final notes = await db.query(
      noteTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [1],
    );

    if (notes.isEmpty) {
      throw CouldNotFindNote();
    } else {
      // return DatabaseNote.fromRow(notes.first);
      final note = DatabaseNote.fromRow(notes.first);
      _notes.removeWhere((note) => note.id == id);
      _notes.add(note);
      _notesStreamController.add(_notes);
      return note;
    }
  }

  //delete all notes
  Future<int> deleteAllNotes() async {
    //get the db
    final db = _getDatabaseOrThrow();

    //chap: caching data
    final numberOfDeletions = await db.delete(noteTable);
    //set the notes array to empty array
    _notes = [];
    //update the stream using stream controller
    _notesStreamController.add(_notes);
    //delete the complete noteTable
    // return await db.delete(noteTable);
    return numberOfDeletions;
  }

  //delete the note
  Future<void> deleteNote({required int id}) async {
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      noteTable,
      where: 'id=?',
      whereArgs: [id],
    );

    if (deletedCount == 0) {
      throw CouldNotDeleteNote();
    }
    //chap:caching data
    else {
      _notes.removeWhere((note) => note.id == id);
      _notesStreamController.add(_notes);
    }
  }

  //create new notes
  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    final db = _getDatabaseOrThrow();

    //ensure that the owner exists
    final dbUser = await getUser(email: owner.email);
    //to ensure that the id provided by the user actually matches with the id in the database
    if (dbUser != owner) {
      throw CouldNotFindUser();
    }

    //create note
    const text = '';
    final noteId = await db.insert(noteTable, {
      userIdColumn: owner.id,
      textColumn: text,
      isSyncedWithCloudColumn: 1,
    });

    //insert the note in your database
    final note = DatabaseNote(
      id: noteId,
      userId: owner.id,
      text: text,
      isSyncedWithCloud: true,
    );

    //chap: Caching Notes
    _notes.add(note);
    _notesStreamController.add(_notes);

    //return the note to your database
    return note;
  }

  //ability to get users
  Future<DatabaseUser> getUser({required String email}) async {
    //ensure the db is ready to be checked
    final db = _getDatabaseOrThrow();

    //await for the query results
    final results = await db.query(
      userTable,
      where: 'email=?',
      whereArgs: [email.toLowerCase()],
    );

    //if the result is empty then throw an error
    if (results.isEmpty) {
      throw CouldNotFindUser();
    }
    //else find the user
    else {
      return DatabaseUser.fromRow(results.first);
    }
  }

  //allow user to be created
  Future<DatabaseUser> createUser({required String email}) async {
    //ensure the db is ready to be checked or omitted
    final db = _getDatabaseOrThrow();

    //await for the query results
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email=?',
      whereArgs: [email.toLowerCase()],
    );

    //if the result is not empty, throw an error
    if (results.isNotEmpty) {
      throw UserAlreadyExists();
    }

    //otherwie insert the user in userTable
    final userId =
        await db.insert(userTable, {emailColumn: email.toLowerCase()});

    //return the created database with new id and email
    return DatabaseUser(
      id: userId,
      email: email,
    );
  }

  //allow users to be deleted
  Future<void> deleteUser({required String email}) async {
    final db = _getDatabaseOrThrow();

    final deletedCount = await db.delete(
      //delete something from usertable
      userTable,
      //where that something's email which is equal to something
      where: 'email= ?',
      //which is lowercase
      whereArgs: [email.toLowerCase()],
    );

    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    }
  }

  //convenience function for getting current db
  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      return db;
    }
  }

  //close the db
  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      await db.close();
      _db = null;
    }
  }

  //open the db
  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;

      //to create tables upon opening the database
      //create if the table doesn't exists
      // const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
      //   "id"	INTEGER NOT NULL,
      //   "email"	TEXT NOT NULL UNIQUE,
      //   PRIMARY KEY("id" AUTOINCREMENT)
      //   );''';
      await db.execute(createUserTable);

      //create notes table if not exists
      // const createNoteTable = '''CREATE TABLE IF NOT EXISTS "notes" (
      //   "id"	INTEGER NOT NULL,
      //   "user_id"	INTEGER NOT NULL,
      //   "text"	TEXT,
      //   "is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
      //   PRIMARY KEY("id" AUTOINCREMENT),
      //   FOREIGN KEY("user_id") REFERENCES "user"("id")
      //   );''';
      await db.execute(createNoteTable);

      //CHAP:CACHING DATA
      await _cacheNotes();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    }
  }
}

//creating a class for our user
@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({
    required this.id,
    required this.email,
  });

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'Person, ID = $id, email = $email';

  @override
  bool operator ==(covariant DatabaseUser other) {
    return id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}

//creating a class for our notes
class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  DatabaseNote({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncedWithCloud,
  });

  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        isSyncedWithCloud =
            (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;

  @override
  String toString() =>
      'Note, ID = $id, isSincedWithCloud = $isSyncedWithCloud, text = $text';

  @override
  bool operator ==(covariant DatabaseNote other) {
    return id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}

const dbName = 'notes.db';
const noteTable = 'note';
const userTable = 'user';
const idColumn = "id";
const emailColumn = "email";
const userIdColumn = "user_id";
const textColumn = "text";
const isSyncedWithCloudColumn = "is_synced_with_cloud";
const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
	      "id"	INTEGER NOT NULL,
	      "email"	TEXT NOT NULL UNIQUE,
	      PRIMARY KEY("id" AUTOINCREMENT)
        );''';
const createNoteTable = '''CREATE TABLE IF NOT EXISTS "notes" (
	      "id"	INTEGER NOT NULL,
	      "user_id"	INTEGER NOT NULL,
	      "text"	TEXT,
	      "is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
	      PRIMARY KEY("id" AUTOINCREMENT),
	      FOREIGN KEY("user_id") REFERENCES "user"("id")
        );''';
