
import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus { pending, inProgress, delivered, cancelled }

class OrderData {
  final String orderID;
  final Timestamp orderTime;
  final String orderLocation;
    final String status;
    final bool isTaken;
  final String driverInfo;
  final String storeInfo;
  final Timestamp lastOrderTimeUpdate;

  OrderData({
    required this.orderID,
    required this.orderTime,
    required this.orderLocation,
    required this.status,
    required this.isTaken,
    required this.driverInfo,
    required this.storeInfo,
    required this.lastOrderTimeUpdate,
  });
}
