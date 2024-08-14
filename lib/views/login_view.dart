


import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:notesfirst/constants/routes.dart';
import 'package:notesfirst/services/auth/auth_exception.dart';
import 'package:notesfirst/services/auth/auth_service.dart';
import 'package:notesfirst/utilities/dialogs/error_dialog.dart';

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
              await AuthService.firebase().logIn(email: email, password: password);

              final  user = AuthService.firebase().currentUser;
              if(user?.isEmailVerified ?? false){
                //the user is verified
                Navigator.of(context).pushNamedAndRemoveUntil(notesRoute, 
            (route)=>false,
            );
              }else{
                //the user is not verified
                Navigator.of(context).pushNamedAndRemoveUntil(verifyEmailRoute, 
            (route)=>false,
            );
              }
              
              }on UserNotFoundAuthException{
                await showErrorDialog(context, 'User not found');
              } on WrongPasswordAuthException{
                await showErrorDialog(context, 'Wrong password');
              } on GenericAuthException{
                await showErrorDialog(context, 'Authentication error');
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
