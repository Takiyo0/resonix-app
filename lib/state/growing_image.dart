import 'package:flutter/material.dart';

class GrowingImageOnScroll extends StatefulWidget {
  final String imageUrl;
  final dynamic scale;

  const GrowingImageOnScroll(
      {super.key, required this.imageUrl, required this.scale});

  @override
  State<GrowingImageOnScroll> createState() => _GrowingImageOnScrollState();
}

class _GrowingImageOnScrollState extends State<GrowingImageOnScroll> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: (220 * widget.scale).toDouble().clamp(220.0, 500.0),
          height: 220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 2,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              widget.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: Icon(
                      Icons.music_note,
                      color: Colors.white,
                      size: 60,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
