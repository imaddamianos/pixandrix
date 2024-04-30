import 'package:flutter/material.dart';

Map<String, dynamic> getStatusInfo(String status) {
  IconData iconData = Icons.circle;
  String statusText = '';
  Color iconColor = Colors.yellow; // Default icon color

  switch (status) {
    case 'OrderStatus.pending':
      iconData = Icons.circle;
      statusText = 'Pending';
      iconColor = Colors.yellow; // Set icon color for pending status
      break;
    case 'OrderStatus.inProgress':
      iconData = Icons.circle;
      statusText = 'In Progress';
      iconColor = Colors.orange; // Set icon color for in progress status
      break;
    case 'OrderStatus.delivered':
      iconData = Icons.circle;
      statusText = 'Delivered';
      iconColor = Colors.green; // Set icon color for delivered status
      break;
    case 'OrderStatus.cancelled':
      iconData = Icons.circle;
      statusText = 'Cancelled';
      iconColor = Colors.red; // Set icon color for cancelled status
      break;
  }

  return {'iconData': iconData, 'statusText': statusText, 'iconColor': iconColor};
}
