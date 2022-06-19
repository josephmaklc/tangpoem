import 'package:flutter/material.dart';

void myShowAboutDialog(BuildContext context, String appTitle, String author, String version, String date) async {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('About ' + appTitle, textAlign: TextAlign.center),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(version, textAlign: TextAlign.center),
              Text(author, textAlign: TextAlign.center),
              Text(date, textAlign: TextAlign.center),
            ],
          ),
        ),
        actions: <Widget>[
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'OK'),
              child: const Text('OK'),
            )
          ])
        ],
      );
    },
  );
}