import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/app_colors.dart';
import '../core/theme/app_theme.dart';

/// Circular explore category tile with scroll-linked motion.
class ExploreCategoryItem extends StatefulWidget {
  const ExploreCategoryItem({
    super.key,
    required this.imagePath,
    required this.label,
    required this.onTap,
    this.scrollOffset = 0,
    this.index = 0,
  });

  final String imagePath;
  final String label;
  final VoidCallback onTap;
  final double scrollOffset;
  final int index;

  @override
  State<ExploreCategoryItem> createState() => _ExploreCategoryItemState();
}

class _ExploreCategoryItemState extends State<ExploreCategoryItem>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late final AnimationController _tapController;
  late final Animation<double> _tapScale;

  static const double _itemWidth = 100;
  static const double _gap = 14;

  @override
  void initState() {
    super.initState();
    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _tapScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.88)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.88, end: 1.06)
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
    final t = (1 - (distance / 220)).clamp(0.86, 1.0);
    return t;
  }

  Future<void> _handleTap() async {
    await _tapController.forward(from: 0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
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
          final scale = (_pressed ? 0.94 : 1.0) * scrollScale * _tapScale.value;
          return Transform.scale(
            scale: scale,
            child: child,
          );
        },
        child: SizedBox(
          width: _itemWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white,
                  boxShadow: AppTheme.softShadowLight,
                ),
                child: ClipOval(
                  child: Image.asset(
                    widget.imagePath,
                    fit: BoxFit.cover,
                    width: 84,
                    height: 84,
                    errorBuilder: (_, __, ___) => const ColoredBox(
                      color: AppColors.white,
                      child: Icon(
                        Icons.local_cafe_rounded,
                        color: AppColors.primaryPink,
                        size: 36,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.2,
                  height: 1.2,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
