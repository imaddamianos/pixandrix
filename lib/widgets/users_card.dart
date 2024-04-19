import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class UsersCard extends StatelessWidget {
  const UsersCard({
    Key? key,
    required this.name,
    required this.image,
    required this.mobile,
    required this.location,
    required this.press,
    required this.onDelete,
  }) : super(key: key);

  final String name, image, mobile, location;
  final GestureTapCallback press;
  final VoidCallback onDelete;

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
                      Text(
                        location,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 175, 155, 76),
                        ),
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
