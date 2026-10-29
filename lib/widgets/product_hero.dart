import 'package:flutter/material.dart';

/// Shared product-image [Hero] used between list cards and details/order.
///
/// Keep [tag] identical on both ends of a navigation. Avoid wrapping this
/// widget in ancestor [Opacity] / [FadeTransition] during the route push —
/// that hides the flight.
class ProductHero extends StatelessWidget {
  const ProductHero({
    super.key,
    required this.tag,
    required this.imagePath,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
  });

  final Object tag;
  final String imagePath;
  final BoxFit fit;
  final AlignmentGeometry alignment;

  static RectTween _arcTween(Rect? begin, Rect? end) {
    return MaterialRectArcTween(begin: begin, end: end);
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      createRectTween: _arcTween,
      transitionOnUserGestures: true,
      child: Material(
        type: MaterialType.transparency,
        child: Image.asset(
          imagePath,
          fit: fit,
          alignment: alignment,
          filterQuality: FilterQuality.high,
          gaplessPlayback: true,
        ),
      ),
    );
  }
}
