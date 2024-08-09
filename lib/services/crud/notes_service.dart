import 'package:flutter/foundation.dart';
import 'package:notesfirst/services/crud/crud_exceptions.dart';
import 'package:path/path.dart' show join;
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart' show MissingPlatformDirectoryException, getApplicationDocumentsDirectory;




class NotesService{
  Database? _db;

  Future<DatabaseNotes> updateNote({required DatabaseNotes note, required String text,}) async{
    final db = _getDatabaseOrThrow();

    await getNote(id: note.id);

    final updateCount = await db.update(NotesTable,{
      textColumn: text,
      isSyncedColumn:0,
    });

    if(updateCount==0){
      throw CouldNotUpdateNoteException();
    }
    else{
      return await getNote(id: note.id);
    }
  }

  Future<Iterable<DatabaseNotes>> getAAllNotes() async{
    final db = _getDatabaseOrThrow();
    final notes = await db.query(NotesTable,);

    if(notes.isEmpty){
      throw CouldNotFindNoteException();
    }

    return notes.map((noteRow)=>DatabaseNotes.fromRow(noteRow));
    
  }

  Future<DatabaseNotes> getNote({required int id}) async {
    final db = _getDatabaseOrThrow();
    final note = await db.query(NotesTable,limit:1,where: 'id=?',whereArgs: [id]);

    if(note.isEmpty){
      throw CouldNotFindNoteException();
    }
    else{
      return DatabaseNotes.fromRow(note.first);
    }
  }

  Future<int> deleteAllNotes() async {
    final db = _getDatabaseOrThrow();
    return await db.delete(NotesTable);
  }

  Future<void> deleteNote({required int id}) async {
    final db = _getDatabaseOrThrow();
    final deleteCount = await db.delete(NotesTable,where:'id=?',whereArgs: [id]);
    if(deleteCount==0){
      throw CouldNotDeleteNoteException();
    }
    
  }

  Future<DatabaseNotes> createNote({required DatabaseUser owner})async{
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
    return note;

  }

  Future<DatabaseUser> getUser({required String email})async{
    final db = _getDatabaseOrThrow();
    final results = await db.query(userTable, where: 'email=?',whereArgs:[email.toLowerCase()]);
    if(results.isEmpty){
      throw CouldNotFindUserException();
    }
    return DatabaseUser.fromRow(results.first);
  }

  Future<DatabaseUser> createUser({required String email})async{
    final db = _getDatabaseOrThrow();
    final results = await db.query(userTable,limit:1,where:'email:?', whereArgs:[email.toLowerCase()]);
    if(results.isNotEmpty){
      throw UserAlreadyExistsException();
    }
    final userId = await db.insert(userTable, {
      emailColumn : email.toLowerCase(),
    });

    return DatabaseUser(id: userId, email: email); 
  }

  Future<void> deleteUser({required String email})async{
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
const dbName = 'notes.db';
const NotesTable = 'note';
const userTable = 'user';

const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'userId';
const textColumn = 'text';
const isSyncedColumn = 'is_synced_with_cloud';
const createNoteTable = '''
            CREATE TABLE IF NOT EXISTS "note" (
              "id"	INTEGER NOT NULL,
              "user_id"	INTEGER NOT NULL,
              "text"	TEXT,
              "is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
              PRIMARY KEY("id" AUTOINCREMENT),
              FOREIGN KEY("id") REFERENCES "",
              FOREIGN KEY("user_id") REFERENCES "user"("id")
            );
''';
const createUserTable = '''
        CREATE TABLE IF NOT EXISTS "user"  (
        "id"	INTEGER NOT NULL,
        "email"	TEXT NOT NULL UNIQUE,
        PRIMARY KEY("id" AUTOINCREMENT)
);
        ''';