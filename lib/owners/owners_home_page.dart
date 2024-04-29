import 'package:flutter/material.dart';
import 'package:pixandrix/first_page.dart';
import 'package:pixandrix/helpers/order_form.dart';
import 'package:pixandrix/models/owner_model.dart';
import 'package:pixandrix/theme/buttons/main_button.dart';

class OwnersHomePage extends StatefulWidget {
  final OwnerData? ownerInfo;
  const OwnersHomePage({super.key, this.ownerInfo});

  @override
  _OwnersHomePageState createState() => _OwnersHomePageState();
}

class _OwnersHomePageState extends State<OwnersHomePage> {
  late OwnerData? ownerInfo; 

  @override
  void initState() {
    super.initState();
    ownerInfo = widget.ownerInfo;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(ownerInfo?.name ?? 'Owner Name'), // Use owner's name or a default value
        leading: CircleAvatar(
          backgroundImage: NetworkImage(ownerInfo?.ownerImage ?? ''), // Use owner's image or a default image URL
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
        padding: const EdgeInsets.all(16.0),
        child: CustomButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const OrderForm()),
            );
          },
          text: 'Request a Driver',
        ),
      ),
    );
  }
}
