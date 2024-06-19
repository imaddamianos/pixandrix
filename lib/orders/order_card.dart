import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pixandrix/helpers/notification_bell.dart';
import 'package:pixandrix/helpers/order_status_utils.dart';
import 'package:timer_builder/timer_builder.dart';

class OrderCard extends StatefulWidget {
  const OrderCard({
    super.key,
    required this.orderTime,
    required this.orderLocation,
    required this.status,
    required this.lastOrderTimeUpdate,
    required this.driverInfo,
    required this.storeInfo,
    required this.press,
    required this.onChangeStatus,
    required this.onCancel,
  });

  final String driverInfo, orderLocation, storeInfo;
  final String status;
  final Timestamp orderTime, lastOrderTimeUpdate;
  final GestureTapCallback press;
  final VoidCallback onChangeStatus;
  final VoidCallback onCancel;

  @override
  _OrderCardState createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  // bool _hasSentNotification = false; // Flag to track notification sent

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> statusInfo = getStatusInfo(widget.status, 'owner');
    DateTime now = DateTime.now();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: GestureDetector(
        onTap: widget.press,
        child: SizedBox(
          width: MediaQuery.of(context).size.width - 10,
          height: 100,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color.fromARGB(255, 184, 184, 183),
                        Colors.transparent,
                        Color.fromARGB(200, 184, 184, 183),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: widget.onCancel,
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Color.fromARGB(255, 255, 0, 0)),
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            widget.storeInfo,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.orderLocation,
                            style: const TextStyle(color: Colors.green),
                          ),
                          const SizedBox(height: 4),
                          TimerBuilder.periodic(
                            const Duration(seconds: 1),
                            builder: (context) {
                              Duration timeLeft =
                                  widget.orderTime.toDate().difference(now);
                              if (widget.status == 'OrderStatus.pending') {
                                return Text(
                                  'Time: ${_formatDuration(timeLeft, widget.orderTime, widget.lastOrderTimeUpdate)}',
                                );
                              } else {
                                return const Text('');
                              }
                            },
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: TextButton(
                    onPressed: widget.onChangeStatus,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusInfo['iconData'],
                          color: statusInfo['iconColor'],
                        ),
                        Text(
                          statusInfo['statusText'],
                          style: TextStyle(
                            color: statusInfo['iconColor'],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration, Timestamp orderTimestamp, Timestamp lastOrderTimeUpdate) {
    DateTime now = DateTime.now();
    DateTime orderTime = orderTimestamp.toDate();
    DateTime lastOrderTime = lastOrderTimeUpdate.toDate();

    Duration timeLeft = orderTime.difference(now);
    Duration timeSinceLastUpdate = now.difference(lastOrderTime);

    if (timeLeft.isNegative) {
      return 'Expired';
    }

    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitHours = twoDigits(timeLeft.inHours.remainder(24));
    String twoDigitMinutes = twoDigits(timeLeft.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(timeLeft.inSeconds.remainder(60));

    if (timeSinceLastUpdate.inMinutes >= 10) {
      notificationService.subscribeToOrderTimeExceed(); // Call your function to handle order exceeding time
      return 'Check order $twoDigitHours:$twoDigitMinutes:$twoDigitSeconds';
    } else {
      return '$twoDigitHours:$twoDigitMinutes:$twoDigitSeconds';
    }
  }
}
