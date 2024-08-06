import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notesfirst/constants/routes.dart';
import 'package:notesfirst/firebase_options.dart';
import 'package:notesfirst/views/login_view.dart';
import 'package:notesfirst/views/notes_view.dart';
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
        loginRoute: (context)=> const LoginView(),
        registerRoute : (context) => const RegisterView(),
        notesRoute: (context)=> const NotesView(),
        verifyEmailRoute: (context)=> const VerifyEmailView(),
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
