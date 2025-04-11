import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'start.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyDHSFZSI-gWYCXBNpFvo0iS6qkf1hMSDsg",
        authDomain: "aptitude-7d86b.firebaseapp.com",
        storageBucket: "aptitude-7d86b.appspot.com",
        appId: "1:826404950092:web:ec5c314628dcd1e4d0e4e9",
        messagingSenderId: "826404950092",
        projectId: "aptitude-7d86b",
        measurementId: "G-PW27VPL9C2",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AptiVerse',
      debugShowCheckedModeBanner: false,
      home: StartingPage(), // First screen with image + forward arrow
    );
  }
}
