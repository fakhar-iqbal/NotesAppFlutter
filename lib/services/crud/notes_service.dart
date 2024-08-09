import 'package:flutter/foundation.dart';
import 'package:path/path.dart' show join;
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart' show MissingPlatformDirectoryException, getApplicationDocumentsDirectory;


class DatabaseAlreadyOpenException implements Exception{}
class UnableToGetDocumentDirectory implements Exception{}
class DatabaseIsNotOpenException implements Exception{}

class NotesService{
  Database? _db;

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