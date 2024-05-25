import 'package:flutter/material.dart';

class DriverCard extends StatelessWidget {
  const DriverCard({
    super.key,
    required this.name,
    required this.image,
    required this.mobile,
    required this.isVerified,
    required this.isAvailable,
    required this.press,
    required this.onDelete,
    required this.onToggleVerification,
  });

  final String name;
  final String image;
  final String mobile;
  final bool isVerified;
  final bool isAvailable;
  final GestureTapCallback press;
  final VoidCallback onDelete;
  final VoidCallback onToggleVerification;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: GestureDetector(
        onTap: press,
        child: SizedBox(
          width: MediaQuery.of(context).size.width - 20,
          height: 100,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Positioned(
                  top: 5,
                  right: 50,
                  child: TextButton(
                    onPressed: () {},
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Icon(
                          Icons.circle,
                          color: isAvailable
                              ? Colors.green
                              : Color.fromARGB(255, 175, 76, 76),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mobile,
                        style: const TextStyle(color: Colors.green),
                      ),
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.all(10),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(image),
                  ),
                ),
                Container(
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
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Switch(
                    value: isVerified,
                    onChanged: (value) {
                      onToggleVerification();
                    },
                    activeColor: Colors.green,
                    inactiveThumbColor: Colors.red,
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.delete),
                      color: Colors.white,
                      onPressed: onDelete,
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
}
