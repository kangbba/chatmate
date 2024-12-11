import '../secrets/secret_keys.dart';
import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // FirebaseOptions를 제거
  //
  // await Firebase.initializeApp(
  //     options: FirebaseOptions(
  //       apiKey: firebaseApiKey,
  //       appId: firebaseAppId,
  //       messagingSenderId: firebaseMessagingSenderId,
  //       projectId: firebaseProjectId,
  //     )
  // );


  runApp(MyApp(),);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(),
    );
  }
}
