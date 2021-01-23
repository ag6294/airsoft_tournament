import 'package:flutter/material.dart';

void showCustomErrorDialog(BuildContext context, String text) {
  showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Errore'),
        content: SingleChildScrollView(
          child: Text(text),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Chiudi'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

class GentiAPIException implements Exception {
  final String cause;
  GentiAPIException(this.cause);
}

class FirebaseDBException implements Exception {
  final String cause;
  FirebaseDBException(this.cause);
}
