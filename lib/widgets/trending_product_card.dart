import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/app_colors.dart';
import '../data/models/product_model.dart';
import 'product_hero.dart';

/// Premium trending card — white body with product stacked over the top edge.
class TrendingProductCard extends StatefulWidget {
  const TrendingProductCard({
    super.key,
    required this.product,
    required this.onAdd,
    required this.onOpen,
    this.scrollOffset = 0,
    this.index = 0,
    this.heroTag,
  });

  final ProductModel product;
  final VoidCallback onAdd;
  final VoidCallback onOpen;
  final double scrollOffset;
  final int index;
  final String? heroTag;

  static const double cardWidth = 140;
  static const double overflowTop = 28;
  static const double bodyHeight = 86;
  static const double imageSize = 78;
  static double get totalHeight => overflowTop + bodyHeight;

  @override
  State<TrendingProductCard> createState() => _TrendingProductCardState();
}

class _TrendingProductCardState extends State<TrendingProductCard>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late final AnimationController _tapController;
  late final Animation<double> _tapScale;

  static const double _itemWidth = 140;
  static const double _gap = 16;

  @override
  void initState() {
    super.initState();
    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _tapScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.92)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.92, end: 1.06)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.06, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 25,
      ),
    ]).animate(_tapController);
  }

  @override
  void dispose() {
    _tapController.dispose();
    super.dispose();
  }

  double get _scrollScale {
    final itemCenter =
        (widget.index * (_itemWidth + _gap)) + (_itemWidth / 2);
    final viewportCenter = widget.scrollOffset + 160;
    final distance = (itemCenter - viewportCenter).abs();
    final t = (1 - (distance / 280)).clamp(0.9, 1.0);
    return t;
  }

  void _handleTap() {
    _tapController.forward(from: 0);
    widget.onOpen();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final scrollScale = _scrollScale;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        _handleTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedBuilder(
        animation: _tapController,
        builder: (context, child) {
          final scale = (_pressed ? 0.97 : 1.0) * scrollScale * _tapScale.value;
          return Transform.scale(
            scale: scale,
            alignment: Alignment.bottomCenter,
            child: child,
          );
        },
        child: SizedBox(
          width: TrendingProductCard.cardWidth,
          height: TrendingProductCard.totalHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: TrendingProductCard.overflowTop,
                left: 0,
                right: 0,
                child: Container(
                  height: TrendingProductCard.bodyHeight,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.pastelCream,
                        AppColors.white,
                        Color(0xFFFFF8F2),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.divider.withOpacity(0.65),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x142D2926),
                        blurRadius: 22,
                        offset: Offset(0, 10),
                        spreadRadius: -4,
                      ),
                      BoxShadow(
                        color: Color(0x0ADA1884),
                        blurRadius: 16,
                        offset: Offset(0, 4),
                        spreadRadius: -6,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            product.formattedPrice,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: TrendingProductCard.overflowTop -
                    TrendingProductCard.imageSize * 0.52,
                left: 0,
                right: 0,
                child: Center(
                  child: IgnorePointer(
                    child: SizedBox(
                      width: TrendingProductCard.imageSize,
                      height: TrendingProductCard.imageSize,
                      child: ProductHero(
                        tag: widget.heroTag ?? 'hero_trending_${product.id}',
                        imagePath: product.imagePath,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
