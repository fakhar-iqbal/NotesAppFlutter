
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:notesfirst/constants/routes.dart';
import 'package:notesfirst/enums/menu_action.dart';
import 'package:notesfirst/services/auth/auth_service.dart';
import 'package:notesfirst/services/crud/notes_service.dart';



class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final NotesService _notesService;

  String get userEmail =>AuthService.firebase().currentUser!.email!;
  @override
  void initState() {
    _notesService = NotesService();
    
    super.initState();
  }
  @override
  void dispose() {
    _notesService.close();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes Appear here'),
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
                final shouldLogout = await showLogoutDialog(context);
                log(shouldLogout.toString());
                if(shouldLogout){
                  await AuthService.firebase().logOut();
                  Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, 
                  (_)=>false,);
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
      body: FutureBuilder(
        future: _notesService.getOrCreateUser(email: userEmail),
        builder: (context,snapshot){
          switch(snapshot.connectionState){
            
            case ConnectionState.done:
              return StreamBuilder(
                stream: _notesService.allNotes,
                builder: (context,snapshot){
                  switch(snapshot.connectionState){
                    
                    case ConnectionState.waiting:
                    case ConnectionState.active:
                    return const Text('waiting for all notes...');
                    
                    default:
                    return const  CircularProgressIndicator();
                  }
                }
              );
            default:
              return const CircularProgressIndicator(); 
          }
          
        },
      ),
    );
  }
}

Future<bool> showLogoutDialog(BuildContext context){
  return showDialog(context: context,
  builder: (context){
    return AlertDialog(
      title: const Text('Log out'),
      content: const Text('Are you sure you want to log out?'),
      actions: [
         TextButton(onPressed: (){
          Navigator.of(context).pop(false);
         }, child: const Text('no'),),
         TextButton(onPressed: (){
          Navigator.of(context).pop(true);
         }, child: const Text('Log out'),),
      ],
    );

  }).then((value)=> value ?? false);
}