import 'package:flutter/material.dart';

class helpButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const helpButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

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
              return Color.fromARGB(135, 0, 20, 85); // Gray background when disabled
            }
            return Color.fromARGB(255, 54, 70, 244); // Red background when enabled
          }),
          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: onPressed != null ? Color.fromARGB(255, 255, 255, 255) : const Color.fromARGB(255, 133, 133, 133), // White text when enabled, black54 when disabled
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
