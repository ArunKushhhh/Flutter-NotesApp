import 'package:flutter/material.dart';

// genereic dialog function for error handling in loginView
Future<void> showErrorDialog(
  BuildContext context,
  String text,
) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("An error occurred"),
        content: Text(text),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Ok"),
          )
        ],
      );
    },
  );
}
