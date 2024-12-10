import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class _VerifyEmailView extends StatefulWidget {
  const _VerifyEmailView({super.key});

  @override
  State<_VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<_VerifyEmailView> {
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
