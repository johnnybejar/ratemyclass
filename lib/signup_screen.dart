import "package:flutter/material.dart";
import "package:firebase_auth/firebase_auth.dart";
import 'home_screen.dart';

//////////////////////////////////////////////////
/// The user can only access this screen through
/// the login screen. If valid input is given,
/// then the email and password input will be
/// stored in the firebase authentication server
/// and can be used to login to the application.
//////////////////////////////////////////////////

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  String? email;
  String? password;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Up"),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
          child: Column(
        children: [
          Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "EMAIL",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      TextFormField(
                        // Text field for entering email
                        decoration: const InputDecoration(
                          hintText: "Enter your email",
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) => email = value,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email field cannot be empty';
                          } else if (!value.contains("@")) {
                            return "Email must contain an @ symbol";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "CONFIRM EMAIL",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          hintText: "Confirm your email",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              value != email) {
                            return "Emails do not match";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "PASSWORD",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      TextFormField(
                        obscureText: true,
                        decoration: const InputDecoration(
                          hintText: "Passwords must be 8 characters long",
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) => password = value,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Password cannot be blank";
                          } else if (value.length < 8) {
                            return "Password must be 8 characters long";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "CONFIRM PASSWORD",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      TextFormField(
                        obscureText: true,
                        decoration: const InputDecoration(
                          hintText: "Confirm your password",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              value != password) {
                            return "Passwords do not match";
                          }
                          return null;
                        },
                      )
                    ],
                  ))),
          ElevatedButton(
              style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: const BorderSide(color: Colors.black))),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                  fixedSize: const MaterialStatePropertyAll<Size>(
                      Size.fromWidth(300))),
              onPressed: (() {
                if (_formKey.currentState!.validate()) {
                  trySignup();
                }
              }),
              child: const Text("SIGN UP", style: TextStyle(color: Colors.black),)),
        ],
      )),
    );
  }

  void trySignup() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: "$email", password: "$password");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
        "Email address $email has been signed up!",
        style: TextStyle(color: Colors.green[400]),
      )));
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: "$email", password: "$password");
      setState(() {});
      if (!mounted) return;
      // Fixed issue where you could go back to loginscreen without hitting logout button
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: ((context) => HomeScreen(
                    userCreds: credential,
                  ))),
          (route) => false);
    } on FirebaseAuthException catch (someError) {
      if (someError.code == "email-already-in-use") {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
          "Error: Email address is already in use with another account!",
          style: TextStyle(color: Colors.red[400]),
        )));
      } else if (someError.code == "invalid-email") {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
          "Error: The email address given is not valid!",
          style: TextStyle(color: Colors.red[400]),
        )));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
          "Error: Something went wrong and we're not sure what: ${someError.message}",
          style: TextStyle(color: Colors.red[400]),
        )));
      }
    }
  }
}
