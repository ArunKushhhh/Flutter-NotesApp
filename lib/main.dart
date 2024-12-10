import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/firebase_options.dart';
import 'package:mynotes/views/login_view.dart';
import 'package:mynotes/views/register_view.dart';

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
        '/login/': (context) => const LoginView(),
        '/register/': (context) => const RegisterView()
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
        backgroundColor: Colors.blue,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
      ),
      body: FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              // //getting the current user
              // final user = FirebaseAuth.instance.currentUser;
              // print(user);

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

              return const LoginView();

            default:
              return const Text("Loading...");
          }
        },
      ),
    );
  }
}

class _VerifyEmailView extends StatefulWidget {
  const _VerifyEmailView({super.key});

  @override
  State<_VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<_VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("Please Verify your  Email Addresss"),
        TextButton(
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              // user.sendEmailVerification();
              await user?.sendEmailVerification();
              //if we actually want the future to be executed, we need to await on it
            },
            child: const Text("Send Email Verification"))
      ],
    );
  }
}
