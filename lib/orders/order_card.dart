import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pixandrix/helpers/order_status_utils.dart';
import 'package:timer_builder/timer_builder.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.orderTime,
    required this.orderLocation,
    required this.status,
    required this.driverInfo,
    required this.storeInfo,
    required this.press,
    required this.onChangeStatus,
    required this.onCancel,
  });

  final String driverInfo, orderLocation, storeInfo;
  final String status;
  final Timestamp orderTime;
  final GestureTapCallback press;
  final VoidCallback onChangeStatus;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> statusInfo = getStatusInfo(status);
    DateTime now = DateTime.now();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: GestureDetector(
        onTap: press,
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
                      onPressed: onCancel,
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
                            storeInfo,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            orderLocation,
                            style: const TextStyle(color: Colors.green),
                          ),
                          const SizedBox(height: 4),
                          TimerBuilder.periodic(
                            const Duration(seconds: 1),
                            builder: (context) {
                              Duration timeLeft =
                                  orderTime.toDate().difference(now);
                              return Text(
                                'Time: ${_formatDuration(timeLeft)}',
                                style: const TextStyle(color: Colors.white),
                              );
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
                        onPressed: onChangeStatus,
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

   String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
      String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
      String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.isNegative) {
       return 'Expired';
    } else if (duration.inMinutes <= 7) {
      return '$twoDigitMinutes min :$twoDigitSeconds sec';
    } else {
      return '$twoDigitMinutes min :$twoDigitSeconds sec';
    }
  }
}
