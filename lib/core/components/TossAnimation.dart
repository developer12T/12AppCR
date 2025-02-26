import 'package:flutter/material.dart';

// ignore: unused_element
class TossAnimationOverlay extends StatelessWidget {
  final Animation<Offset> animation;
  final Offset startPosition;
  final VoidCallback onComplete;

  const TossAnimationOverlay({
    Key? key,
    required this.animation,
    required this.startPosition,
    required this.onComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: startPosition.dx,
      top: startPosition.dy,
      child: SlideTransition(
        position: animation,
        child: ScaleTransition(
          scale: animation.drive(Tween<double>(begin: 1, end: 0.3)),
          child: const Icon(
            Icons.shopping_basket,
            size: 40,
            color: Colors.orange,
          ),
        ),
      ),
    );
  }
}
