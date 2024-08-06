

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notesfirst/constants/routes.dart';

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
             
            final user  = FirebaseAuth.instance.currentUser;
            await user?.sendEmailVerification();
      
      
          },child: const Text('Send email Verification again'),),
          TextButton(onPressed: () async{
            await FirebaseAuth.instance.signOut();
            Navigator.of(context).pushNamedAndRemoveUntil(registerRoute, (route)=>false,);
          },
          child: Text('Restart'),),
        ],),
    );
  }
}