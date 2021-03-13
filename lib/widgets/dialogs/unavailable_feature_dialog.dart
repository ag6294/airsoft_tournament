import 'package:flutter/material.dart';

Future<bool> showFeatureNotAvailableDialog(BuildContext context) async {
  Widget continueButton = TextButton(
    child: Text(
      'Chiudi',
      style: TextStyle(fontWeight: FontWeight.bold),
    ),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Funzionalità non disponibile"),
    content: Text(
        "Questa funzioanlità non è purtroppo ancora disponibile per questa piattaforma"),
    actions: [
      continueButton,
    ],
  );
  // show the dialog
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
