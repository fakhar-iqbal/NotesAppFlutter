

import 'package:flutter/material.dart';
import 'package:notesfirst/constants/routes.dart';
import 'package:notesfirst/services/auth/auth_service.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Text('verify email here'),
      ),
      body: Column(children: [
          const Text("We've sent the verification email. check your inbox!"),
          const Text('Did not receive the email? click here: '),
          TextButton(onPressed: () async {
             
            
            await AuthService.firebase().SendEmailVerification();
      
      
          },child: const Text('Send email Verification again'),),
          TextButton(onPressed: () async{
            await AuthService.firebase().logOut();
            Navigator.of(context).pushNamedAndRemoveUntil(registerRoute, (route)=>false,);
          },
          child: const Text('Restart'),),
        ],),
    );
  }
}