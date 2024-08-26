
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notesfirst/constants/routes.dart';
import 'package:notesfirst/helper/loading/loading_screen.dart';
import 'package:notesfirst/services/auth/bloc/auth_bloc.dart';
import 'package:notesfirst/services/auth/bloc/auth_event.dart';
import 'package:notesfirst/services/auth/bloc/auth_state.dart';
import 'package:notesfirst/services/auth/firebase_auth_provider.dart';
import 'package:notesfirst/views/forgot_password_view.dart';
import 'package:notesfirst/views/login_view.dart';
import 'package:notesfirst/views/notes/create_update_note_view.dart';
import 'package:notesfirst/views/notes/notes_view.dart';
import 'package:notesfirst/views/register_view.dart';
import 'package:notesfirst/views/verify_email_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


void main() {

  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      title: 'Flutter Demo',
      theme: ThemeData(
        
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: BlocProvider<AuthBloc>(
        create: (context)=> AuthBloc(
          FirebaseAuthProvider()
        ),
        child: const HomePage(),
      ),
      routes: {
        newNoteRoute : (context)=> const CreateUpdateNoteView(),
      },
    ),);
}


class HomePage extends StatelessWidget {
  const HomePage({super.key});


  @override
  Widget build(BuildContext context) {

    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocConsumer<AuthBloc,AuthState>(
      listener: (context,state){
        if(state.isLoading){
          LoadingScreen().show(context: context,text: state.loadingText ?? 'Please wait a moment...');
        }else{
          LoadingScreen().hide();
        }
      },
      builder: (context,state){
      if(state is AuthStateLoggedIn){
        return const NotesView();
      } else if(state is AuthStateNeedsVerification){
        return const VerifyEmailView();
      } else if( state is AuthStateLoggedOut){
        return const LoginView();
      } else if(state is AuthStateForgotPassword){
        return const ForgotPasswordView();
      }else if(state is AuthStateRegistering){
        return const RegisterView();
      }
      else{
        return const Scaffold(
          body: CircularProgressIndicator(),
        );
      }
    });

  }
}
