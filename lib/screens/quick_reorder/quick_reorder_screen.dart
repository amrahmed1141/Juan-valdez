import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/routes/app_routes.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../cubits/cart/cart_cubit.dart';
import '../../cubits/cart/cart_state.dart';
import '../../data/mock/product_mock_data.dart';

/// Personalized quick-reorder moment after splash.
class QuickReorderScreen extends StatefulWidget {
  const QuickReorderScreen({super.key});

  @override
  State<QuickReorderScreen> createState() => _QuickReorderScreenState();
}

class _QuickReorderScreenState extends State<QuickReorderScreen>
    with TickerProviderStateMixin {
  final GlobalKey _productKey = GlobalKey();
  final GlobalKey _latteKey = GlobalKey();
  final GlobalKey _cartKey = GlobalKey();
  final GlobalKey _orderBtnKey = GlobalKey();

  late final AnimationController _enterController;
  late final AnimationController _orderController;

  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;
  late final Animation<double> _cardFade;
  late final Animation<Offset> _cardSlide;
  late final Animation<double> _ctaFade;
  late final Animation<Offset> _ctaSlide;

  late final Animation<double> _btnScale;
  late final Animation<double> _productFly;
  late final Animation<double> _latteFly;
  late final Animation<double> _confirmFade;
  late final Animation<double> _badgePulse;

  OverlayEntry? _flyOverlay;
  bool _ordering = false;
  bool _cartFilled = false;
  bool _isPickup = true;
  bool _showQuantityControl = false;
  int _orderQuantity = 1;

  @override
  void initState() {
    super.initState();

    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _headerFade = CurvedAnimation(
      parent: _enterController,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _enterController,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOutCubic),
      ),
    );

    _cardFade = CurvedAnimation(
      parent: _enterController,
      curve: const Interval(0.18, 0.7, curve: Curves.easeOut),
    );
    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.14),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _enterController,
        curve: const Interval(0.18, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _ctaFade = CurvedAnimation(
      parent: _enterController,
      curve: const Interval(0.45, 1.0, curve: Curves.easeOut),
    );
    _ctaSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _enterController,
        curve: const Interval(0.45, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _orderController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _btnScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.94)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 18,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.94, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 22,
      ),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 60),
    ]).animate(_orderController);

    _productFly = CurvedAnimation(
      parent: _orderController,
      curve: const Interval(0.12, 0.55, curve: Curves.easeInCubic),
    );

    _latteFly = CurvedAnimation(
      parent: _orderController,
      curve: const Interval(0.28, 0.72, curve: Curves.easeInCubic),
    );

    _confirmFade = CurvedAnimation(
      parent: _orderController,
      curve: const Interval(0.55, 0.78, curve: Curves.easeOut),
    );

    _badgePulse = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 55),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.25)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.25, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 25,
      ),
    ]).animate(_orderController);

    _enterController.forward();
  }

  @override
  void dispose() {
    _orderController.removeListener(_onOrderTick);
    _removeFlyOverlay();
    _enterController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  void _removeFlyOverlay() {
    _flyOverlay?.remove();
    _flyOverlay = null;
  }

  Rect? _rectOf(GlobalKey key) {
    final box = key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    final origin = box.localToGlobal(Offset.zero);
    return origin & box.size;
  }

  void _onOrderTick() {
    if (_orderController.value >= 0.58) {
      _fillCartIfNeeded();
    }
  }

  void _fillCartIfNeeded() {
    if (_cartFilled || !mounted) return;
    _cartFilled = true;
    final cart = context.read<CartCubit>();
    for (final item in ProductMockData.usualOrder) {
      cart.addToCart(
        item.product,
        quantity: item.quantity * _orderQuantity,
      );
    }
  }

  Future<void> _onOrderAgain() async {
    if (_ordering) return;
    setState(() => _ordering = true);

    final productRect = _rectOf(_productKey);
    final latteRect = _rectOf(_latteKey);
    final cartRect = _rectOf(_cartKey);

    if (productRect != null && latteRect != null && cartRect != null) {
      _showFlyOverlay(
        productRect: productRect,
        latteRect: latteRect,
        cartRect: cartRect,
      );
    }

    _orderController
      ..removeListener(_onOrderTick)
      ..reset()
      ..addListener(_onOrderTick);
    await _orderController.forward();
    _orderController.removeListener(_onOrderTick);
    _fillCartIfNeeded();

    if (!mounted) return;
    await Future<void>.delayed(const Duration(milliseconds: 220));
    _removeFlyOverlay();

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  void _showFlyOverlay({
    required Rect productRect,
    required Rect latteRect,
    required Rect cartRect,
  }) {
    _removeFlyOverlay();

    final cartCenter = cartRect.center;

    _flyOverlay = OverlayEntry(
      builder: (context) {
        return AnimatedBuilder(
          animation: _orderController,
          builder: (context, _) {
            return IgnorePointer(
              child: Stack(
                children: [
                  _FlyingProduct(
                    progress: _productFly.value,
                    start: productRect,
                    end: cartCenter,
                    imagePath: AppAssets.productGlazed,
                  ),
                  _FlyingProduct(
                    progress: _latteFly.value,
                    start: latteRect,
                    end: cartCenter,
                    imagePath: AppAssets.foamIcedLatte,
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    Overlay.of(context).insert(_flyOverlay!);
  }

  void _onSkip() {
    if (_ordering) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isWide = size.width >= 700;
    final horizontal = isWide ? size.width * 0.18 : 24.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(horizontal, 16, horizontal, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: ScaleTransition(
                  scale: _badgePulse,
                  child: _CartBadge(key: _cartKey),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeTransition(
                      opacity: _headerFade,
                      child: SlideTransition(
                        position: _headerSlide,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.quickReorderGreeting,
                              style: GoogleFonts.nunito(
                                fontSize: isWide ? 15 : 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.6,
                                color: AppColors.orange,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              AppStrings.quickReorderTitle,
                              style: GoogleFonts.nunito(
                                fontSize: isWide ? 40 : 32,
                                fontWeight: FontWeight.w700,
                                height: 1.1,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppStrings.quickReorderSubtitle,
                              style: GoogleFonts.nunito(
                                fontSize: isWide ? 16 : 14,
                                height: 1.45,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    FadeTransition(
                      opacity: _cardFade,
                      child: SlideTransition(
                        position: _cardSlide,
                        child: _UsualOrderCard(
                          productKey: _productKey,
                          latteKey: _latteKey,
                          isWide: isWide,
                          warmGlow: _isPickup,
                          showQuantityControl: _showQuantityControl,
                          orderQuantity: _orderQuantity,
                          onShowQuantityControl: () {
                            setState(() {
                              _showQuantityControl = true;
                              if (_orderQuantity == 0) _orderQuantity = 1;
                            });
                          },
                          onDecreaseQuantity: () {
                            setState(() {
                              _orderQuantity--;
                              _showQuantityControl = false;
                            });
                          },
                          onIncreaseQuantity: () {
                            setState(() {
                              _orderQuantity++;
                              _showQuantityControl = false;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FadeTransition(
                      opacity: _ctaFade,
                      child: SlideTransition(
                        position: _ctaSlide,
                        child: _FulfillmentToggle(
                          isPickup: _isPickup,
                          enabled: !_ordering,
                          onChanged: (pickup) {
                            if (_ordering) return;
                            setState(() => _isPickup = pickup);
                          },
                        ),
                      ),
                    ),
                    const Spacer(),
                    FadeTransition(
                      opacity: _confirmFade,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Center(
                          child: Text(
                            AppStrings.addedToCart,
                            style: GoogleFonts.nunito(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryPink,
                            ),
                          ),
                        ),
                      ),
                    ),
                    FadeTransition(
                      opacity: _ctaFade,
                      child: SlideTransition(
                        position: _ctaSlide,
                        child: ScaleTransition(
                          scale: _btnScale,
                          child: SizedBox(
                            key: _orderBtnKey,
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _ordering || _orderQuantity == 0
                                  ? null
                                  : _onOrderAgain,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.orange,
                                disabledBackgroundColor:
                                    AppColors.orange.withOpacity(0.7),
                                foregroundColor: AppColors.white,
                                padding: EdgeInsets.symmetric(
                                  vertical: isWide ? 18 : 16,
                                ),
                                shape: const StadiumBorder(),
                                elevation: 0,
                              ),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 220),
                                transitionBuilder: (child, anim) {
                                  return FadeTransition(
                                    opacity: anim,
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(0, 0.15),
                                        end: Offset.zero,
                                      ).animate(anim),
                                      child: child,
                                    ),
                                  );
                                },
                                child: Text(
                                  _isPickup
                                      ? AppStrings.orderForPickup
                                      : AppStrings.orderForDelivery,
                                  key: ValueKey(_isPickup),
                                  style: GoogleFonts.nunito(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    FadeTransition(
                      opacity: _ctaFade,
                      child: Center(
                        child: TextButton(
                          onPressed: _ordering ? null : _onSkip,
                          child: Text(
                            AppStrings.skip,
                            style: GoogleFonts.nunito(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
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
    );
  }
}

class _UsualOrderCard extends StatelessWidget {
  const _UsualOrderCard({
    required this.productKey,
    required this.latteKey,
    required this.isWide,
    required this.warmGlow,
    required this.showQuantityControl,
    required this.orderQuantity,
    required this.onShowQuantityControl,
    required this.onDecreaseQuantity,
    required this.onIncreaseQuantity,
  });

  final GlobalKey productKey;
  final GlobalKey latteKey;
  final bool isWide;
  final bool warmGlow;
  final bool showQuantityControl;
  final int orderQuantity;
  final VoidCallback onShowQuantityControl;
  final VoidCallback onDecreaseQuantity;
  final VoidCallback onIncreaseQuantity;

  static const double _overflowTop = 32;
  static const double _cardHeight = 156;

  @override
  Widget build(BuildContext context) {
    final stageSize = isWide ? 128.0 : 112.0;
    final productSize = isWide ? 104.0 : 92.0;
    final latteSize = isWide ? 94.0 : 84.0;
    final imageLane = stageSize + 28;

    return SizedBox(
      height: _overflowTop + _cardHeight,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: _overflowTop,
            left: 0,
            right: 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOut,
              height: _cardHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: warmGlow
                      ? const [
                          AppColors.pastelCream,
                          AppColors.white,
                          Color(0xFFFFF8F2),
                        ]
                      : const [
                          Color(0xFFFFF0F6),
                          AppColors.white,
                          AppColors.pastelPeach,
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(36),
                border: Border.all(
                  color: AppColors.divider.withOpacity(0.65),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x142D2926),
                    blurRadius: 32,
                    offset: Offset(0, 14),
                    spreadRadius: -4,
                  ),
                  BoxShadow(
                    color: Color(0x0ADA1884),
                    blurRadius: 24,
                    offset: Offset(0, 8),
                    spreadRadius: -6,
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  imageLane,
                  isWide ? 22 : 18,
                  isWide ? 22 : 18,
                  isWide ? 18 : 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'USUAL',
                      style: GoogleFonts.nunito(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                        color: AppColors.orange,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '2 Glazed Juan Valdez',
                      style: GoogleFonts.nunito(
                        fontSize: isWide ? 17 : 15,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Iced Latte',
                      style: GoogleFonts.nunito(
                        fontSize: isWide ? 17 : 15,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${(ProductMockData.usualOrderTotal * orderQuantity).toStringAsFixed(0)} EGP',
                      style: GoogleFonts.nunito(
                        fontSize: isWide ? 26 : 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryPink,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Circular product stage + side-by-side pop-out images
          Positioned(
            left: isWide ? 14 : 10,
            top: _overflowTop - 22,
            child: SizedBox(
              width: stageSize + 24,
              height: stageSize + 24,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    width: stageSize,
                    height: stageSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: warmGlow
                            ? [
                                AppColors.pastelCream,
                                AppColors.pastelPeach.withOpacity(0.85),
                              ]
                            : [
                                AppColors.pastelPink,
                                AppColors.pastelPeach.withOpacity(0.9),
                              ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (warmGlow
                                  ? AppColors.orange
                                  : AppColors.primaryPink)
                              .withOpacity(0.16),
                          blurRadius: 22,
                          offset: const Offset(0, 8),
                          spreadRadius: -4,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: -2,
                    top: -3,
                    child: _OverflowProduct(
                      key: latteKey,
                      imagePath: AppAssets.foamIcedLatte,
                      size: latteSize,
                    ),
                  ),
                  Positioned(
                    left: -8,
                    bottom: 4,
                    child: _OverflowProduct(
                      key: productKey,
                      imagePath: AppAssets.productGlazed,
                      size: productSize,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    child: _QuantityControl(
                      expanded: showQuantityControl,
                      quantity: orderQuantity,
                      onExpand: onShowQuantityControl,
                      onDecrease: onDecreaseQuantity,
                      onIncrease: onIncreaseQuantity,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverflowProduct extends StatelessWidget {
  const _OverflowProduct({
    super.key,
    required this.imagePath,
    required this.size,
  });

  final String imagePath;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        imagePath,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}

class _QuantityControl extends StatelessWidget {
  const _QuantityControl({
    required this.expanded,
    required this.quantity,
    required this.onExpand,
    required this.onDecrease,
    required this.onIncrease,
  });

  final bool expanded;
  final int quantity;
  final VoidCallback onExpand;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      width: expanded
          ? 104
          : quantity > 0
              ? 48
              : 28,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.14),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: expanded
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: onDecrease,
                  tooltip: 'Decrease quantity',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 30,
                    height: 32,
                  ),
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.remove_rounded, size: 18),
                  color: AppColors.textPrimary,
                ),
                Text(
                  '$quantity',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: onIncrease,
                  tooltip: 'Increase quantity',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 30,
                    height: 32,
                  ),
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  color: AppColors.orange,
                ),
              ],
            )
          : Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onExpand,
                borderRadius: BorderRadius.circular(18),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.add_rounded,
                        size: 18,
                        color: AppColors.orange,
                      ),
                      if (quantity > 0) ...[
                        const SizedBox(width: 2),
                        Text(
                          '$quantity',
                          style: GoogleFonts.nunito(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

/// Sliding Pick up / Delivery segmented control (outside the order card).
class _FulfillmentToggle extends StatelessWidget {
  const _FulfillmentToggle({
    required this.isPickup,
    required this.enabled,
    required this.onChanged,
  });

  final bool isPickup;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.6,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final thumbWidth = (width - 8) / 2;

          return Container(
            height: 52,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.divider),
              boxShadow: AppTheme.softShadowLight,
            ),
            child: Stack(
              children: [
                AnimatedAlign(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  alignment:
                      isPickup ? Alignment.centerLeft : Alignment.centerRight,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutBack,
                    width: thumbWidth,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.orange,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.orange.withOpacity(0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: _FulfillmentOption(
                        label: AppStrings.pickUp,
                        icon: Icons.storefront_rounded,
                        selected: isPickup,
                        onTap: enabled ? () => onChanged(true) : null,
                      ),
                    ),
                    Expanded(
                      child: _FulfillmentOption(
                        label: AppStrings.delivery,
                        icon: Icons.delivery_dining_rounded,
                        selected: !isPickup,
                        onTap: enabled ? () => onChanged(false) : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FulfillmentOption extends StatelessWidget {
  const _FulfillmentOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedScale(
          scale: selected ? 1.04 : 1.0,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutBack,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: selected ? AppColors.white : AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: selected ? AppColors.white : AppColors.textSecondary,
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

class _CartBadge extends StatelessWidget {
  const _CartBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.dark,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 2),
                boxShadow: AppTheme.softShadowLight,
              ),
              child: ClipOval(
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Image.asset(
                    AppAssets.cartBag,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
            ),
            Positioned(
              right: -1,
              top: -1,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: state.totalQuantity > 0
                      ? AppColors.primaryPink
                      : AppColors.divider,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                child: Text(
                  '${state.totalQuantity}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
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

class _FlyingProduct extends StatelessWidget {
  const _FlyingProduct({
    required this.progress,
    required this.start,
    required this.end,
    required this.imagePath,
  });

  final double progress;
  final Rect start;
  final Offset end;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    if (progress <= 0) return const SizedBox.shrink();

    final t = progress.clamp(0.0, 1.0);
    final startCenter = start.center;
    // Slight arc toward the cart.
    final mid = Offset(
      (startCenter.dx + end.dx) / 2,
      mathMin(startCenter.dy, end.dy) - 80,
    );
    final pos = _quadBezier(startCenter, mid, end, t);
    final scale = 1.0 - (0.65 * t);
    final opacity = (1.0 - t * 0.15).clamp(0.0, 1.0);
    final size = start.shortestSide * scale;

    return Positioned(
      left: pos.dx - size / 2,
      top: pos.dy - size / 2,
      child: Opacity(
        opacity: opacity,
        child: SizedBox(
          width: size,
          height: size,
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }

  static Offset _quadBezier(Offset a, Offset b, Offset c, double t) {
    final u = 1 - t;
    return Offset(
      u * u * a.dx + 2 * u * t * b.dx + t * t * c.dx,
      u * u * a.dy + 2 * u * t * b.dy + t * t * c.dy,
    );
  }

  static double mathMin(double a, double b) => a < b ? a : b;
}
