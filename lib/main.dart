import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'login_screen.dart';

//////////////////////////////////////////////////
/// App startup will show the login screen and
/// the about screen is also here and is accessed
/// from the login screen. Trying to branch
//////////////////////////////////////////////////

void main() async {
  runApp(const MaterialApp(title: "Rate My Class", home: LoginScreen()));
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("About")),
      body: const Center(
        child: Text(
          "This app was created by John Bejar and Octavio Galindo.",
          style: TextStyle(
            decoration: TextDecoration.underline,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
