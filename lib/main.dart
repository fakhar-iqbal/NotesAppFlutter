import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notesfirst/firebase_options.dart';
import 'package:notesfirst/views/login_view.dart';



void main() {

  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    ),);
}


class HomePage extends StatelessWidget {
  const HomePage({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HomePage'),backgroundColor: const Color.fromARGB(255, 239, 168, 168),),
      body: FutureBuilder(
        future: Firebase.initializeApp(
              options: DefaultFirebaseOptions.currentPlatform,
              ), 

        builder: (context, snapshot) {

          switch (snapshot.connectionState){
            
            case ConnectionState.done:
            final user = (FirebaseAuth.instance.currentUser); 
            
            if (user?.emailVerified ?? false){
              print('user is verified');
            }
            else{
              print('user is not verified');
            }
            print('done');
              return Text('Done');

                           
              
          
        default:
       return Text('Loading...');
          }

        },
        
      ),
    );
  }
}