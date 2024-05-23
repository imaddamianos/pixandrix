import 'package:flutter/material.dart';
import 'package:pixandrix/owners/owners_home_page.dart';

import 'package:flutter/material.dart';

void showAlertDialog(BuildContext context, String title, String message, {bool goBackOnDismiss = false}) {
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
              if (goBackOnDismiss) {
                Navigator.of(context).maybePop(); // Navigates back to the previous page if available
              }
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}


void showAlertWithDestination(BuildContext context, String title, String message, StatefulWidget destination ) {
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
                MaterialPageRoute(builder: (context) => destination),
              );
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}