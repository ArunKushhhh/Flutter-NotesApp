import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;
import 'package:mynotes/constants/routes.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  //late: although the variable does not have a value now but i promise to assign it a value before it is used.
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  // everytime the homepage goes out of the memory, we need to dispose these values
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register"),
        backgroundColor: Colors.blue,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
      ),
      body: Column(
        children: [
          // Email input field
          TextField(
            controller: _email,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(hintText: "Enter E-mail"),
          ),

          //Password input field
          TextField(
            controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(hintText: "Enter Password"),
          ),

          // Register button
          TextButton(
              onPressed: () async {
                // await Firebase.initializeApp(
                //    options: DefaultFirebaseOptions.currentPlatform,
                //  );
                final email = _email.text;
                final password = _password.text;
                try {
                  final userCredential = await FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                          email: email, password: password);
                  devtools.log(userCredential.toString());
                } on FirebaseAuthException catch (e) {
                  // print(e.code);
                  if (e.code == 'weak-password') {
                    devtools.log("Weak password");
                  } else if (e.code == 'email-already-in-use') {
                    devtools.log("Email already in use");
                  } else if (e.code == 'invalid-email') {
                    devtools.log("Invalid Email entered");
                  }
                }
              },
              child: const Text("Register")),

          // Already registed.. login button
          TextButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  notesRoute,
                  (route) => false,
                );
              },
              child: const Text("Already registered? Login Here!")),
        ],
      ),
    );
  }
}
