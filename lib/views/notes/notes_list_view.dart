import 'package:flutter/material.dart';
import 'package:notesfirst/services/crud/notes_service.dart';
import 'package:notesfirst/utilities/dialogs/delete_dialog.dart';

typedef NoteCallback = void Function(DatabaseNotes note);

class NotesListView extends StatelessWidget {
  const NotesListView({super.key, required this.onDeleteNote,required this.onTapNote, required this.notes});
  final NoteCallback onDeleteNote;
  final NoteCallback onTapNote;
  final List<DatabaseNotes> notes;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
                        itemCount: notes.length,
                        itemBuilder: (context,index){
                          final note = notes[index];
                          return ListTile(
                            onTap: (){
                              onTapNote(note);
                            },
                            title: Text(note.text,
                            maxLines: 1,
                            softWrap:true,
                            overflow: TextOverflow.ellipsis,
                            ),
                            trailing: IconButton(
                              onPressed:()async{
                                final shouldDelete= await showDeleteDialog(context:context);
                                if(shouldDelete){
                                  onDeleteNote(note);
                                }
                              },
                              icon: const Icon(Icons.delete),
                            ),

                            
                          );
                        },
                        
                      );
  }
}