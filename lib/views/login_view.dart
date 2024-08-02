
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:notesfirst/firebase_options.dart';

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
          
              print(UserCredential);
              } on FirebaseAuthException catch(f){
                print(f);
                if(f.code=='invalid-credential'){
                  print('register first');
                }
                else{
                  print(f.code);
                  if(f.code=='wrong-password'){
                    print('wrong password');
                  }
                }
              } 
              catch (e) {
                print('something bad happened');
                print(e.runtimeType);
              }
          
          },child: const Text('Login'),
          ),
      
          TextButton(onPressed: (){
            Navigator.of(context).pushNamedAndRemoveUntil('/register/', 
            (route)=>false,
            );
          },
          child: Text('Not registered yet? Register here!')),
          
          ]),
    );
  }
}
