import 'package:pixandrix/models/order_model.dart';

class RequestDriverCheck {
  bool shouldDisableButton(List<OrderData> orders) {
  if (orders.isEmpty) return false;

  // Sort the orders by lastOrderTimeUpdate in ascending order
  orders.sort((a, b) => a.orderTimeTaken.toDate().compareTo(b.orderTimeTaken.toDate()));

  final latestOrder = orders.last;
  final orderTimeTaken = latestOrder.orderTimeTaken.toDate();
  final currentTime = DateTime.now();

  // Calculate the difference in minutes between currentTime and lastOrderTimeUpdate
  final timeDifference = currentTime.difference(orderTimeTaken).inMinutes;

  // Return false if the time difference is greater than 10 minutes, otherwise return true
  if (timeDifference >= 7) {
    return false;
  }
  return true;
}
}