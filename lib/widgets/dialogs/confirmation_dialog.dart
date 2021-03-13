import 'package:flutter/material.dart';

Future<bool> showConfirmationDialog(BuildContext context) async {
  // set up the buttons
  Widget cancelButton = TextButton(
    child: Text("Cancella"),
    onPressed: () {
      Navigator.of(context).pop(false);
    },
  );
  Widget continueButton = TextButton(
    child: Text(
      "Continua",
      style: TextStyle(fontWeight: FontWeight.bold),
    ),
    onPressed: () {
      Navigator.of(context).pop(true);
    },
  );
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Attenzione"),
    content: Text("Sei sicuro?"),
    actions: [
      cancelButton,
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
