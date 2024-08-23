import 'package:firebase_core/firebase_core.dart';
import 'package:notesfirst/firebase_options.dart';
import 'package:notesfirst/services/auth/auth_user.dart';
import 'package:notesfirst/services/auth/auth_provider.dart';
import 'package:notesfirst/services/auth/auth_exception.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, FirebaseAuthException;


class FirebaseAuthProvider implements AuthProvider{

  @override 
  Future<void> initialize()async{
    await Firebase.initializeApp(
              options: DefaultFirebaseOptions.currentPlatform,
              );
  }
  @override
  Future<void> logOut()async{
    final user =  FirebaseAuth.instance.currentUser; 
    if(user!=null){
      FirebaseAuth.instance.signOut();
    }else{
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  Future<AuthUser> createUser({required String email, required String password}) async{
    try{
      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      final user = currentUser;
      if(user!=null){
        return user;
      }else{
        throw UserNotFoundAuthException();
      }
    }on FirebaseAuthException catch(e){
      if(e.code=='weak-password'){
        throw WeakPasswordAuthException();
      }else if(e.code=='email-already-in-use'){
        throw EmailAlreadyInUseAuthException();
      }else if(e.code=='invalid-email'){
        throw EmailInvalidAuthException();
      }else{
        throw GenericAuthException();
      }

    } catch(_){
      throw GenericAuthException();
    }
  }

  @override 
  Future<AuthUser> logIn({required String email, required String password})async{
    try{
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      final user = currentUser;
      if(user!=null){
        return user;
      }else{
        throw UserNotLoggedInAuthException();
      }
    }on FirebaseAuthException catch(e){
      if(e.code=='user-not-found'){
        throw UserNotFoundAuthException();
      }else if(e.code=='wrong-password'){
        throw WeakPasswordAuthException();
      }else{
        throw GenericAuthException();
      }
    } catch(_){
      throw GenericAuthException();
    }
  }

  @override    
  AuthUser? get currentUser{

    final user = FirebaseAuth.instance.currentUser;
    if(user != null){
      return AuthUser.fromFirebase(user);
    }else{
      return null;
    }
  }

  @override   
  Future<void> SendEmailVerification()async {
    final user = FirebaseAuth.instance.currentUser;
    if(user!=null){
      await user.sendEmailVerification();
    }else{
      throw UserNotLoggedInAuthException();
    }
  }

  @override  
  Future<void> sendPasswordReset({required String toEmail}) async {
    try{
      await FirebaseAuth.instance.sendPasswordResetEmail(email: toEmail);
    } on FirebaseAuthException catch(e){
      switch(e.code){
        case 'firebase_auth/invalid-email':
        throw EmailInvalidAuthException();
        case 'firebase_auth/user-not-found':
        throw UserNotFoundAuthException();
        default: 
        throw GenericAuthException();
      }
    }   catch(_){
      throw GenericAuthException();
    }
  }
}
