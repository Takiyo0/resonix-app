import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

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
          width: (MediaQuery.of(context).size.width * 0.65 * widget.scale)
              .toDouble()
              .clamp(220.0, 500.0),
          height: MediaQuery.of(context).size.width * 0.65,
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
            child: CachedNetworkImage(
              fit: BoxFit.cover,
              imageUrl: widget.imageUrl,
              progressIndicatorBuilder: (context, url, downloadProgress) {
                if (downloadProgress.progress == null) {
                  return _buildSkeleton();
                }
                return Container();
              },
              errorWidget: (context, url, error) {
                return Container(
                  color: Colors.black.withAlpha((255 * 0.5).toInt()),
                  child: Center(
                    child: Icon(
                      Icons.music_note,
                      color: Colors.white,
                      size: 50,
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

  Widget _buildSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[800]!,
      highlightColor: Colors.grey[600]!,
      child: Container(
        width: (MediaQuery.of(context).size.width * 0.65 * widget.scale)
            .toDouble()
            .clamp(220.0, 500.0),
        height: MediaQuery.of(context).size.width * 0.65,
        color: Colors.black,
      ),
    );
  }
}
