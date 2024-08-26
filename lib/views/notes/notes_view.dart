
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notesfirst/constants/routes.dart';
import 'package:notesfirst/enums/menu_action.dart';
import 'package:notesfirst/extensions/buildcontext/loc.dart';
import 'package:notesfirst/services/auth/auth_service.dart';
import 'package:notesfirst/services/auth/bloc/auth_bloc.dart';
import 'package:notesfirst/services/auth/bloc/auth_event.dart';
import 'package:notesfirst/services/cloud/cloud_note.dart';
import 'package:notesfirst/services/cloud/firebase_cloud_storage.dart';
import 'package:notesfirst/utilities/dialogs/logout_dialog.dart';
import 'package:notesfirst/views/notes/notes_list_view.dart';

extension Count<T extends Iterable> on Stream<T>{
  Stream<int> get getLength => map((event) => event.length);
}

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final FirebaseCloudStorage _notesService;

  String get userId =>AuthService.firebase().currentUser!.id;
  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder(
          stream: _notesService.allNotes(ownerUserId: userId).getLength,
          builder: (context, AsyncSnapshot<int> snapshot) {
            if(snapshot.hasData){
              final notesCount = snapshot.data ?? 0;
              final text = context.loc.notes_title(notesCount);
              return Text(text);
              
            }else{
              return const Text('');
            }
          }
        ),
        backgroundColor: Colors.red,
        actions:[
          IconButton(
            onPressed: (){
              Navigator.of(context).pushNamed(newNoteRoute);
            },
            icon: const Icon(Icons.add), 
          ),
          PopupMenuButton(
            onSelected: (value) async {
              switch(value){
                case MenuAction.logout:
                final shouldLogout = await showLogoutDialog(context:context);
                
                if(shouldLogout){
                  context.read<AuthBloc>().add(const AuthEventLogOut());
                  
                }
                break;
              }
            },
            itemBuilder: (context){
              return [
                const PopupMenuItem<MenuAction>(value: MenuAction.logout,child:Text('Log out')),
              ];
            }
          )
        ],
      ),
      body: StreamBuilder(
                stream: _notesService.allNotes(ownerUserId: userId),
                builder: (context,snapshot){
                  switch(snapshot.connectionState){
                    
                    case ConnectionState.waiting:
                    case ConnectionState.active:
                    if(snapshot.hasData){
                      final allNotes = snapshot.data as Iterable<CloudNote>;
                      return NotesListView(onDeleteNote: (note) async {
                        await _notesService.deleteNote(documentId: note.documentId);
                      },
                      onTapNote:(note){
                        Navigator.of(context).pushNamed(newNoteRoute,arguments: note);
                      },
                      notes: allNotes);
                      
                    }else{
                      return const CircularProgressIndicator();
                    }
                    
                    default:
                    return const  CircularProgressIndicator();
                  }
                }
              )
    );
  }
}

