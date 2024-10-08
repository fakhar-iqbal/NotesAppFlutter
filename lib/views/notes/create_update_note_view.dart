
import 'package:flutter/material.dart';
import 'package:notesfirst/services/auth/auth_service.dart';
import 'package:notesfirst/utilities/dialogs/cannot_share_empty_dialog.dart';
import 'package:notesfirst/utilities/generics/get_arguments.dart';
import 'package:notesfirst/services/cloud/cloud_note.dart';
import 'package:notesfirst/services/cloud/firebase_cloud_storage.dart';
import 'package:share_plus/share_plus.dart';
class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {

  CloudNote? _note;
  late final FirebaseCloudStorage _notesService;
  late final TextEditingController _textController;

  @override
  void initState(){
    _notesService = FirebaseCloudStorage();
    _textController = TextEditingController();
    super.initState();
  }

  Future<CloudNote> createOrGetExistingNote(BuildContext context)async{
    
    final widgetNote = context.getArgument<CloudNote>();
    if(widgetNote !=null){
      _note = widgetNote;
      _textController.text = widgetNote.text;
      return widgetNote;
    }

    final existingNote = _note;
    
    if(existingNote != null){
      
      return existingNote;
    }
    

    final currentUser = AuthService.firebase().currentUser!;
    final ownerUserId = currentUser.id;
    final newNote= await _notesService.createNote(ownerUserId: ownerUserId);
    _note = newNote;
    return newNote;
    
  }

  void _textControllerListener()async{
    final note = _note;
    if(note==null){
      return;
    }
    final text = _textController.text;
    await _notesService.updateNote(documentId: note.documentId, text: text);
    
  }

  void _setupTextControllerListener(){
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  void _deleteNoteIfEmpty(){
    final note = _note;
    if(_textController.text.isEmpty && note != null){
      _notesService.deleteNote(documentId: note.documentId);
    }
  }

  void _saveNoteIfNotEmpty() async {
    final note = _note;
    final text = _textController.text;
    if(text.isNotEmpty && note!=null){
      await _notesService.updateNote(documentId: note.documentId, text: text);
    }

  }

  @override
  void dispose() {
    _deleteNoteIfEmpty();
    _saveNoteIfNotEmpty();
    _textController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title:  const Text('New Note'),
        actions: [
          IconButton(onPressed:() async {
            final text = _textController.text;
            if(_note==null || text.isEmpty){
              
              await cannotShareEmptyNoteDialog(context);
            }else{
              Share.share(text);
            }
          },
          icon: const Icon(Icons.share),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder(
          
          future: createOrGetExistingNote(context),
          builder:(context,snapshot){
            switch(snapshot.connectionState){
              case ConnectionState.done:
              
              _setupTextControllerListener();
              
              return TextField(
                controller: _textController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Start typing here...',
                ),
              );
              default:
              return const CircularProgressIndicator();
            }
          },
        ),
      ),

    );
  }
}

