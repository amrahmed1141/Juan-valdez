import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/product_model.dart';
import 'product_hero.dart';

/// Single product product card used by [ProductCarousel].
///
/// Expand/collapse is a continuous morph (one image, one container):
/// photo slides left while the pastel shell grows into the detail card.
class ProductCard extends StatefulWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.isExpanded,
    required this.quantity,
    required this.onToggleExpand,
    required this.onOpenDetails,
    required this.onIncrement,
    required this.onDecrement,
    this.onAdd,
    this.heroTag,
  });

  final ProductModel product;
  final bool isExpanded;
  final int quantity;
  final VoidCallback onToggleExpand;
  final VoidCallback onOpenDetails;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback? onAdd;
  final String? heroTag;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with SingleTickerProviderStateMixin {
  static const Duration _duration = Duration(milliseconds: 420);
  static const double _tapSlop = 18;

  late final AnimationController _controller;
  late final Animation<double> _curve;

  bool _showQuantity = false;
  Offset? _pointerDown;
  bool _suppressCardTap = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _duration);
    _curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    if (widget.isExpanded) {
      _controller.value = 1;
    }
  }

  @override
  void didUpdateWidget(covariant ProductCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
        _showQuantity = false;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPlusTap() {
    if (!_showQuantity) {
      setState(() => _showQuantity = true);
      if (widget.quantity == 0) widget.onIncrement();
      return;
    }
    widget.onIncrement();
  }

  void _handleTapUp(TapUpDetails details) {
    if (_suppressCardTap) {
      _suppressCardTap = false;
      _pointerDown = null;
      return;
    }
    final down = _pointerDown;
    _pointerDown = null;
    if (down != null &&
        (details.globalPosition - down).distance > _tapSlop) {
      return;
    }
    widget.onToggleExpand();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isWide = screenWidth >= 700;

    final collapsedSize = isWide ? 260.0 : 240.0;
    final expandedWidth = isWide ? 380.0 : math.min(screenWidth - 48, 300.0);
    final expandedHeight = isWide ? 230.0 : 210.0;
    final imageCollapsed = collapsedSize * 0.9;
    final imageExpanded = isWide ? 128.0 : 108.0;

    return Listener(
      behavior: HitTestBehavior.deferToChild,
      onPointerDown: (event) => _pointerDown = event.position,
      onPointerCancel: (_) => _pointerDown = null,
      child: GestureDetector(
        behavior: HitTestBehavior.deferToChild,
        onTapDown: (details) => _pointerDown = details.globalPosition,
        onTapUp: _handleTapUp,
        onTapCancel: () => _pointerDown = null,
        child: AnimatedBuilder(
          animation: _curve,
          builder: (context, _) {
            final t = _curve.value;

            final width = lerpDouble(collapsedSize + 28, expandedWidth, t)!;
            final height =
                lerpDouble(collapsedSize + 16, expandedHeight + 28, t)!;
            final shellW = lerpDouble(collapsedSize, expandedWidth, t)!;
            final shellH = lerpDouble(collapsedSize, expandedHeight, t)!;
            final radius = lerpDouble(collapsedSize / 2, 36, t)!;

            final imageSize = lerpDouble(imageCollapsed, imageExpanded, t)!;
            final imageAlign = Alignment.lerp(
              Alignment.center,
              const Alignment(-0.88, 0.12),
              t,
            )!;

            final infoOpacity = Curves.easeOut
                .transform(((t - 0.28) / 0.72).clamp(0.0, 1.0));
            final collapsedAddOpacity = (1.0 - t * 1.6).clamp(0.0, 1.0);
            final notchOpacity = Curves.easeOut
                .transform(((t - 0.45) / 0.55).clamp(0.0, 1.0));

            return SizedBox(
              width: width,
              height: height,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  // Pastel shell morphs circle → rounded card.
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: shellW,
                      height: shellH,
                      decoration: BoxDecoration(
                        color: widget.product.pastelColor,
                        borderRadius: BorderRadius.circular(radius),
                        boxShadow: t > 0.15
                            ? AppTheme.softShadow
                            : AppTheme.softShadowLight,
                      ),
                      child: IgnorePointer(
                        ignoring: infoOpacity < 0.5,
                        child: Opacity(
                          opacity: infoOpacity,
                          child: Transform.translate(
                            offset: Offset(lerpDouble(18, 0, infoOpacity)!, 0),
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                lerpDouble(0, imageExpanded + 8, t)!,
                                22,
                                16,
                                14,
                              ),
                              child: _ProductInfoPanel(
                                product: widget.product,
                                isWide: isWide,
                                onOrder: () {
                                  _suppressCardTap = true;
                                  (widget.onAdd ?? widget.onOpenDetails)();
                                },
                                onOrderPointerDown: () =>
                                    _suppressCardTap = true,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Single image slides center → left.
                  Align(
                    alignment: imageAlign,
                    child: Transform.translate(
                      offset: Offset(
                        lerpDouble(0, isWide ? -6.0 : -2.0, t)!,
                        lerpDouble(0, 8.0, t)!,
                      ),
                      child: SizedBox(
                        width: imageSize,
                        height: imageSize,
                        child: ProductHero(
                          tag: widget.heroTag ??
                              'hero_carousel_${widget.product.id}',
                          imagePath: widget.product.imagePath,
                        ),
                      ),
                    ),
                  ),

                  // Collapsed + chip.
                  Positioned(
                    right: lerpDouble(4, 12, t)!,
                    top: lerpDouble(collapsedSize * 0.08, 18, t)!,
                    child: IgnorePointer(
                      ignoring: collapsedAddOpacity < 0.4,
                      child: Opacity(
                        opacity: collapsedAddOpacity,
                        child: _AddChip(
                          onPointerDown: () => _suppressCardTap = true,
                          onTap: widget.onIncrement,
                        ),
                      ),
                    ),
                  ),

                  // Expanded quantity chrome.
                  Positioned(
                    top: -16,
                    left: 0,
                    right: 0,
                    child: IgnorePointer(
                      ignoring: notchOpacity < 0.5,
                      child: Opacity(
                        opacity: notchOpacity,
                        child: Center(
                          child: Listener(
                            onPointerDown: (_) => _suppressCardTap = true,
                            child: _QuantityChrome(
                              showQuantity: _showQuantity,
                              quantity: widget.quantity,
                              onPlus: _onPlusTap,
                              onMinus: () {
                                if (widget.quantity <= 1) {
                                  widget.onDecrement();
                                  setState(() => _showQuantity = false);
                                } else {
                                  widget.onDecrement();
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProductInfoPanel extends StatelessWidget {
  const _ProductInfoPanel({
    required this.product,
    required this.isWide,
    required this.onOrder,
    required this.onOrderPointerDown,
  });

  final ProductModel product;
  final bool isWide;
  final VoidCallback onOrder;
  final VoidCallback onOrderPointerDown;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.nunito(
                  fontSize: isWide ? 19 : 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Text(
              product.formattedPrice,
              style: GoogleFonts.nunito(
                fontSize: isWide ? 16 : 14,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryPink,
              ),
            ),
          ],
        ),
        Text(
          AppStrings.sense,
          style: GoogleFonts.nunito(
            fontSize: isWide ? 16 : 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: Text(
            product.description,
            maxLines: isWide ? 4 : 3,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.nunito(
              fontSize: isWide ? 11 : 10,
              height: 1.4,
              color: AppColors.textPrimary.withOpacity(0.7),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Listener(
            onPointerDown: (_) => onOrderPointerDown(),
            child: Material(
              color: Colors.white.withOpacity(0.88),
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: onOrder,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  child: Text(
                    AppStrings.order,
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AddChip extends StatelessWidget {
  const _AddChip({
    required this.onTap,
    this.onPointerDown,
  });

  final VoidCallback onTap;
  final VoidCallback? onPointerDown;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => onPointerDown?.call(),
      child: Material(
        color: Colors.white,
        shape: const CircleBorder(),
        elevation: 3,
        shadowColor: AppColors.shadow,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: const SizedBox(
            width: 36,
            height: 36,
            child: Icon(
              Icons.add_rounded,
              size: 20,
              color: AppColors.accent,
            ),
          ),
        ),
      ),
    );
  }
}

class _QuantityChrome extends StatelessWidget {
  const _QuantityChrome({
    required this.showQuantity,
    required this.quantity,
    required this.onPlus,
    required this.onMinus,
  });

  final bool showQuantity;
  final int quantity;
  final VoidCallback onPlus;
  final VoidCallback onMinus;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      height: 42,
      width: showQuantity ? 114 : 42,
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(21),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: showQuantity
            ? Row(
                children: [
                  _StepperIcon(icon: Icons.remove_rounded, onTap: onMinus),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 160),
                      transitionBuilder: (child, anim) =>
                          ScaleTransition(scale: anim, child: child),
                      child: Text(
                        '$quantity',
                        key: ValueKey(quantity),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  _StepperIcon(icon: Icons.add_rounded, onTap: onPlus),
                ],
              )
            : InkWell(
                customBorder: const CircleBorder(),
                onTap: onPlus,
                child: const Center(
                  child: Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
      ),
    );
  }
}

class _StepperIcon extends StatelessWidget {
  const _StepperIcon({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: SizedBox(
        width: 34,
        height: 42,
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}
