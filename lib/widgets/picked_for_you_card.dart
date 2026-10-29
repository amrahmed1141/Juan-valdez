import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../data/models/product_model.dart';
import 'product_hero.dart';

/// Horizontal promo card — dark body with product image stacked over the edge.
class PickedForYouCard extends StatefulWidget {
  const PickedForYouCard({
    super.key,
    required this.product,
    required this.isFavorite,
    required this.onFavorite,
    required this.onAddToCart,
    required this.onOpenDetails,
    this.heroTag,
  });

  final ProductModel product;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onAddToCart;
  final VoidCallback onOpenDetails;
  final String? heroTag;

  @override
  State<PickedForYouCard> createState() => _PickedForYouCardState();
}

class _PickedForYouCardState extends State<PickedForYouCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  bool _adding = false;

  static const double _cardHeight = 164;
  static const double _overflowY = 32;
  static const double _imageWidth = 150;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleAdd() async {
    if (_adding) return;
    setState(() => _adding = true);
    widget.onAddToCart();
    await Future<void>.delayed(const Duration(milliseconds: 280));
    if (mounted) setState(() => _adding = false);
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: GestureDetector(
          onTap: widget.onOpenDetails,
          child: SizedBox(
            height: _cardHeight + _overflowY,
            width: double.infinity,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Promo body — same gradient as Order Again
                Positioned(
                  top: _overflowY / 2,
                  left: 0,
                  right: 18,
                  child: Container(
                    height: _cardHeight,
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
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: AppColors.divider.withOpacity(0.65),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x142D2926),
                          blurRadius: 24,
                          offset: Offset(0, 10),
                          spreadRadius: -4,
                        ),
                        BoxShadow(
                          color: Color(0x0ADA1884),
                          blurRadius: 20,
                          offset: Offset(0, 6),
                          spreadRadius: -6,
                        ),
                      ],
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          right: 28,
                          top: 16,
                          child: _AccentBlob(
                            size: 52,
                            color: AppColors.orange.withOpacity(0.18),
                          ),
                        ),
                        Positioned(
                          right: 12,
                          bottom: 20,
                          child: _AccentBlob(
                            size: 24,
                            color: AppColors.primaryPink.withOpacity(0.2),
                          ),
                        ),
                        Positioned(
                          right: 72,
                          bottom: 10,
                          child: _AccentBlob(
                            size: 12,
                            color: AppColors.orange.withOpacity(0.14),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 14, 132, 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      product.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.nunito(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        height: 1.1,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: widget.onFavorite,
                                    behavior: HitTestBehavior.opaque,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        left: 4,
                                        top: 2,
                                      ),
                                      child: Icon(
                                        widget.isFavorite
                                            ? Icons.favorite_rounded
                                            : Icons.favorite_border_rounded,
                                        size: 20,
                                        color: widget.isFavorite
                                            ? AppColors.primaryPink
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                product.highlight ?? AppStrings.pickedForYouHint,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.nunito(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  height: 1.2,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                product.formattedPrice,
                                style: GoogleFonts.nunito(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  height: 1.2,
                                  color: AppColors.orange,
                                ),
                              ),
                              const Spacer(),
                              AnimatedScale(
                                scale: _adding ? 0.96 : 1,
                                duration: const Duration(milliseconds: 160),
                                child: SizedBox(
                                  height: 34,
                                  child: FilledButton(
                                    onPressed: _handleAdd,
                                    style: FilledButton.styleFrom(
                                      backgroundColor: AppColors.primaryPink,
                                      foregroundColor: AppColors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      shape: const StadiumBorder(),
                                    ),
                                    child: Text(
                                      AppStrings.addToCart,
                                      style: GoogleFonts.nunito(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Stacked iced coffee — overflows top, bottom, and right
                Positioned(
                  right: -6,
                  top: 0,
                  bottom: 0,
                  width: _imageWidth,
                  child: IgnorePointer(
                    child: ProductHero(
                      tag: widget.heroTag ?? 'hero_picked_${product.id}',
                      imagePath: product.imagePath,
                      alignment: Alignment.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AccentBlob extends StatelessWidget {
  const _AccentBlob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size * 0.7,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size),
      ),
    );
  }
}
