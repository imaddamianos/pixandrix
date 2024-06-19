import 'package:pixandrix/models/order_model.dart';

class RequestDriverCheck {
  bool shouldDisableButton(List<OrderData> orders) {
  if (orders.isEmpty) return false;

  // Sort the orders by lastOrderTimeUpdate in ascending order
  orders.sort((a, b) => a.lastOrderTimeUpdate.toDate().compareTo(b.lastOrderTimeUpdate.toDate()));

  final latestOrder = orders.last;
  final lastOrderTimeUpdate = latestOrder.lastOrderTimeUpdate.toDate();
  final currentTime = DateTime.now();

  // Calculate the difference in minutes between currentTime and lastOrderTimeUpdate
  final timeDifference = currentTime.difference(lastOrderTimeUpdate).inMinutes;

  // Return false if the time difference is greater than 10 minutes, otherwise return true
  if (timeDifference >= 10) {
    return false;
  }
  return true;
}
}