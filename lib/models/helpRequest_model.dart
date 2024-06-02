import 'package:cloud_firestore/cloud_firestore.dart';

class HelpRequestData {
  final String description;
  final String driverInfo;
  final String driverNumber;
  final Timestamp timestamp;
  double latitude;
  double longitude;
  bool isHelped;

  HelpRequestData({
    required this.description,
    required this.driverInfo,
    required this.driverNumber,
    required this.isHelped,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
  });
}
