import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//show is used to import particular package
import 'dart:developer' as devtools show log;

enum MenuAction { logout }

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          tooltip: 'Show Snackbar',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('This is a navigation mwnu')));
          },
        ),
        title: const Text("Notes"),
        backgroundColor: Colors.blue,
        titleTextStyle: const TextStyle(fontSize: 20, color: Colors.white),
        //a list of navigation menu to redirect to different pages
        actions: [
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              // devtools.log(value.toString());
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogoutDialog(context);
                  devtools.log(shouldLogout.toString());
                  if (shouldLogout) {
                    await FirebaseAuth.instance.signOut();
                    // ignore: use_build_context_synchronously
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil('/login/', (_) => false);
                  }
                  break;
              }
            },
            itemBuilder: (context) {
              return [
                const PopupMenuItem<MenuAction>(
                  // value is what we see
                  value: MenuAction.logout,
                  //child is what the user sees
                  child: Text("Log out"),
                )
              ];
            },
          )
        ],
      ),
      body: const Text("Notes"),
    );
  }
}

// log out function
Future<bool> showLogoutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      //use AlertDialog from showDialog
      return AlertDialog(
        title: const Text("Sign Out"),
        content: const Text("Are you sure you want top log out?"),
        actions: [
          //cancel button
          TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text("Cancel")),

          //confirm button
          TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text("Confirm")),
        ],
      );
    },
  ).then(
    (value) => value ?? false,
  );
}
