import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notesfirst/constants/routes.dart';
import 'package:notesfirst/services/auth/auth_exception.dart';
import 'package:notesfirst/services/auth/auth_service.dart';
import 'package:notesfirst/services/auth/bloc/auth_bloc.dart';
import 'package:notesfirst/services/auth/bloc/auth_event.dart';
import 'package:notesfirst/services/auth/bloc/auth_state.dart';
import 'package:notesfirst/utilities/dialogs/error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async  {
        if(state is AuthStateRegistering){
          if(state.exception is EmailInvalidAuthException){
            await showErrorDialog(context, 'invalid emaill!');
          }else if(state.exception is WeakPasswordAuthException){
            await showErrorDialog(context, 'weak password!!');

          }else if(state.exception is EmailAlreadyInUseAuthException){
            await showErrorDialog(context, 'email already in use!');

          }else if(state.exception is GenericAuthException){
            await showErrorDialog(context, 'Registration error!');

          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Register screen'),
        ),
        body: Column(children: [
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
          TextButton(
            onPressed: () async {
              final email = _email.text;
              final password = _password.text;

              context.read<AuthBloc>().add(AuthEventRegister(email, password));
            },
            child: const Text('Register'),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthBloc>().add(const AuthEventLogOut());
            },
            child: const Text('Login'),
          ),
        ]),
      ),
    );
  }
}
