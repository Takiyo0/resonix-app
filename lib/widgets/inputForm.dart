import 'package:flutter/material.dart';

class TakiyoInputForm extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String placeholder;
  final double topMargin;
  final bool obscureText;

  const TakiyoInputForm({
    super.key,
    required this.controller,
    required this.label,
    required this.placeholder,
    this.topMargin = 5,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: topMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13.0,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 5),
          TextField(
            controller: controller,
            obscureText: obscureText,
            decoration: InputDecoration(
              labelText: placeholder,
              labelStyle: const TextStyle(color: Colors.black38),
              floatingLabelBehavior: FloatingLabelBehavior.never,
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(15.0)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
