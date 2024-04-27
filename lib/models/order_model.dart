import 'package:pixandrix/models/driver_model.dart';
import 'package:pixandrix/models/owner_model.dart';

enum OrderStatus { pending, inProgress, delivered, cancelled }

class Order {
  final DateTime orderTime;
  final String orderLocation;
  final OrderStatus status;
  final bool isTaken;
  final DriverData driverInfo;
  final OwnerData storeInfo;

  Order({
    required this.orderTime,
    required this.orderLocation,
    required this.status,
    required this.isTaken,
    required this.driverInfo,
    required this.storeInfo,
  });
}
