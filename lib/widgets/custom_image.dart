import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CustomImage extends StatefulWidget {
  final String imageUrl;
  final double? scale;
  final int height;
  final int width;
  final Widget? fallback;

  const CustomImage(
      {super.key,
      required this.imageUrl,
      this.scale,
      required this.height,
      required this.width,
      this.fallback});

  @override
  State<CustomImage> createState() => _CustomImageState();
}

class _CustomImageState extends State<CustomImage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width.toDouble(),
      height: widget.height.toDouble(),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 10,
            spreadRadius: 2,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: Image.network(
            widget.imageUrl,
            fit: BoxFit.cover,
            frameBuilder: (context, child, frame, sync) {
              if (frame == null) {
                return _buildSkeleton();
              }
              return child;
            },
            errorBuilder: (context, error, stackTrace) {
              return widget.fallback ??
                  Container(
                    color: Colors.black.withAlpha((255 * 0.5).toInt()),
                    child: Center(
                      child: Icon(
                        Icons.music_note,
                        color: Colors.white,
                        // size: 60,
                        size: widget.height * 0.6,
                      ),
                    ),
                  );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[800]!,
      highlightColor: Colors.grey[600]!,
      child: Container(
        width: widget.width.toDouble(),
        height: widget.height.toDouble(),
        color: Colors.black,
      ),
    );
  }
}
