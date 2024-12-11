import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/utilities/show_error_diallog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
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
        title: const Text("Login"),
        backgroundColor: Colors.blue,
        titleTextStyle: const TextStyle(fontSize: 20, color: Colors.white),
      ),
      body: Column(
        children: [
          // //Email Input Field
          TextField(
            controller: _email,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(hintText: "Enter E-mail"),
          ),

          //Password Input Field
          TextField(
            controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(hintText: "Enter Password"),
          ),

          // Login Button
          TextButton(
              onPressed: () async {
                // await Firebase.initializeApp(
                //    options: DefaultFirebaseOptions.currentPlatform,
                //  );
                final email = _email.text;
                final password = _password.text;
                try {
                  final userCredential = await FirebaseAuth.instance
                      .signInWithEmailAndPassword(
                          email: email, password: password);
                  devtools.log(userCredential.toString());
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    notesRoute,
                    (route) => false,
                  );
                }
                //the type of excpetion is identified using the e.runtimeType method
                on FirebaseAuthException catch (e) {
                  devtools.log(
                      'FirebaseAuthException code: ${e.code}'); // Debugging

                  if (e.code == 'user-not-found') {
                    // print(e.code);

                    // Chapter: Error handling in LoginView
                    await showErrorDialog(
                      // devtools.log("User not found");
                      // ignore: use_build_context_synchronously
                      context,
                      "User not found. Please check your email or register.",
                    );
                  } else if (e.code == 'invalid-credential') {
                    // devtools.log(e.code.toString());
                    // devtools.log("Wrong Password- invalid login credentials");

                    await showErrorDialog(
                      // ignore: use_build_context_synchronously
                      context,
                      "Wrong Password - Invalid login credentials",
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
                    e.toString(),
                  );
                }

                // catch (e) {
                //   print("Something bad happended");
                //   print(e.runtimeType);
                //   print(e);
                // }
              },
              child: const Text("Login")),

          // route to registerView

          TextButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  registerRoute,
                  (route) => false,
                );
              },
              child: const Text("Not registered yet? Register Here!"))
        ],
      ),
    );
  }
}
