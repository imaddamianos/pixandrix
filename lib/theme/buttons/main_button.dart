import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.disabled)) {
              return const Color.fromARGB(30, 255, 0, 0); // Gray background when disabled
            }
            return Colors.red; // Red background when enabled
          }),
          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: onPressed != null ? Colors.white : const Color.fromARGB(255, 133, 133, 133), // White text when enabled, black54 when disabled
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
