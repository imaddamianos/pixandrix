// import 'package:pixandrix/models/driver_model.dart';
// import 'package:pixandrix/models/owner_model.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus { pending, inProgress, delivered, cancelled }

class OrderData {
   final Timestamp orderTime;
  final String orderLocation;
    final String status;
    // final bool isTaken;
  final String driverInfo;
  final String storeInfo;

  OrderData({
    required this.orderTime,
    required this.orderLocation,
    required this.status,
    // required this.isTaken,
    required this.driverInfo,
    required this.storeInfo,
  });
}
