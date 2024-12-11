import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/firebase_options.dart';
import 'package:mynotes/views/login_view.dart';
import 'package:mynotes/views/notes_view.dart';
import 'package:mynotes/views/register_view.dart';
import 'package:mynotes/views/verify_email_view.dart';
import 'dart:developer' as devtools show log;
import 'package:mynotes/constants/routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    //instead of using a stateless widget we could pass the material app directly through the runApp()
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        notesRoute: (context) => const NotesView(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            // //getting the current user
            final user = FirebaseAuth.instance.currentUser;
            // print(user);
            devtools.log(user.toString());

            //after linking login and register pages
            //combining various screens (Homescreen to login and register screen)

            //if the user is logged in(user != null) we are checking if his email is verified or not. If it is, print "Email is verified" otherwise return VerifEmailView() to verify the user email

            //otherwise (if (user == null)) return LoginView()
            if (user != null) {
              if (user.emailVerified) {
                // print("Email is verified");
                return const LoginView();
              } else {
                return const VerifyEmailView();
              }
            } else {
              return const LoginView();
            }
          // return const Text("Done");
          //instead of done, if the user is logged in and his email is verified, we want to redirect him to the NotesView()

          // //emailVerified is a boolean value that indicates whether the user's email has been verified i.e. the user has clicked on the verification link sent to their email
          // //the condition checks: 1. if the user is logged in, the condition is true
          // //2. if no user is logged in (user is null), or if the user's email is not verified(emailVerified is false), the condition is false
          // if (user?.emailVerified ?? false) {
          //   // print("You are a verified user");
          //   return const Text("Done");
          // } else {
          //   // print("You need to verify your email");

          //   //we are using navigator here to push _VerifyEmailView into the hompage if the user is not verified
          //   //However it is not suggested to push something into a FutureBuilder

          //   // Navigator.of(context).push(MaterialPageRoute(
          //   //     builder: (context) => const _VerifyEmailView()));

          //   //after repalcing scaffold with column for a builder to be returned, we now need to replace the navigator with returning only _VerifyEmailView();
          //   return const _VerifyEmailView();
          //   //hence, instead of pushing a whole new screen into out app, we are just pushing content of the new screen into the current screen.
          // }

          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}
