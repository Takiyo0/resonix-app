import 'package:flutter/cupertino.dart';
import 'package:marquee/marquee.dart';

class ConditionalMarqueeText extends StatefulWidget {
  final String text;
  final double containerWidth;
  final TextStyle style;
  final double velocity;

  const ConditionalMarqueeText({
    super.key,
    required this.text,
    required this.containerWidth,
    this.style = const TextStyle(
      color: CupertinoColors.white,
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
    this.velocity = 30,
  });

  @override
  _ConditionalMarqueeTextState createState() => _ConditionalMarqueeTextState();
}

class _ConditionalMarqueeTextState extends State<ConditionalMarqueeText> {
  late double textWidth;

  @override
  void initState() {
    super.initState();
    _calculateTextWidth();
  }

  void _calculateTextWidth() {
    final textPainter = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();

    setState(() {
      textWidth = textPainter.width;
    });
  }

  @override
  Widget build(BuildContext context) {
    _calculateTextWidth();
    return SizedBox(
      height: 30,
      width: widget.containerWidth,
      child: textWidth > widget.containerWidth
          ? Marquee(
        velocity: widget.velocity,
        text: widget.text,
        style: widget.style,
        blankSpace: 30,
      )
          : Text(
        widget.text,
        style: widget.style,
        overflow: TextOverflow.ellipsis, // Prevents overflow
      ),
    );
  }
}
