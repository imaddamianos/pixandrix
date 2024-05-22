import 'package:flutter/material.dart';
import 'package:pixandrix/owners/owners_home_page.dart';

void showAlertDialog(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message, style: const TextStyle(color: Colors.black),),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

void showAlertOrder(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message, style: const TextStyle(color: Colors.black),),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const OwnersHomePage()),
              );
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}