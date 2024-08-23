

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notesfirst/constants/routes.dart';
import 'package:notesfirst/services/auth/auth_service.dart';
import 'package:notesfirst/services/auth/bloc/auth_bloc.dart';
import 'package:notesfirst/services/auth/bloc/auth_event.dart';

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
          TextButton(onPressed: ()  {
            context.read<AuthBloc>().add(const AuthEventSendVerificationEmail());
          },child: const Text('Send email Verification again'),),
          TextButton(onPressed: () async{
            context.read<AuthBloc>().add(const AuthEventLogOut());
            
          },
          child: const Text('Restart'),),
        ],),
    );
  }
}