import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/utilities/show_error_diallog.dart';

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

                  //Chapter: Error handling in RegisterView

                  //it would be better to send the verification email as soon as the user registers instead of asking the user whether to  send it or not
                  final user = FirebaseAuth.instance.currentUser;
                  await user?.sendEmailVerification();

                  // on succesful registration, navigate to verifyEmailView
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pushNamed(verifyEmailRoute);
                } on FirebaseAuthException catch (e) {
                  // print(e.code);
                  if (e.code == 'weak-password') {
                    devtools.log("Weak password");
                    // Chapter: error handling in RegisterView
                    await showErrorDialog(
                      // ignore: use_build_context_synchronously
                      context,
                      "Weak Password. Please enter a strong password",
                    );
                  } else if (e.code == 'email-already-in-use') {
                    devtools.log("Email already in use");
                    await showErrorDialog(
                      // ignore: use_build_context_synchronously
                      context,
                      "Email already in use. Please enter a new email",
                    );
                  } else if (e.code == 'invalid-email') {
                    devtools.log("Invalid Email entered");
                    await showErrorDialog(
                      // ignore: use_build_context_synchronously
                      context,
                      "Invalid email",
                    );
                  } else {
                    await showErrorDialog(
                      // ignore: use_build_context_synchronously
                      context,
                      "Error: ${e.code}",
                    );
                  }
                } catch (e) {
                  await showErrorDialog(
                    // ignore: use_build_context_synchronously
                    context,
                    "Error: ${e.toString()}",
                  );
                }
              },
              child: const Text("Register")),

          // Already registed.. login button
          TextButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  loginRoute,
                  (route) => false,
                );
              },
              child: const Text("Already registered? Login Here!")),
        ],
      ),
    );
  }
}
