import 'package:flutter/material.dart';

class TakiyoButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const TakiyoButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      child: Text(text, style: const TextStyle(fontSize: 16)),
    );
  }
}