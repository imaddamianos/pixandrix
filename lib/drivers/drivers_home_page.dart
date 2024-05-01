import 'package:flutter/material.dart';
import 'package:pixandrix/firebase/firebase_operations.dart';
import 'package:pixandrix/first_page.dart';
import 'package:pixandrix/models/driver_model.dart';
import 'package:pixandrix/models/order_model.dart';
import 'package:pixandrix/theme/buttons/main_button.dart';
import 'package:pixandrix/widgets/order_card_drivers';


class DriversHomePage extends StatefulWidget {
  final DriverData? driverInfo;
  const DriversHomePage({Key? key, this.driverInfo}) : super(key: key);

  @override
  _DriversHomePageState createState() => _DriversHomePageState();
}

class _DriversHomePageState extends State<DriversHomePage> {
  late DriverData? driverInfo;
  List<OrderData>? orders;

  @override
  void initState() {
    super.initState();
    _loadOrders();
    driverInfo = widget.driverInfo; // Initialize driverInfo in initState
  }

  Future<void> _loadOrders() async {
    // Fetch orders data and cast it to a List<OrderData>
    final fetchedOrders = await FirebaseOperations.getOrders();
    orders = fetchedOrders.cast<OrderData>();

    if (mounted) {
      setState(() {}); // Trigger a rebuild to reflect the updated orders data
    }
  }

  Future<void> _changeOrderStatus(
    int index,
  ) async {
    // Remove the driver at the specified index from the list
    final orderToChange = orders![index].orderID;
    final driver = driverInfo?.name;
    if (orders![index].status == 'OrderStatus.pending') {
      if (index >= 0 && index < orders!.length) {
        await FirebaseOperations.changeOrderStatus(
            'OrderStatus.inProgress', orderToChange);
        await FirebaseOperations.changeDriverName(driver!, orderToChange);
      }
    } else if (orders![index].status == 'OrderStatus.inProgress') {
      if (index >= 0 && index < orders!.length) {
        await FirebaseOperations.changeOrderStatus(
            'OrderStatus.delivered', orderToChange);
      }
    }
    _loadOrders(); // Refresh the drivers list after removing the driver
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(driverInfo?.name ?? 'Driver Name'),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: CircleAvatar(
            backgroundImage: NetworkImage(driverInfo?.driverImage ?? ''),
          ),
        ),
        actions: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const FirstPage()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: RefreshIndicator(
          onRefresh: _loadOrders,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Expanded(
                child: orders == null
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: orders!.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              OrderCardDrivers(
                                orderTime: orders![index].orderTime,
                                orderLocation: orders![index].orderLocation,
                                status: orders![index].status,
                                driverInfo: orders![index].driverInfo,
                                storeInfo: orders![index].storeInfo,
                                press: () {
                                  // Show details of the order
                                },
                                onChangeStatus: () {
                                  _changeOrderStatus(index);
                                },
                              ),
                              const SizedBox(height: 20),
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// class DriversHomePage extends StatefulWidget {
//   final DriverData? driverInfo;
//   const DriversHomePage({super.key, this.driverInfo});

//   @override
//   _DriversHomePageState createState() => _DriversHomePageState();
// }

// class _DriversHomePageState extends State<DriversHomePage> {
//   late DriverData? driverInfo;
//   List<OrderData>? orders;

//   @override
//   void initState() {
//     super.initState();
//     _loadOrders();
//     driverInfo = widget.driverInfo; // Initialize ownerInfo in initState
//   }

//   Future<void> _loadOrders() async {
//     // Fetch drivers data and cast it to a List<DriverData>
//     final fetchedOrders = await FirebaseOperations.getOrders();
//     orders = fetchedOrders.cast<OrderData>();

//     if (mounted) {
//       setState(() {}); // Trigger a rebuild to reflect the updated drivers data
//     }
//   }

//   Future<void> _changeOrderStatus(
//     int index,
//   ) async {
//     // Remove the driver at the specified index from the list
//     final orderToChange = orders![index].orderID;
//     final driver = driverInfo?.name;
//     if (orders![index].status == 'OrderStatus.pending') {
//       if (index >= 0 && index < orders!.length) {
//         await FirebaseOperations.changeOrderStatus(
//             'OrderStatus.inProgress', orderToChange);
//         await FirebaseOperations.changeDriverName(driver!, orderToChange);
//       }
//     } else if (orders![index].status == 'OrderStatus.inProgress') {
//       if (index >= 0 && index < orders!.length) {
//         await FirebaseOperations.changeOrderStatus(
//             'OrderStatus.delivered', orderToChange);
//       }
//     }
//     _loadOrders(); // Refresh the drivers list after removing the driver
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Center(
//           child: Text(driverInfo?.name ?? 'Driver Name'),
//         ), // Use owner's name or a default value
//         leading: Padding(
//           padding: const EdgeInsets.only(left: 10.0),
//           child: CircleAvatar(
//             backgroundImage: NetworkImage(driverInfo?.driverImage ??
//                 ''), // Use owner's image or a default image URL
//           ),
//         ),
//         actions: [
//           Row(
//             children: [
//               IconButton(
//                 icon: const Icon(Icons.notifications),
//                 onPressed: () {},
//               ),
//               IconButton(
//                 icon: const Icon(Icons.logout),
//                 onPressed: () {
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(builder: (context) => const FirstPage()),
//                   );
//                 },
//               ),
//             ],
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 20),
//             RefreshIndicator(
//               onRefresh: _loadOrders, // Call _loadOrders when refreshing
//               child: Expanded(
//                 child: orders == null
//                     ? Center(
//                         child: CircularProgressIndicator(),
//                       )
//                     : ListView.builder(
//                         itemCount: orders!.length,
//                         itemBuilder: (context, index) {
//                           return Column(
//                             children: [
//                               OrderCardDrivers(
//                                 orderTime: orders![index].orderTime,
//                                 orderLocation: orders![index].orderLocation,
//                                 status: orders![index].status,
//                                 // isTaken: orders![index].isTaken,
//                                 driverInfo: orders![index].driverInfo,
//                                 storeInfo: orders![index].storeInfo,
//                                 press: () {
//                                   // showDialog(
//                                   //   context: context,
//                                   //   builder: (context) => DriverCardWindow(
//                                   //     driverName: drivers![index].name,
//                                   //     driverImage: drivers![index].driverImage,
//                                   //     driverMobile: drivers![index].phoneNumber,
//                                   //     driverID: drivers![index].driverID,
//                                   //   ),
//                                   // );
//                                 },
//                                 onChangeStatus: () {
//                                   _changeOrderStatus(index);
//                                 },
//                               ),
//                               const SizedBox(height: 20),
//                             ],
//                           );
//                         },
//                       ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
