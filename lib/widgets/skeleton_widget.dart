import 'package:flutter/material.dart';

class SkeletonContainer extends StatelessWidget {
  final double width;
  final double height;
  final BoxShape shape;

  const SkeletonContainer({
    required this.width,
    required this.height,
    this.shape = BoxShape.rectangle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[700],
        borderRadius: shape == BoxShape.circle
            ? null
            : BorderRadius.circular(8.0),
        shape: shape,
      ),
    );
  }
}
