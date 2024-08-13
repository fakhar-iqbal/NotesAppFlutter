import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:notesfirst/services/crud/crud_exceptions.dart';
import 'package:path/path.dart' show join;
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart' show MissingPlatformDirectoryException, getApplicationDocumentsDirectory;




class NotesService{
  Database? _db;
  List<DatabaseNotes> _notes = [];

  static final NotesService _shared = NotesService._sharedInstance();
  NotesService._sharedInstance(){
    
    _notesStreamController = StreamController<List<DatabaseNotes>>.broadcast(
      onListen: (){
        _notesStreamController.sink.add(_notes);
      },
    );

  }
  factory NotesService() => _shared;

  late final StreamController<List<DatabaseNotes>>_notesStreamController;

  Stream<List<DatabaseNotes>> get allNotes => _notesStreamController.stream;

  Future<DatabaseUser> getOrCreateUser({required String email})async{
    try{
      final user = await getUser(email: email);
      return user;
    } on CouldNotFindUserException{
      final createdUser = createUser(email: email);
      return createdUser;
    } catch(e){
      final createdUser = createUser(email: email);
      return createdUser;
      
    }
  }

  Future<void> _cacheNotes()async{
    final allNotes = await getAllNotes();
    _notes = allNotes.toList();
    _notesStreamController.add(_notes);

  }


  Future<DatabaseNotes> updateNote({required DatabaseNotes note, required String text,}) async{
    await ensureOpen();
    final db = _getDatabaseOrThrow();

  //make sure that the note exists
  
    await getNote(id: note.id);

    final updateCount = await db.update(NotesTable,{
      textColumn: text,
      isSyncedColumn:0,
    },where: "id=?",whereArgs:[note.id]);

    if(updateCount==0){
      throw CouldNotUpdateNoteException();
    }
    else{
      final updatedNote =  await getNote(id: note.id);
      _notes.removeWhere((note)=>note.id==updatedNote.id);
      _notes.add(updatedNote);
      _notesStreamController.add(_notes);
      return updatedNote;
    }
  }

  Future<Iterable<DatabaseNotes>> getAllNotes() async{
    await ensureOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(NotesTable,);

    if(notes.isEmpty){
      throw CouldNotFindNoteException();
    }

    return notes.map((noteRow)=>DatabaseNotes.fromRow(noteRow));
    
  }

  Future<DatabaseNotes> getNote({required int id}) async {
    await ensureOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(NotesTable,limit:1,where: 'id=?',whereArgs: [id]);

    if(notes.isEmpty){
      throw CouldNotFindNoteException();
    }
    else{
      final note= DatabaseNotes.fromRow(notes.first);
      _notes.removeWhere((note)=>note.id==id);
      _notes.add(note);
      _notesStreamController.add(_notes);
      return note;
    }
  }

  Future<int> deleteAllNotes() async {
    await ensureOpen();
    final db = _getDatabaseOrThrow();
    final numberDelete = await db.delete(NotesTable);
    _notes=[];
    _notesStreamController.add(_notes);
    return numberDelete;
  }

  Future<void> deleteNote({required int id}) async {
    await ensureOpen();
    final db = _getDatabaseOrThrow();
    final deleteCount = await db.delete(NotesTable,where:'id=?',whereArgs: [id]);
    if(deleteCount==0){
      throw CouldNotDeleteNoteException();
    }else{
      _notes.removeWhere((note)=>note.id==id);
    }
    
  }

  Future<DatabaseNotes> createNote({required DatabaseUser owner})async{
    await ensureOpen();
    final db = _getDatabaseOrThrow();

    // make sure owner exists in rteh database

    final dbUser = await getUser(email: owner.email);
    if(dbUser!=owner){
      throw CouldNotFindUserException();
    }

    const text = '';
    //create the note
    final noteId = await db.insert(NotesTable, {
      userIdColumn: owner.id,
      textColumn: text,
      isSyncedColumn: 1,
    });

    final note = DatabaseNotes(id: noteId, text: text, userId: owner.id, isSyncedWithCloud: true,);
    log('lio');

    _notes.add(note);
    _notesStreamController.add(_notes);

    return note;

  }

Future<DatabaseUser> getUser({required String email}) async {
    await ensureOpen();
    final db = _getDatabaseOrThrow();

    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (results.isEmpty) {
      throw CouldNotFindUserException();
    } else {
      return DatabaseUser.fromRow(results.first);
    }
  }

  Future<DatabaseUser> createUser({required String email})async{
    await ensureOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(userTable,limit:1,where:'email=?', whereArgs:[email.toLowerCase()]);
    if(results.isNotEmpty){
      throw UserAlreadyExistsException();
    }
    final userId = await db.insert(userTable, {
      emailColumn : email.toLowerCase(),
    });

    return DatabaseUser(id: userId, email: email); 
  }

  Future<void> deleteUser({required String email})async{
    await ensureOpen();
    final db = _getDatabaseOrThrow();
    final deleteAccount = await db.delete(userTable,where: 'email=?',whereArgs: [email.toLowerCase()]);

    if(deleteAccount !=1){
      throw CouldNotDeleteUserException();
    }

  }

  Database _getDatabaseOrThrow(){
    final db = _db;
    if(db==null){
      throw DatabaseIsNotOpenException();
    }else{
      return db;
    }
  }

  Future<void> close()async {
    final db = _db;
    if(db==null){
      throw DatabaseIsNotOpenException();
    }else{
      await db.close();
      _db = null;
    }

  }

  Future<void> ensureOpen()async{
    try{
      await open();
    } on DatabaseAlreadyOpenException{
      // empty
    }
  }

  Future<void> open() async{
    if(_db != null){
      throw DatabaseAlreadyOpenException();
    }
    try{
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path,dbName);
      final db = await openDatabase(dbPath);
      _db =db;

      // create user table       

        await db.execute(createUserTable);
        //create note table      

        await db.execute(createNoteTable);

        await _cacheNotes();

    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentDirectory();
    }
  }
}






@immutable
class DatabaseUser{
  final int id;
  final String email;

  const DatabaseUser({required this.id, required this.email,});

  DatabaseUser.fromRow(Map<String,Object?> map) : id = map[idColumn] as int,
            email = map[emailColumn] as String;

  @override
  String toString()=> "Person, ID = $id, Email = $email";

  @override  
  bool operator ==(covariant DatabaseUser other) => id==other.id;
  @override  
  int get hashCode => id.hashCode;
}

class DatabaseNotes{
  final int id;
  final String text;
  final int userId;
  final bool isSyncedWithCloud;

  DatabaseNotes({required this.id, required this.text, required this.userId, required this.isSyncedWithCloud});
  
  DatabaseNotes.fromRow(Map<String, Object?> map) :
    id = map[idColumn] as int,
    userId = map[userIdColumn] as int,
    text= map[textColumn] as String,
    isSyncedWithCloud = (map[isSyncedColumn] as int) == 1 ? true: false;

    @override
  String toString() => 'Note, Id = $id, userId = $userId, isSyncedWIthCloud = $isSyncedWithCloud';
  @override  
  bool operator ==(covariant DatabaseNotes other) => id==other.id;
  @override  
  int get hashCode => id.hashCode;



}
const dbName = 'note.db';
const NotesTable = 'Notes';
const userTable = 'Users';

const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'userId';
const textColumn = 'text';
const isSyncedColumn = 'is_synced_with_cloud';
const createNoteTable = '''
            CREATE TABLE IF NOT EXISTS "Notes" (
              "id"	INTEGER NOT NULL,
              "userId"	INTEGER NOT NULL,
              "text"	TEXT,
              "is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
              PRIMARY KEY("id" AUTOINCREMENT),
              FOREIGN KEY("id") REFERENCES "",
              FOREIGN KEY("userId") REFERENCES "Users"("id")
            );
''';
const createUserTable = '''
        CREATE TABLE IF NOT EXISTS "Users"  (
        "id"	INTEGER NOT NULL,
        "email"	TEXT NOT NULL UNIQUE,
        PRIMARY KEY("id" AUTOINCREMENT)
);
        ''';