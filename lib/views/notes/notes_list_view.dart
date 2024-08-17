import 'package:flutter/material.dart';
import 'package:notesfirst/services/cloud/cloud_note.dart';
import 'package:notesfirst/utilities/dialogs/delete_dialog.dart';

typedef NoteCallback = void Function(CloudNote note);

class NotesListView extends StatelessWidget {
  const NotesListView({super.key, required this.onDeleteNote,required this.onTapNote, required this.notes});
  final NoteCallback onDeleteNote;
  final NoteCallback onTapNote;
  final Iterable<CloudNote> notes;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
                        itemCount: notes.length,
                        itemBuilder: (context,index){
                          final note = notes.elementAt(index);
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