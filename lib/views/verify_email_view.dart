// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_service.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify Email"),
        backgroundColor: Colors.blue,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          color: Colors.white,
        ),
      ),
      body: Column(
        children: [
          const Text(
              "we've already sent you an Email Verification. Please click on the link to verify your account"),
          Container(
            height: 20,
          ),
          const Text(
              "If you haven't received a verification email yet, press the button below"),
          TextButton(
              onPressed: () async {
                // commented in chap: migrating to auth services
                // final user = FirebaseAuth.instance.currentUser;

                AuthService.firebase().currentUser;

                // user.sendEmailVerification();

                // commented in chap: migrating to auth services
                // await user?.sendEmailVerification();

                await AuthService.firebase().sendEmailVerification();

                //if we actually want the future to be executed, we need to await on it
              },
              child: const Text("Send Email Verification")),
          Container(
            height: 20,
          ),
          const Text(
              "If you have successfully verified your email, click the button below and log in to your account"),
          TextButton(
            onPressed: () async {
              // commented in chap: migrating to auth services
              // await FirebaseAuth.instance.signOut();

              await AuthService.firebase().logOut();

              // ignore: use_build_context_synchronously
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(loginRoute, (route) => false);
            },
            child: const Text("Restart"),
          )
        ],
      ),
    );
  }
}
