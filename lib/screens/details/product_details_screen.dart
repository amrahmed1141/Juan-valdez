import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/routes/app_routes.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../cubits/home/home_cubit.dart';
import '../../cubits/home/home_state.dart';
import '../../cubits/order/order_cubit.dart';
import '../../cubits/order/order_state.dart';
import '../../data/mock/product_mock_data.dart';
import '../../data/models/buy_now_args.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/models/product_model.dart';
import '../../data/models/product_details_args.dart';
import '../../widgets/fulfillment_sheet.dart';
import '../../widgets/product_hero.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key, required this.args});

  final ProductDetailsArgs args;

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen>
    with TickerProviderStateMixin {
  static const double _viewportFraction = 0.88;
  static const int _descriptionPreviewLength = 110;
  static const Duration _flyDuration = Duration(milliseconds: 520);

  late final PageController _pageController;
  late int _currentIndex;
  double _page = 0;
  int _quantity = 1;
  bool _descriptionExpanded = false;

  ProductModel? _selectedPair;
  bool _pairSettled = false;
  bool _isFlying = false;

  final GlobalKey _mainImageKey = GlobalKey();
  final Map<String, GlobalKey> _pairThumbKeys = {};

  AnimationController? _flyController;
  OverlayEntry? _flyOverlay;

  List<ProductModel> get _products => widget.args.products;

  ProductModel get _current => _products[_currentIndex];

  bool get _hasCombo => _selectedPair != null;

  String get _displayName =>
      _hasCombo ? '${_current.name} Combo' : _current.name;

  double get _unitPrice =>
      _current.price + (_selectedPair?.price ?? 0);

  double get _totalPrice => _unitPrice * _quantity;

  String get _formattedTotal {
    final value = _totalPrice;
    final decimals = value == value.roundToDouble() ? 0 : 2;
    return 'EGP ${value.toStringAsFixed(decimals)}';
  }

  int get _displayCalories {
    final base = _caloriesFor(_current);
    if (_selectedPair == null) return base;
    return base + _caloriesFor(_selectedPair!);
  }

  int get _displayPoints {
    final base = _pointsFor(_current);
    if (_selectedPair == null) return base;
    return base + _pointsFor(_selectedPair!);
  }

  String _ratingFor(ProductModel product) {
    const scores = ['4.5', '4.6', '4.7', '4.8', '4.9', '5.0'];
    return scores[product.id.hashCode.abs() % scores.length];
  }

  int _caloriesFor(ProductModel product) {
    const options = [220, 250, 280, 310, 340, 380];
    return options[product.id.hashCode.abs() % options.length];
  }

  int _pointsFor(ProductModel product) {
    return ((product.price * 0.8).round().clamp(20, 80));
  }

  GlobalKey _thumbKeyFor(ProductModel pair) {
    return _pairThumbKeys.putIfAbsent(pair.id, GlobalKey.new);
  }

  bool get _canExpandDescription =>
      _current.description.length > _descriptionPreviewLength;

  String get _visibleDescription {
    if (!_canExpandDescription || _descriptionExpanded) {
      return _current.description;
    }
    return '${_current.description.substring(0, _descriptionPreviewLength).trimRight()}...';
  }

  @override
  void initState() {
    super.initState();
    _currentIndex =
        widget.args.initialIndex.clamp(0, _products.length - 1);
    _page = _currentIndex.toDouble();
    _pageController = PageController(
      initialPage: _currentIndex,
      viewportFraction: _viewportFraction,
    );
    _pageController.addListener(_onPageScroll);
  }

  void _onPageScroll() {
    if (!_pageController.hasClients) return;
    final page = _pageController.page;
    if (page == null) return;
    setState(() => _page = page);
  }

  void _clearCombo() {
    _removeFlyOverlay();
    setState(() {
      _selectedPair = null;
      _pairSettled = false;
      _isFlying = false;
    });
  }

  void _removeFlyOverlay() {
    _flyOverlay?.remove();
    _flyOverlay = null;
    _flyController?.dispose();
    _flyController = null;
  }

  Rect? _rectFromKey(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return null;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  Future<void> _flyPairIntoCard(ProductModel pair) async {
    if (_isFlying) return;

    final start = _rectFromKey(_thumbKeyFor(pair));
    final mainRect = _rectFromKey(_mainImageKey);
    if (start == null || mainRect == null) {
      setState(() {
        _selectedPair = pair;
        _pairSettled = true;
      });
      return;
    }

    final endSize = Size(
      mainRect.width * 0.42,
      mainRect.height * 0.58,
    );
    final end = Rect.fromLTWH(
      mainRect.left + mainRect.width * 0.52,
      mainRect.top + (mainRect.height - endSize.height) / 2,
      endSize.width,
      endSize.height,
    );

    _removeFlyOverlay();
    final controller = AnimationController(
      vsync: this,
      duration: _flyDuration,
    );
    _flyController = controller;
    final animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOutCubic,
    );
    final rectTween = RectTween(begin: start, end: end);

    setState(() {
      _selectedPair = pair;
      _pairSettled = false;
      _isFlying = true;
    });

    _flyOverlay = OverlayEntry(
      builder: (context) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final rect = rectTween.evaluate(animation)!;
            final scale = 0.85 + (0.15 * animation.value);
            return Positioned(
              left: rect.left,
              top: rect.top,
              width: rect.width,
              height: rect.height,
              child: IgnorePointer(
                child: Transform.scale(
                  scale: scale,
                  child: child,
                ),
              ),
            );
          },
          child: Image.asset(
            pair.imagePath,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
        );
      },
    );

    Overlay.of(context).insert(_flyOverlay!);
    await controller.forward();
    if (!mounted) return;

    _removeFlyOverlay();
    setState(() {
      _pairSettled = true;
      _isFlying = false;
    });
  }

  Future<void> _onPairTap(ProductModel pair) async {
    if (_isFlying) return;

    if (_selectedPair?.id == pair.id) {
      _clearCombo();
      return;
    }

    if (_selectedPair != null && _pairSettled) {
      // Swap without re-flying from far away — quick settle + short fly.
      setState(() {
        _pairSettled = false;
        _selectedPair = null;
      });
      await Future<void>.delayed(const Duration(milliseconds: 40));
      if (!mounted) return;
    }

    await _flyPairIntoCard(pair);
  }

  @override
  void dispose() {
    _removeFlyOverlay();
    _pageController.removeListener(_onPageScroll);
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    _removeFlyOverlay();
    setState(() {
      _currentIndex = index;
      _quantity = 1;
      _descriptionExpanded = false;
      _selectedPair = null;
      _pairSettled = false;
      _isFlying = false;
    });
  }

  void _addToCart() {
    AppSnackbars.show(context, AppStrings.orderingDisabled);
  }

  Future<void> _buyNow() async {
    final active = context.read<OrderCubit>().state.activeOrder;
    if (active != null) {
      await Navigator.of(context).pushNamed(
        AppRoutes.orderDetails,
        arguments: active.id,
      );
      return;
    }

    final home = context.read<HomeCubit>().state;
    final choice = await showFulfillmentSheet(
      context: context,
      initialMode: FulfillmentMode.dineIn,
      initialStore: home.selectedStore,
    );
    if (!mounted || choice == null) return;

    context.read<HomeCubit>().setFulfillment(
          mode: FulfillmentMode.dineIn,
          store: choice.store,
        );

    final items = <CartItemModel>[
      CartItemModel(product: _current, quantity: _quantity),
    ];
    final pair = _selectedPair;
    if (pair != null) {
      items.add(CartItemModel(product: pair, quantity: _quantity));
    }

    await Navigator.of(context).pushNamed(
      AppRoutes.buyNowCheckout,
      arguments: BuyNowArgs(
        items: items,
        mode: FulfillmentMode.dineIn,
        store: choice.store,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canSwipe = _products.length > 1;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final routeAnimation = ModalRoute.of(context)?.animation;

    final chromeFade = routeAnimation != null
        ? CurvedAnimation(
            parent: routeAnimation,
            curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
            reverseCurve: const Interval(0.2, 1.0, curve: Curves.easeInCubic),
          )
        : null;
    final headerSlide = routeAnimation != null
        ? Tween<Offset>(
            begin: const Offset(0, -0.2),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: routeAnimation,
              curve: const Interval(0.15, 0.9, curve: Curves.easeOutCubic),
            ),
          )
        : null;
    final panelSlide = routeAnimation != null
        ? Tween<Offset>(
            begin: const Offset(0, 0.18),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: routeAnimation,
              curve: const Interval(0.12, 1.0, curve: Curves.easeOutCubic),
            ),
          )
        : null;

    final headerWidget = Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: _DetailsHeader(
        sectionTitle: widget.args.sectionTitle,
        onBack: () => Navigator.of(context).pop(),
      ),
    );

    final panelWidget = _GlassInfoPanel(
      bottomInset: bottomInset,
      canSwipe: canSwipe,
      pageCount: _products.length,
      currentIndex: _currentIndex,
      productKey: _current.id,
      name: _displayName,
      rating: _ratingFor(_current),
      calories: _displayCalories,
      points: _displayPoints,
      description: _visibleDescription,
      canExpand: _canExpandDescription,
      expanded: _descriptionExpanded,
      pairs: ProductMockData.pairsWellWith(_current),
      selectedPairId: _selectedPair?.id,
      pairThumbKeyFor: _thumbKeyFor,
      onToggleDescription: _canExpandDescription
          ? () {
              setState(() {
                _descriptionExpanded = !_descriptionExpanded;
              });
            }
          : null,
      onPairTap: _onPairTap,
      onAddToCart: _addToCart,
      onBuyNow: _buyNow,
    );

    Widget fadeChrome(Widget child) {
      if (chromeFade == null) return child;
      return FadeTransition(opacity: chromeFade, child: child);
    }

    // Fully opaque wash — translucent pink let the home route bleed through
    // because the Hero route uses opaque: false.
    final backdrop = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(AppColors.cream, AppColors.pastelPink, 0.55)!,
            AppColors.backgroundAlt,
            AppColors.cream,
          ],
        ),
      ),
    );

    return Scaffold(
      // Transparent only during chrome fade-in; backdrop itself is opaque.
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Solid base so nothing from the previous route can show through.
          const Positioned.fill(
            child: ColoredBox(color: AppColors.cream),
          ),
          Positioned.fill(child: fadeChrome(backdrop)),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                if (headerSlide != null)
                  FadeTransition(
                    opacity: chromeFade!,
                    child: SlideTransition(
                      position: headerSlide,
                      child: headerWidget,
                    ),
                  )
                else
                  headerWidget,
                const SizedBox(height: 8),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _products.length,
                    physics: canSwipe
                        ? const BouncingScrollPhysics()
                        : const NeverScrollableScrollPhysics(),
                    onPageChanged: _onPageChanged,
                    itemBuilder: (context, index) {
                      final product = _products[index];
                      final distance = (_page - index).abs();
                      final scale =
                          (1 - (distance * 0.12)).clamp(0.88, 1.0);
                      final opacity =
                          (1 - (distance * 0.35)).clamp(0.55, 1.0);

                      final isCurrent = index == _currentIndex;
                      final isOpeningHero =
                          index == widget.args.initialIndex;
                      final card = _ProductCard(
                        product: product,
                        quantity: isCurrent ? _quantity : 1,
                        totalPrice: isCurrent
                            ? _formattedTotal
                            : 'EGP ${product.price.toStringAsFixed(0)}',
                        isHero: isOpeningHero,
                        heroTag: widget.args.effectiveHeroTag,
                        chromeAnimation: isOpeningHero ? chromeFade : null,
                        imageAreaKey: isCurrent ? _mainImageKey : null,
                        pairedProduct: isCurrent && _pairSettled
                            ? _selectedPair
                            : null,
                        reservePairSlot: isCurrent &&
                            (_pairSettled ||
                                (_isFlying && _selectedPair != null)),
                        onDecrement: isCurrent
                            ? () {
                                if (_quantity > 1) {
                                  setState(() => _quantity--);
                                }
                              }
                            : null,
                        onIncrement: isCurrent
                            ? () => setState(() => _quantity++)
                            : null,
                      );

                      // Keep the opening Hero free of ancestor Opacity /
                      // Transform so its flight end-rect stays accurate.
                      if (isOpeningHero && distance < 0.01) {
                        return card;
                      }

                      return Transform.scale(
                        scale: scale,
                        child: Opacity(
                          opacity: opacity,
                          child: card,
                        ),
                      );
                    },
                  ),
                ),
                if (panelSlide != null)
                  FadeTransition(
                    opacity: chromeFade!,
                    child: SlideTransition(
                      position: panelSlide,
                      child: panelWidget,
                    ),
                  )
                else
                  panelWidget,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Frosted bottom sheet: name + stats + pairs + CTAs.
/// Sized to children — no empty vertical space.
class _GlassInfoPanel extends StatelessWidget {
  const _GlassInfoPanel({
    required this.bottomInset,
    required this.canSwipe,
    required this.pageCount,
    required this.currentIndex,
    required this.productKey,
    required this.name,
    required this.rating,
    required this.calories,
    required this.points,
    required this.description,
    required this.canExpand,
    required this.expanded,
    required this.pairs,
    required this.onPairTap,
    required this.onAddToCart,
    required this.onBuyNow,
    required this.pairThumbKeyFor,
    this.selectedPairId,
    this.onToggleDescription,
  });

  final double bottomInset;
  final bool canSwipe;
  final int pageCount;
  final int currentIndex;
  final String productKey;
  final String name;
  final String rating;
  final int calories;
  final int points;
  final String description;
  final bool canExpand;
  final bool expanded;
  final List<ProductModel> pairs;
  final String? selectedPairId;
  final GlobalKey Function(ProductModel pair) pairThumbKeyFor;
  final ValueChanged<ProductModel> onPairTap;
  final VoidCallback? onToggleDescription;
  final VoidCallback onAddToCart;
  final VoidCallback onBuyNow;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.55),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(
                color: AppColors.white.withOpacity(0.7),
                width: 1.2,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withOpacity(0.1),
                blurRadius: 24,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              22,
              14,
              22,
              bottomInset > 0 ? bottomInset : 14,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (canSwipe) ...[
                  _PageIndicator(
                    count: pageCount,
                    currentIndex: currentIndex,
                  ),
                  const SizedBox(height: 12),
                ],
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    final offset = Tween<Offset>(
                      begin: const Offset(0, 0.05),
                      end: Offset.zero,
                    ).animate(animation);
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: offset,
                        child: child,
                      ),
                    );
                  },
                  child: _ProductInfoBlock(
                    key: ValueKey(productKey),
                    name: name,
                    rating: rating,
                    calories: calories,
                    points: points,
                    description: description,
                    canExpand: canExpand,
                    expanded: expanded,
                    pairs: pairs,
                    selectedPairId: selectedPairId,
                    pairThumbKeyFor: pairThumbKeyFor,
                    onPairTap: onPairTap,
                    onToggleDescription: onToggleDescription,
                  ),
                ),
                const SizedBox(height: 14),
                _BottomActions(
                  onAddToCart: onAddToCart,
                  onBuyNow: onBuyNow,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailsHeader extends StatelessWidget {
  const _DetailsHeader({
    required this.sectionTitle,
    required this.onBack,
  });

  final String sectionTitle;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CircleIconButton(
          icon: Icons.arrow_back_rounded,
          onTap: onBack,
        ),
        Expanded(
          child: Center(
            child: _SectionChip(title: sectionTitle),
          ),
        ),
        // Same width as back button so the section chip stays centered.
        const SizedBox(width: 42),
      ],
    );
  }
}

class _SectionChip extends StatelessWidget {
  const _SectionChip({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.trendingSection,
            AppColors.backgroundAlt,
            AppColors.pastelPink.withOpacity(0.55),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.primaryPink.withOpacity(0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPink.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.primaryPink,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Ink(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.85),
            shape: BoxShape.circle,
            boxShadow: AppTheme.softShadowLight,
            border: Border.all(color: AppColors.divider),
          ),
          child: Icon(icon, size: 20, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.quantity,
    required this.totalPrice,
    required this.isHero,
    this.heroTag,
    this.chromeAnimation,
    this.imageAreaKey,
    this.pairedProduct,
    this.reservePairSlot = false,
    this.onDecrement,
    this.onIncrement,
  });

  final ProductModel product;
  final int quantity;
  final String totalPrice;
  final bool isHero;
  final String? heroTag;
  /// Fades card chrome only — never the [ProductHero] image.
  final Animation<double>? chromeAnimation;
  final GlobalKey? imageAreaKey;
  final ProductModel? pairedProduct;
  final bool reservePairSlot;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;

  @override
  Widget build(BuildContext context) {
    final tag = heroTag ?? 'product_${product.id}';
    final mainImage = isHero
        ? ProductHero(
            tag: tag,
            imagePath: product.imagePath,
          )
        : Image.asset(
            product.imagePath,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            gaplessPlayback: true,
          );

    final showPair = pairedProduct != null;
    final useComboLayout = showPair || reservePairSlot;

    Widget maybeFadeChrome(Widget child) {
      final anim = chromeAnimation;
      if (anim == null) return child;
      return FadeTransition(opacity: anim, child: child);
    }

    final shell = DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(AppColors.white, product.pastelColor, 0.35)!,
            AppColors.white,
          ],
        ),
      ),
    );

    final favoriteButton = Align(
      alignment: Alignment.topRight,
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          final liked = state.isFavorite(product.id);
          return Material(
            color: AppColors.white,
            shape: const CircleBorder(),
            elevation: 1,
            shadowColor: AppColors.shadow,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                context.read<HomeCubit>().toggleFavorite(product);
              },
              child: SizedBox(
                width: 40,
                height: 40,
                child: Icon(
                  liked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  size: 20,
                  color: liked
                      ? AppColors.primaryPink
                      : AppColors.textPrimary,
                ),
              ),
            ),
          );
        },
      ),
    );

    final bottomRow = Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _QuantityPill(
          quantity: quantity,
          onDecrement: onDecrement,
          onIncrement: onIncrement,
        ),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Total Price',
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: Text(
                totalPrice,
                key: ValueKey(totalPrice),
                style: GoogleFonts.nunito(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  height: 1.1,
                ),
              ),
            ),
          ],
        ),
      ],
    );

    final imageArea = KeyedSubtree(
      key: imageAreaKey,
      child: useComboLayout
          ? Row(
              children: [
                Expanded(
                  flex: 11,
                  child: Center(child: mainImage),
                ),
                Expanded(
                  flex: 9,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 180),
                    opacity: showPair ? 1 : 0,
                    child: showPair
                        ? Padding(
                            padding: const EdgeInsets.only(left: 4, right: 2),
                            child: Image.asset(
                              pairedProduct!.imagePath,
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.high,
                            ),
                          )
                        : const SizedBox.expand(),
                  ),
                ),
              ],
            )
          : Center(child: mainImage),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 4, 10, 12),
      child: Stack(
        children: [
          Positioned.fill(child: maybeFadeChrome(shell)),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            child: Column(
              children: [
                maybeFadeChrome(favoriteButton),
                Expanded(child: imageArea),
                const SizedBox(height: 8),
                maybeFadeChrome(bottomRow),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityPill extends StatelessWidget {
  const _QuantityPill({
    required this.quantity,
    this.onDecrement,
    this.onIncrement,
  });

  final int quantity;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.exploreSection,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MiniQtyBtn(
            icon: Icons.remove_rounded,
            onTap: onDecrement,
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.textPrimary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$quantity',
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.white,
              ),
            ),
          ),
          _MiniQtyBtn(
            icon: Icons.add_rounded,
            onTap: onIncrement,
          ),
        ],
      ),
    );
  }
}

class _MiniQtyBtn extends StatelessWidget {
  const _MiniQtyBtn({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 18, color: AppColors.textPrimary),
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({
    required this.count,
    required this.currentIndex,
  });

  final int count;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count.clamp(0, 8), (index) {
        final visibleCount = count > 8 ? 8 : count;
        final active = count > 8
            ? (currentIndex / (count - 1) * (visibleCount - 1)).round() ==
                index
            : index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 18 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: active
                ? AppColors.textPrimary
                : AppColors.navInactive.withOpacity(0.45),
            borderRadius: BorderRadius.circular(20),
          ),
        );
      }),
    );
  }
}

class _ProductInfoBlock extends StatelessWidget {
  const _ProductInfoBlock({
    super.key,
    required this.name,
    required this.rating,
    required this.calories,
    required this.points,
    required this.description,
    required this.canExpand,
    required this.expanded,
    required this.pairs,
    required this.pairThumbKeyFor,
    required this.onPairTap,
    this.selectedPairId,
    this.onToggleDescription,
  });

  final String name;
  final String rating;
  final int calories;
  final int points;
  final String description;
  final bool canExpand;
  final bool expanded;
  final List<ProductModel> pairs;
  final String? selectedPairId;
  final GlobalKey Function(ProductModel pair) pairThumbKeyFor;
  final ValueChanged<ProductModel> onPairTap;
  final VoidCallback? onToggleDescription;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: GoogleFonts.nunito(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        _InfoChipsRow(
          calories: calories,
          rating: rating,
          points: points,
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: onToggleDescription,
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: description,
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (canExpand)
                  TextSpan(
                    text: expanded ? '  See less' : '  See more..',
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      height: 1.45,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (pairs.isNotEmpty) ...[
          const SizedBox(height: 14),
          _PairsWellWithStrip(
            pairs: pairs,
            selectedPairId: selectedPairId,
            pairThumbKeyFor: pairThumbKeyFor,
            onPairTap: onPairTap,
          ),
        ],
      ],
    );
  }
}

/// Staggered fade/slide stats: cal · rating · points (no chip borders).
class _InfoChipsRow extends StatelessWidget {
  const _InfoChipsRow({
    required this.calories,
    required this.rating,
    required this.points,
  });

  final int calories;
  final String rating;
  final int points;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      _InfoStat(
        label: '~$calories cal',
        iconPath: AppAssets.iconKcal,
      ),
      _InfoStat(
        label: rating,
        leading: const Icon(
          Icons.star_rounded,
          size: 16,
          color: AppColors.orange,
        ),
      ),
      _InfoStat(
        label: '+$points pts',
        iconPath: AppAssets.iconCoin,
      ),
    ];

    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          Flexible(
            child: TweenAnimationBuilder<double>(
              key: ValueKey(i),
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 280 + (i * 70)),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 8 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: items[i],
            ),
          ),
        ],
      ],
    );
  }
}

class _InfoStat extends StatelessWidget {
  const _InfoStat({
    required this.label,
    this.iconPath,
    this.leading,
  });

  final String label;
  final String? iconPath;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leading != null) ...[
          leading!,
          const SizedBox(width: 4),
        ] else if (iconPath != null) ...[
          Image.asset(
            iconPath!,
            width: 14,
            height: 14,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
          const SizedBox(width: 4),
        ],
        Flexible(
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _PairsWellWithStrip extends StatelessWidget {
  const _PairsWellWithStrip({
    required this.pairs,
    required this.pairThumbKeyFor,
    required this.onPairTap,
    this.selectedPairId,
  });

  final List<ProductModel> pairs;
  final String? selectedPairId;
  final GlobalKey Function(ProductModel pair) pairThumbKeyFor;
  final ValueChanged<ProductModel> onPairTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Pairs well with',
          style: GoogleFonts.nunito(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 86,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: pairs.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final pair = pairs[index];
              final selected = selectedPairId == pair.id;
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: Duration(milliseconds: 320 + (index * 80)),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(16 * (1 - value), 0),
                      child: Transform.scale(
                        scale: 0.92 + (0.08 * value),
                        child: child,
                      ),
                    ),
                  );
                },
                child: _PairMiniCard(
                  product: pair,
                  selected: selected,
                  imageKey: pairThumbKeyFor(pair),
                  onTap: () => onPairTap(pair),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PairMiniCard extends StatelessWidget {
  const _PairMiniCard({
    required this.product,
    required this.onTap,
    required this.imageKey,
    this.selected = false,
  });

  final ProductModel product;
  final VoidCallback onTap;
  final GlobalKey imageKey;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          width: 118,
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.orange.withOpacity(0.12)
                : AppColors.white.withOpacity(0.78),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? AppColors.orange
                  : AppColors.divider.withOpacity(0.8),
              width: selected ? 1.6 : 1,
            ),
            boxShadow: AppTheme.softShadowLight,
          ),
          child: Row(
            children: [
              Container(
                key: imageKey,
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: product.pastelColor.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(4),
                child: Opacity(
                  opacity: selected ? 0.35 : 1,
                  child: Image.asset(
                    product.imagePath,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.nunito(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.formattedPrice,
                      style: GoogleFonts.nunito(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.onAddToCart,
    required this.onBuyNow,
  });

  final VoidCallback onAddToCart;
  final VoidCallback onBuyNow;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderCubit, OrderState>(
      buildWhen: (prev, next) =>
          prev.activeOrder?.id != next.activeOrder?.id ||
          prev.activeOrder?.status != next.activeOrder?.status,
      builder: (context, orderState) {
        final hasActive = orderState.activeOrder != null;
        final ctaLabel =
            hasActive ? AppStrings.viewOrderStatus : AppStrings.dineIn;

        return Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 52,
                child: Material(
                  color: AppColors.exploreSection.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(28),
                  child: InkWell(
                    onTap: onAddToCart,
                    borderRadius: BorderRadius.circular(28),
                    child: Center(
                      child: Text(
                        AppStrings.viewDetails,
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 52,
                child: Material(
                  color: AppColors.brandRed,
                  borderRadius: BorderRadius.circular(28),
                  child: InkWell(
                    onTap: onBuyNow,
                    borderRadius: BorderRadius.circular(28),
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: Text(
                          ctaLabel,
                          key: ValueKey(ctaLabel),
                          style: GoogleFonts.nunito(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
