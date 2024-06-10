import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus { pending, inProgress, delivered, cancelled }

class OrderData {
  final String orderID;
  final String orderLocation;
  final String status;
  final String driverInfo;
  final String storeInfo;
  final Timestamp orderTime;
  final Timestamp lastOrderTimeUpdate;
  final bool isTaken;


  OrderData({
    required this.isTaken,
    required this.orderID,
    required this.orderLocation,
    required this.status,
    required this.driverInfo,
    required this.storeInfo,
    required this.orderTime,
    required this.lastOrderTimeUpdate,
  });

  factory OrderData.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderData(
      orderID: data['orderID'],
      orderLocation: data['orderLocation'] ?? '',
      status: data['status'] ?? '',
      driverInfo: data['driverInfo'] ?? '',
      storeInfo: data['storeInfo'] ?? '',
      orderTime: data['orderTime'] ?? Timestamp.now(),
      lastOrderTimeUpdate: data['lastOrderTimeUpdate'] ?? Timestamp.now(),
      isTaken: data['isTaken'],
    );
  }
}
