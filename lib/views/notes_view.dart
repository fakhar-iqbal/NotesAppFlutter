
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:notesfirst/constants/routes.dart';

enum MenuAction { logout }

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes Main View'),
        backgroundColor: Colors.red,
        actions:[
          PopupMenuButton(
            onSelected: (value) async {
              switch(value){
                case MenuAction.logout:
                final shouldLogout = await showLogoutDialog(context);
                log(shouldLogout.toString());
                if(shouldLogout){
                  await FirebaseAuth.instance.signOut();
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
      body: const Text('Your notes appear hre'),
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