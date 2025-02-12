import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AnimatedPrevButton extends StatefulWidget {
  final VoidCallback? onPressed;

  const AnimatedPrevButton({Key? key, this.onPressed}) : super(key: key);

  @override
  _AnimatedPrevButtonState createState() => _AnimatedPrevButtonState();
}

class _AnimatedPrevButtonState extends State<AnimatedPrevButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _translation;
  late Animation<double> _fadeOut;
  late Animation<double> _fadeIn;
  late Animation<double> _scaleIn;
  late Animation<double> _scaleOut;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _translation = Tween<double>(begin: 0.0, end: -20.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Cubic(0.7, -0.6, 0.25, 1.1),
      ),
    );

    _fadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutCubic,
      ),
    );

    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutCubic,
      ),
    );

    _scaleIn = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Cubic(0.7, -0.6, 0.25, 1.1),
      ),
    );

    _scaleOut = Tween<double>(begin: 1.0, end: 0.5).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutCubic,
      ),
    );
  }

  void _animate() {
    _controller.forward(from: 0);
    if (widget.onPressed != null) {
      widget.onPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _animate,
      child: SizedBox(
        width: 43,
        height: 38,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(-20, 0),
                  child: Transform.scale(
                    scale: _scaleOut.value,
                    child: Opacity(
                      opacity: _fadeOut.value,
                      child: Transform.flip(
                        flipX: true,
                        child: const Icon(
                          CupertinoIcons.play_fill,
                          size: 38,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_translation.value, 0),
                  child: Transform.flip(
                    flipX: true,
                    child: const Icon(
                      CupertinoIcons.play_fill,
                      size: 38,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(20 + _translation.value, 0),
                  child: Transform.scale(
                    scale: _scaleIn.value,
                    child: Opacity(
                      opacity: _fadeIn.value,
                      child: Transform.flip(
                        flipX: true,
                        child: const Icon(
                          CupertinoIcons.play_fill,
                          size: 38,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
