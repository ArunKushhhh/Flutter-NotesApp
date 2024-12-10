import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
      ),
    );
  }
}
