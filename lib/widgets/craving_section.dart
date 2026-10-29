import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app/routes/app_routes.dart';
import '../core/constants/app_assets.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../core/theme/app_theme.dart';
import '../cubits/home/home_cubit.dart';
import '../cubits/home/home_state.dart';
import '../data/models/product_model.dart';
import '../data/models/product_details_args.dart';
import 'product_hero.dart';

/// "What are you craving?" — sliding chips + animated horizontal product cards.
class CravingSection extends StatefulWidget {
  const CravingSection({
    super.key,
    required this.state,
    /// Distinguishes heroes when multiple [CravingSection]s stay mounted
    /// (e.g. Home + Menu in an [IndexedStack]).
    this.heroScope = 'craving',
  });

  final HomeState state;
  final String heroScope;

  @override
  State<CravingSection> createState() => _CravingSectionState();
}

class _CravingSectionState extends State<CravingSection> {
  int _categoryIndex = 0;
  double _slideDirection = 1;

  static const List<({String imagePath, String label, String category})>
      _menuItems = [
    (
      imagePath: AppAssets.butterCroissant,
      label: 'CROISSANT',
      category: AppStrings.categoryCroissant,
    ),
    (
      imagePath: AppAssets.chocolateChipCookie,
      label: 'COOKIES',
      category: AppStrings.categoryCookies,
    ),
    (
      imagePath: AppAssets.juanValdezCoffee,
      label: 'COFFEE',
      category: AppStrings.categoryCoffee,
    ),
    (
      imagePath: AppAssets.strawberryFrappe,
      label: 'COLD',
      category: AppStrings.categoryIced,
    ),
    (
      imagePath: AppAssets.menuChipBreakfast,
      label: 'FOOD',
      category: AppStrings.categoryFood,
    ),
    (
      imagePath: AppAssets.nutellaCookie,
      label: 'DESSERTS',
      category: AppStrings.categoryDesserts,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _categoryIndex = _indexForCategory(widget.state.selectedCategory);
  }

  @override
  void didUpdateWidget(covariant CravingSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.selectedCategory != widget.state.selectedCategory) {
      final next = _indexForCategory(widget.state.selectedCategory);
      setState(() {
        _slideDirection = next >= _categoryIndex ? 1.0 : -1.0;
        _categoryIndex = next;
      });
    }
  }

  int _indexForCategory(String category) {
    final i = _menuItems.indexWhere(
      (m) => m.category.toLowerCase() == category.toLowerCase(),
    );
    if (i >= 0) return i;
    switch (category) {
      case AppStrings.exploreCroissant:
        return 0;
      case AppStrings.exploreCookies:
        return 1;
      case AppStrings.exploreHotDrinks:
        return 2;
      case AppStrings.exploreIcedDrinks:
      case AppStrings.exploreFrozenDrinks:
        return 3;
      case AppStrings.exploreCombos:
        return 4;
      case AppStrings.exploreSignature:
      case AppStrings.exploreSpecialOffers:
        return 5;
      default:
        return 0;
    }
  }

  Color _washForCategory(String category) {
    switch (category) {
      case AppStrings.categoryCoffee:
      case AppStrings.exploreHotDrinks:
        return AppColors.pastelPeach;
      case AppStrings.categoryBreakfast:
      case AppStrings.categoryFood:
      case AppStrings.exploreCombos:
        return AppColors.pastelCream;
      case AppStrings.categoryIced:
      case AppStrings.exploreIcedDrinks:
      case AppStrings.exploreFrozenDrinks:
        return AppColors.pastelBlue;
      case AppStrings.categoryCroissant:
      case AppStrings.exploreCroissant:
        return AppColors.pastelYellow;
      case AppStrings.categoryCookies:
      case AppStrings.exploreCookies:
        return AppColors.pastelPeach;
      case AppStrings.categoryDesserts:
      case AppStrings.categorySignature:
      case AppStrings.exploreSignature:
      default:
        return AppColors.pastelTeal;
    }
  }

  void _onChipTap(int index) {
    final item = _menuItems[index];
    context.read<HomeCubit>().selectCategory(item.category);
    context.read<HomeCubit>().revealFullMenu();
  }

  void _addToCart(ProductModel product) {
    AppSnackbars.show(context, AppStrings.orderingDisabled);
  }

  @override
  Widget build(BuildContext context) {
    final juan_valdez = widget.state.filteredProducts;
    final selectedMenuIndex = _indexForCategory(widget.state.selectedCategory);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.whatAreYouCraving,
          style: AppTheme.sectionHeader,
        ),
        const SizedBox(height: 14),
        _SlidingMenuChips(
          items: _menuItems,
          selectedIndex: selectedMenuIndex,
          onSelected: _onChipTap,
        ),
        const SizedBox(height: 18),
        TextButton(
          onPressed: () {
            context.read<HomeCubit>().revealFullMenu();
          },
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primaryPink,
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            AppStrings.viewFullMenu,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOutCubic,
          child: widget.state.showFullMenu
              ? Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: juan_valdez.isEmpty
                      ? const _CravingEmpty()
                      : AnimatedSwitcher(
                          duration: const Duration(milliseconds: 340),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          layoutBuilder: (currentChild, previousChildren) {
                            return Stack(
                              alignment: Alignment.topCenter,
                              children: [
                                // Outgoing carousels keep their widgets for the
                                // slide, but must not register Hero tags.
                                for (final child in previousChildren)
                                  HeroMode(enabled: false, child: child),
                                if (currentChild != null) currentChild,
                              ],
                            );
                          },
                          transitionBuilder: (child, animation) {
                            final slide = Tween<Offset>(
                              begin: Offset(_slideDirection * 0.18, 0),
                              end: Offset.zero,
                            ).animate(animation);
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: slide,
                                child: child,
                              ),
                            );
                          },
                          child: _CravingCarousel(
                            key: ValueKey(widget.state.selectedCategory),
                            juan_valdez: juan_valdez,
                            washColor: _washForCategory(
                              widget.state.selectedCategory,
                            ),
                            heroScope: widget.heroScope,
                            onAdd: _addToCart,
                            onOpenDetails: (product) {
                              final tag =
                                  'hero_${widget.heroScope}_${product.id}';
                              Navigator.of(context).pushNamed(
                                AppRoutes.details,
                                arguments: ProductDetailsArgs.fromSection(
                                  product: product,
                                  products: juan_valdez,
                                  sectionTitle:
                                      widget.state.selectedCategory.toUpperCase(),
                                  heroTag: tag,
                                ),
                              );
                            },
                          ),
                        ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

// ─── Horizontal chips with sliding pink pill ─────────────────────────────────

class _SlidingMenuChips extends StatefulWidget {
  const _SlidingMenuChips({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<({String imagePath, String label, String category})> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  State<_SlidingMenuChips> createState() => _SlidingMenuChipsState();
}

class _SlidingMenuChipsState extends State<_SlidingMenuChips> {
  static const double _gap = 10;
  static const double _height = 48;

  final ScrollController _scrollController = ScrollController();
  final List<double> _widths = [];

  @override
  void initState() {
    super.initState();
    _widths.addAll(List.filled(widget.items.length, 0));
  }

  @override
  void didUpdateWidget(covariant _SlidingMenuChips oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items.length != widget.items.length) {
      _widths
        ..clear()
        ..addAll(List.filled(widget.items.length, 0));
    }
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onChipSized(int index, double width) {
    if (index < 0 || index >= _widths.length) return;
    if ((_widths[index] - width).abs() < 0.5) return;
    setState(() => _widths[index] = width);
    if (index == widget.selectedIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
    }
  }

  double get _indicatorLeft {
    var left = 0.0;
    final selected = widget.selectedIndex.clamp(0, _widths.length - 1);
    for (var i = 0; i < selected; i++) {
      left += _widths[i] + _gap;
    }
    return left;
  }

  double get _indicatorWidth {
    final selected = widget.selectedIndex.clamp(0, _widths.length - 1);
    return _widths[selected];
  }

  bool get _ready => _widths.every((w) => w > 0);

  void _scrollToSelected() {
    if (!_scrollController.hasClients || !_ready) return;
    final left = _indicatorLeft;
    final width = _indicatorWidth;
    final view = _scrollController.position.viewportDimension;
    final offset = _scrollController.offset;
    final targetCenter = left + width / 2;
    final desired = (targetCenter - view / 2).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );
    if ((desired - offset).abs() > 8) {
      _scrollController.animateTo(
        desired,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _height,
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Stack(
          children: [
            if (_ready)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutCubic,
                left: _indicatorLeft,
                top: 0,
                width: _indicatorWidth,
                height: _height,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.primaryPink,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33DA1884),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
            Row(
              children: [
                for (var i = 0; i < widget.items.length; i++) ...[
                  if (i > 0) const SizedBox(width: _gap),
                  _MenuChip(
                    imagePath: widget.items[i].imagePath,
                    label: widget.items[i].label,
                    selected: i == widget.selectedIndex,
                    onTap: () => widget.onSelected(i),
                    onSized: (w) => _onChipSized(i, w),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuChip extends StatefulWidget {
  const _MenuChip({
    required this.imagePath,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.onSized,
  });

  final String imagePath;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final ValueChanged<double> onSized;

  @override
  State<_MenuChip> createState() => _MenuChipState();
}

class _MenuChipState extends State<_MenuChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounce;

  @override
  void initState() {
    super.initState();
    _bounce = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      lowerBound: 0.94,
      upperBound: 1.0,
      value: 1.0,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _reportSize());
  }

  @override
  void didUpdateWidget(covariant _MenuChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected && !oldWidget.selected) {
      _bounce.reverse().then((_) {
        if (mounted) _bounce.forward();
      });
    }
    if (widget.selected != oldWidget.selected) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _reportSize());
    }
  }

  @override
  void dispose() {
    _bounce.dispose();
    super.dispose();
  }

  void _reportSize() {
    if (!mounted) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) {
      widget.onSized(box.size.width);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _bounce,
      child: AnimatedScale(
        scale: widget.selected ? 1.04 : 1.0,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: widget.selected ? Colors.transparent : AppColors.white,
                border: Border.all(
                  color: widget.selected
                      ? Colors.transparent
                      : AppColors.divider,
                ),
                boxShadow: widget.selected ? null : AppTheme.softShadowLight,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedScale(
                    scale: widget.selected ? 1.12 : 1.0,
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutBack,
                    child: ClipOval(
                      child: Image.asset(
                        widget.imagePath,
                        width: 22,
                        height: 22,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.coffee_rounded,
                          size: 16,
                          color: widget.selected
                              ? AppColors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.label,
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                      color: widget.selected
                          ? AppColors.white
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Animated horizontal product carousel ────────────────────────────────────

class _CravingCarousel extends StatefulWidget {
  const _CravingCarousel({
    super.key,
    required this.juan_valdez,
    required this.washColor,
    required this.heroScope,
    required this.onAdd,
    required this.onOpenDetails,
  });

  final List<ProductModel> juan_valdez;
  final Color washColor;
  final String heroScope;
  final ValueChanged<ProductModel> onAdd;
  final ValueChanged<ProductModel> onOpenDetails;

  @override
  State<_CravingCarousel> createState() => _CravingCarouselState();
}

class _CravingCarouselState extends State<_CravingCarousel> {
  static const double _gap = 10;

  late final ScrollController _scrollController;
  double _offset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() => _offset = _scrollController.offset);
      });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardWidth = _CravingCard.cardWidthFor(context);
    final height = _CravingCard.totalHeightFor(context);
    final itemExtent = cardWidth + _gap;

    return SizedBox(
      height: height,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(
          parent: PageScrollPhysics(),
        ),
        clipBehavior: Clip.none,
        padding: const EdgeInsets.only(right: 4, top: 4, bottom: 8),
        itemCount: widget.juan_valdez.length,
        itemExtent: itemExtent,
        itemBuilder: (context, index) {
          // Soft scale/fade driven by scroll — no AnimatedScale fighting the gesture.
          final itemCenter = index * itemExtent + cardWidth / 2;
          final viewportCenter = _offset + cardWidth / 2;
          final distance = (itemCenter - viewportCenter).abs();
          final t = (1 - distance / (itemExtent * 1.6)).clamp(0.0, 1.0);
          final scale = 0.92 + (0.08 * Curves.easeOut.transform(t));
          // Avoid Opacity ancestors around ProductHero — they break flights.
          return Transform.scale(
            scale: scale,
            alignment: Alignment.bottomCenter,
            filterQuality: FilterQuality.high,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _CravingCard(
                product: widget.juan_valdez[index],
                washColor: widget.washColor,
                heroTag:
                    'hero_${widget.heroScope}_${widget.juan_valdez[index].id}',
                onAdd: () => widget.onAdd(widget.juan_valdez[index]),
                onOpen: () => widget.onOpenDetails(widget.juan_valdez[index]),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Product card — cookie-card layout with floating image, pastel wash,
/// and a deep bottom-right curve for the arrow button.
class _CravingCard extends StatelessWidget {
  const _CravingCard({
    required this.product,
    required this.washColor,
    required this.onAdd,
    required this.onOpen,
    this.heroTag,
  });

  final ProductModel product;
  final Color washColor;
  final VoidCallback onAdd;
  final VoidCallback onOpen;
  final String? heroTag;

  /// Extra space above the card so the product can float outside.
  static const double overflowTop = 40;

  static double cardWidthFor(BuildContext context) {
    return MediaQuery.sizeOf(context).height * 0.20;
  }

  static double totalHeightFor(BuildContext context) {
    final cardSize = cardWidthFor(context);
    return overflowTop + cardSize + 6;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final cookieSize = size.height * 0.12;
    final cardSize = size.height * 0.20;

    return GestureDetector(
      onTap: onOpen,
      child: SizedBox(
        width: cardSize,
        height: overflowTop + cardSize,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Pastel card — sharp corners except deep bottom-right curve.
            Positioned(
              top: overflowTop,
              left: 0,
              child: Container(
                height: cardSize,
                width: cardSize,
                decoration: BoxDecoration(
                  color: washColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(75),
                  ),
                  boxShadow: AppTheme.softShadow,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    top: 32,
                    right: 32,
                    bottom: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.nunito(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.workspace_premium_rounded,
                            size: 11,
                            color: AppColors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'PREMIUM',
                            style: GoogleFonts.nunito(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              color: AppColors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        product.formattedPrice,
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryPink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Magenta arrow nestled in the deep bottom-right curve.
            Positioned(
              right: 4,
              bottom: 4,
              child: Material(
                color: AppColors.primaryPink,
                shape: const CircleBorder(),
                elevation: 2,
                shadowColor: const Color(0x44DA1884),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onAdd,
                  child: const SizedBox(
                    width: 46,
                    height: 46,
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),

            // Floating product — top half sits above the card edge.
            Positioned(
              top: overflowTop - cookieSize * 0.35,
              left: 0,
              right: 0,
              child: Center(
                child: IgnorePointer(
                  child: Container(
                    width: cookieSize,
                    height: cookieSize,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 16,
                          offset: Offset(0, 8),
                          spreadRadius: -2,
                        ),
                      ],
                    ),
                    child: ProductHero(
                      tag: heroTag ?? 'hero_craving_${product.id}',
                      imagePath: product.imagePath,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CravingEmpty extends StatelessWidget {
  const _CravingEmpty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          AppStrings.comingSoon,
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(
            fontSize: 15,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
