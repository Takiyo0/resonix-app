import 'package:flutter/material.dart';

class TakiyoError extends StatelessWidget {
  final String error;
  final EdgeInsetsGeometry? margin;

  const TakiyoError({super.key, required this.error, this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.withAlpha(150),
        borderRadius: BorderRadius.circular(10.0),
      ),
      margin: margin,
      height: 45.0,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Icon(Icons.error, color: Colors.white),
          SizedBox(width: 4.0),
          Expanded(
            child: Text(
              error,
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
