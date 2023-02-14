import "package:flutter/material.dart";
import "package:firebase_auth/firebase_auth.dart";
import 'package:rate_my_clas/home_screen.dart';
import 'package:rate_my_clas/signup_screen.dart';
import 'main.dart';

////////////////////////////////////////////////////
/// Login screen is now the first screen you see when
/// starting the app. If the user types valid
/// credentials, they are logged in and sent to the
/// home screen. They are also given the option to
/// sign up. Testing the branch a 2nd time.
////////////////////////////////////////////////////

// login credentials are
// username: john@bejar.com
// password: 12345678

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String? email;
  String? password;
  String? error;
  final _formKey =
      GlobalKey< // Underscore implies a private variable in this class
          FormState>();
  // The global key allows you to generate the unique identifier to the key,
  // then we can use it wherever in the class the FormState is what we use
  // for the Forms, to collect the information for the forms

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Log In"),
        actions: <Widget>[
          TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AboutScreen()));
              },
              child: const Text(
                "About",
                style: TextStyle(color: Colors.white),
              )) // Changed the about to the top of the AppBar
        ],
      ),
      body: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
              // We need this SingleChildScrollView widget so that the screen does not
              // overflow when the keyboard is shown and to allow the user to view their
              // input as it is being typed
              child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  width: 300,
                  height: 300,
                  child: Image.asset("assets/images/prototype/RTC_Logo.png"),
                ),
                Form(
                  key: _formKey,
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(),
                        const Text("Email"),
                        TextFormField(
                          decoration: const InputDecoration(
                              hintText: "Enter your email"),
                          onChanged: (value) => email = value,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              // Indicates value is null or ""
                              return 'Email field cannot be empty';
                            } else if (!value.contains("@")) {
                              // Indicates the email must have a @
                              return "Email must contain an @ symbol";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text("Password"),
                        TextFormField(
                          obscureText: true,
                          decoration: const InputDecoration(
                              hintText: "Enter your password"),
                          onChanged: (value) => password = value,
                          validator: (value) {
                            if (value == null || value.length < 8) {
                              return 'Password must contain at least 8 characters';
                            }
                            return null;
                          },
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    side:
                                        const BorderSide(color: Colors.black))),
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              // Validate will call the validators for the form fields, and if they are null, it will be true
                              tryLogin();
                            }
                          },
                          child: const Text(
                            "LOGIN",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        if (error !=
                            null) // If auth doesn't work, this pop up will appear with a reason why
                          Text(
                            "Oppsie Error: $error",
                            style: TextStyle(color: Colors.red[800]),
                          ),
                        const SizedBox(
                          height: 15,
                        ),
                        const Text("New Account?"),
                        ElevatedButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    side:
                                        const BorderSide(color: Colors.black))),
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                          ),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const SignUpScreen()));
                          },
                          child: const Text("SIGN UP",
                              style: TextStyle(color: Colors.black)),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ))),
    );
  }

  // This is the method that will attempt to sign the user into the home screen, if logging in doesn't work, it will spit out an error
  void tryLogin() async {
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: "$email", password: "$password");
      error = null;
      setState(() {});
      if (!mounted) return;
      Navigator.of(context).pop();
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => HomeScreen(
                userCreds: credential,
              )));
    } on FirebaseAuthException catch (someError) {
      if (someError.code == "user-not-found") {
        error = "Sorry bub, no one with an email by that name!";
      } else if (someError.code == "wrong-password") {
        error = "Uh oh, looks like that password is wrong!";
      } else {
        error =
            "Well, some error occured but we're not sure what: ${someError.message}";
      }
      setState(() {});
    }
  }
}
