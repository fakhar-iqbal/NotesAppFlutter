
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:notesfirst/constants/routes.dart';
import 'package:notesfirst/firebase_options.dart';
import 'package:notesfirst/utilities/show_error_dialog.dart';

/// This Dart class named HomePage extends StatelessWidget.
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {

 
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login here'),
      ),
      body: Column(
            children:[
               TextField(
                controller: _email,
                autocorrect: false,
                enableSuggestions: false,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'Enter your email',
                ),
              ),
               TextField(
                controller: _password,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                decoration: const InputDecoration(
                  hintText: 'Enter your password',
                ),
               ),
            TextButton(onPressed: () async{
          
              final email = _email.text;
              final password = _password.text;
          
              try {
                 
          
              final UserCredential=  await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);

              log(UserCredential.toString());
              Navigator.of(context).pushNamedAndRemoveUntil(notesRoute, 
            (route)=>false,
            );
              } on FirebaseAuthException catch(f){
                log(f.toString());
                await showErrorDialog(context, f.code);
              } 
              catch (e) {
                await showErrorDialog(context,e.toString());
                log(e.runtimeType.toString());
              }
          
          },child: const Text('Login'),
          ),
      
          TextButton(onPressed: (){
            Navigator.of(context).pushNamedAndRemoveUntil(registerRoute, 
            (route)=>false,
            );
          },
          child: Text('Not registered yet? Register here!')),
          
          ]),
    );
  }
}
