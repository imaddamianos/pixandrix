import 'package:flutter/material.dart';
import 'package:pixandrix/firebase/firebase_operations.dart';
import 'package:pixandrix/owners/owners_home_page.dart';

import 'package:flutter/material.dart';

void showAlertDialog(BuildContext context, String title, String message,
    {bool goBackOnDismiss = false}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(
          message,
          style: const TextStyle(color: Colors.black),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (goBackOnDismiss) {
                Navigator.of(context)
                    .maybePop(); // Navigates back to the previous page if available
              }
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

void showAlertWithDestination(BuildContext context, String title,
    String message, StatefulWidget destination) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(
          message,
          style: const TextStyle(color: Colors.black),
        ),
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
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      );
    },
  );
}

void showAlertWithFunction(BuildContext context, String title,
    String message, void function) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(
          message,
          style: const TextStyle(color: Colors.black),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
             function;
             Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

void showAlertNewOrder(BuildContext context, String title,
    String message,  VoidCallback onClose, StatefulWidget destination) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(
          message,
          style: const TextStyle(color: Colors.black),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => destination),
              );
              onClose();
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

void showAlertChangeProgress(
    BuildContext context,
    String title,
    String message,
    String status,
    String orderNumber,
    String driverOrder,
    VoidCallback onClose) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(
          message,
          style: const TextStyle(color: Colors.black),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              DateTime now = DateTime.now().toLocal();
              if (status == 'OrderStatus.pending') {
                await FirebaseOperations.changeOrderStatus(
                    'OrderStatus.inProgress', orderNumber, now);
                await FirebaseOperations.changeDriverName(
                    driverOrder, orderNumber);
                Navigator.pop(context);
              } else if (status == 'OrderStatus.inProgress') {
                await FirebaseOperations.changeOrderStatus(
                    'OrderStatus.delivered', orderNumber, now);
                Navigator.pop(context);
              }else if(status == 'OrderStatus.remove'){
                await FirebaseOperations.removeOrder(orderNumber);
                Navigator.pop(context);
              }

              onClose();
            },
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      );
    },
  );
}

void showAlertDelete(
    BuildContext context,
    String title,
    String message,
    String driverName,
    String ownerName,
    VoidCallback onClose) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(
          message,
          style: const TextStyle(color: Colors.black),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              if(ownerName == ''){
                 await FirebaseOperations.removeDriver(driverName);
                Navigator.pop(context);
              }else if(driverName == ''){
               await FirebaseOperations.removeOwner(ownerName);
                Navigator.pop(context);
              }
                

              onClose();
            },
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      );
    },
  );
}

void showAlertDriverCancelOrder(BuildContext context, String title,
    String message, String orderNumber, VoidCallback onClose) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(
          message,
          style: const TextStyle(color: Colors.black),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
                await FirebaseOperations.changeOrderStatus(
                    'OrderStatus.pending', orderNumber, DateTime(0000, 0, 0));
                Navigator.pop(context);
                await FirebaseOperations.changeDriverName('', orderNumber);

              onClose();
            },
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      );
    },
  );
}
