import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notesfirst/firebase_options.dart';
import 'package:notesfirst/views/login_view.dart';
import 'package:notesfirst/views/register_view.dart';
import 'package:notesfirst/views/verify_email_view.dart';
import 'dart:developer' show log;


void main() {

  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
      routes: {
        '/login/': (context)=> const LoginView(),
        '/register/' : (context) => const RegisterView(),
        '/notesview/': (context)=> const NotesView(),
      },
    ),);
}


class HomePage extends StatelessWidget {
  const HomePage({super.key});


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Firebase.initializeApp(
              options: DefaultFirebaseOptions.currentPlatform,
              ), 

        builder: (context, snapshot) {

          switch (snapshot.connectionState){
            
            case ConnectionState.done:
            final user = FirebaseAuth.instance.currentUser;
            if(user!=null){
              if(user.emailVerified){
                return const NotesView();
              }else{
                return const VerifyEmailView();
              }
            } else{
              return const LoginView();
            }

            

          
        default:
       return const CircularProgressIndicator();
          }

        },
        
      );
  }
}

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
                  Navigator.of(context).pushNamedAndRemoveUntil('/login/', 
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