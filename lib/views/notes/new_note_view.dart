import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:notesfirst/services/auth/auth_service.dart';
import 'package:notesfirst/services/crud/notes_service.dart';

class NewNoteView extends StatefulWidget {
  const NewNoteView({super.key});

  @override
  State<NewNoteView> createState() => _NewNoteViewState();
}

class _NewNoteViewState extends State<NewNoteView> {

  DatabaseNotes? _note;
  late final NotesService _notesService;
  late final TextEditingController _textController;

  @override
  void initState(){
    _notesService = NotesService();
    _textController = TextEditingController();
    super.initState();
  }

  Future<DatabaseNotes> createNewNote()async{
    log('f');
    final existingNote = _note;
    log('g');
    if(existingNote != null){
      log('h');

      return existingNote;
    }
    log('y');

    final currentUser = AuthService.firebase().currentUser!;
    final email = currentUser.email!;
    log(email);

    final owner = await _notesService.getUser(email: email);
    log('fs');
    final cNote = await _notesService.createNote(owner: owner);
    log('r');
    log(cNote.toString());
    return cNote;
  }

  void _textControllerListener()async{
    final note = _note;
    if(note==null){
      return;
    }
    final text = _textController.text;
    await _notesService.updateNote(note: note, text: text);
    
  }

  void _setupTextControllerListener(){
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  void _deleteNoteIfEmpty(){
    final note = _note;
    if(_textController.text.isEmpty && note != null){
      _notesService.deleteNote(id:note.id);
    }
  }

  void _saveNoteIfNotEmpty() async {
    final note = _note;
    final text = _textController.text;
    if(text.isNotEmpty && note!=null){
      await _notesService.updateNote(note: note, text: text);
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
      ),
      body: FutureBuilder(
        
        future: createNewNote(),
        builder:(context,snapshot){
          switch(snapshot.connectionState){
            case ConnectionState.done:
            _note = snapshot.data as DatabaseNotes;
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

    );
  }
}

