class CloudStorageExceptions implements Exception{
  const CloudStorageExceptions();
}

class CouldNotCreateNoteException implements CloudStorageExceptions{}
class CouldNotUpdateNoteException implements CloudStorageExceptions{}
class CouldNotDeleteNoteException implements CloudStorageExceptions{}

class CouldNotGetAllNotesException implements CloudStorageExceptions{}
