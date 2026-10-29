import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app/routes/app_routes.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../core/theme/app_theme.dart';
import '../cubits/home/home_cubit.dart';
import '../cubits/order/order_cubit.dart';
import '../cubits/order/order_state.dart';
import '../data/mock/product_mock_data.dart';
import '../data/models/cart_item_model.dart';
import '../data/models/product_model.dart';

/// Home "As Your Usual" — one-tap reorder of the habitual combo.
class UsualSection extends StatefulWidget {
  const UsualSection({super.key});

  @override
  State<UsualSection> createState() => _UsualSectionState();
}

class _UsualSectionState extends State<UsualSection>
    with TickerProviderStateMixin {
  static const double _overflowTop = 24;
  static const double _cardMinHeight = 148;

  late final AnimationController _enter;
  late final AnimationController _float;
  late final AnimationController _ctaPulse;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  int _quantity = 1;
  bool _ordering = false;
  bool _success = false;

  List<CartItemModel> get _items => ProductMockData.usualOrder;

  double get _total => ProductMockData.usualOrderTotal * _quantity;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 640),
    );
    _fade = CurvedAnimation(parent: _enter, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _enter, curve: Curves.easeOutCubic),
    );

    _float = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);

    _ctaPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );

    _enter.forward();
  }

  @override
  void dispose() {
    _enter.dispose();
    _float.dispose();
    _ctaPulse.dispose();
    super.dispose();
  }

  void _bumpQty(int delta) {
    final next = (_quantity + delta).clamp(1, 9);
    if (next == _quantity) return;
    HapticFeedback.selectionClick();
    setState(() => _quantity = next);
  }

  Future<void> _orderAgain() async {
    if (_ordering) return;

    final orders = context.read<OrderCubit>().state;
    if (orders.activeOrder != null) {
      AppSnackbars.show(context, AppStrings.usualActiveVisit);
      return;
    }

    setState(() {
      _ordering = true;
      _success = false;
    });
    await _ctaPulse.forward();
    await _ctaPulse.reverse();

    if (!mounted) return;

    final home = context.read<HomeCubit>().state;
    final scaled = _items
        .map(
          (item) => item.copyWith(quantity: item.quantity * _quantity),
        )
        .toList();

    context.read<HomeCubit>().checkInAtCafe(
          store: home.selectedStore,
          table: home.tableNumber ?? '4',
        );
    context.read<OrderCubit>().startDineInVisit(
          store: context.read<HomeCubit>().state.selectedStore,
          tableNumber: context.read<HomeCubit>().state.tableNumber,
          items: scaled,
        );

    HapticFeedback.mediumImpact();
    if (!mounted) return;
    setState(() {
      _ordering = false;
      _success = true;
    });
    AppSnackbars.show(context, AppStrings.usualVisitStarted);

    await Future<void>.delayed(const Duration(milliseconds: 1400));
    if (mounted) setState(() => _success = false);
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 420;
    final items = _items;

    if (items.isEmpty) {
      return const _UsualEmpty();
    }

    final primary = items.first.product;
    final secondary = items.length > 1 ? items[1].product : null;
    final stageSize = isWide ? 108.0 : 96.0;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.asYourUsual, style: AppTheme.sectionHeader),
            const SizedBox(height: 4),
            Text(
              AppStrings.asYourUsualHint,
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 18),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: _overflowTop),
                  child: _UsualCardBody(
                    minHeight: _cardMinHeight,
                    contentLeft: stageSize + 20,
                    primary: primary,
                    secondary: secondary,
                    total: _total,
                    quantity: _quantity,
                    ordering: _ordering,
                    success: _success,
                    onDecrease: () => _bumpQty(-1),
                    onIncrease: () => _bumpQty(1),
                    onOrder: _orderAgain,
                    ctaScale:
                        Tween<double>(begin: 1, end: 0.94).animate(_ctaPulse),
                  ),
                ),
                Positioned(
                  left: isWide ? 10 : 6,
                  top: 0,
                  child: _FloatingProductStage(
                    stageSize: stageSize,
                    primary: primary,
                    secondary: secondary,
                    float: reduceMotion ? null : _float,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _UsualCardBody extends StatelessWidget {
  const _UsualCardBody({
    required this.minHeight,
    required this.contentLeft,
    required this.primary,
    required this.secondary,
    required this.total,
    required this.quantity,
    required this.ordering,
    required this.success,
    required this.onDecrease,
    required this.onIncrease,
    required this.onOrder,
    required this.ctaScale,
  });

  final double minHeight;
  final double contentLeft;
  final ProductModel primary;
  final ProductModel? secondary;
  final double total;
  final int quantity;
  final bool ordering;
  final bool success;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onOrder;
  final Animation<double> ctaScale;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderCubit, OrderState>(
      builder: (context, orderState) {
        final hasActive = orderState.activeOrder != null;

        return Container(
          constraints: BoxConstraints(minHeight: minHeight),
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
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: AppColors.divider.withValues(alpha: 0.65),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x142D2926),
                blurRadius: 28,
                offset: Offset(0, 12),
                spreadRadius: -4,
              ),
              BoxShadow(
                color: Color(0x147A1E2B),
                blurRadius: 20,
                offset: Offset(0, 6),
                spreadRadius: -6,
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(contentLeft, 14, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.brandGold.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        AppStrings.usualChip,
                        style: GoogleFonts.nunito(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                          color: AppColors.brandGold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        AppSnackbars.show(context, AppStrings.comingSoon);
                      },
                      child: Text(
                        AppStrings.editUsual,
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  primary.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (secondary != null)
                  Text(
                    secondary!.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                      color: AppColors.textSecondary,
                    ),
                  ),
                const SizedBox(height: 8),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  transitionBuilder: (child, anim) {
                    return FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.2),
                          end: Offset.zero,
                        ).animate(anim),
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    '${total.toStringAsFixed(0)} EGP',
                    key: ValueKey(total),
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.fade,
                    style: GoogleFonts.nunito(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.brandRed,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _QtyStepper(
                      quantity: quantity,
                      onDecrease: onDecrease,
                      onIncrease: onIncrease,
                    ),
                    const Spacer(),
                    ScaleTransition(
                      scale: ctaScale,
                      child: AnimatedScale(
                        scale: ordering ? 0.96 : 1,
                        duration: const Duration(milliseconds: 140),
                        child: SizedBox(
                          height: 36,
                          child: FilledButton(
                            onPressed: hasActive || ordering ? null : onOrder,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.brandRed,
                              disabledBackgroundColor:
                                  AppColors.brandRed.withValues(alpha: 0.45),
                              foregroundColor: AppColors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: const StadiumBorder(),
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: success
                                  ? const Icon(
                                      Icons.check_rounded,
                                      key: ValueKey('ok'),
                                      size: 18,
                                    )
                                  : Text(
                                      AppStrings.orderUsualAgain,
                                      key: const ValueKey('cta'),
                                      style: GoogleFonts.nunito(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FloatingProductStage extends StatelessWidget {
  const _FloatingProductStage({
    required this.stageSize,
    required this.primary,
    required this.secondary,
    required this.float,
  });

  final double stageSize;
  final ProductModel primary;
  final ProductModel? secondary;
  final Animation<double>? float;

  @override
  Widget build(BuildContext context) {
    final primarySize = stageSize * 0.88;
    final secondarySize = stageSize * 0.78;

    Widget stage = SizedBox(
      width: stageSize + 28,
      height: stageSize + 28,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            width: stageSize,
            height: stageSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.pastelCream,
                  AppColors.pastelPeach.withValues(alpha: 0.88),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.brandRed.withValues(alpha: 0.14),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                  spreadRadius: -4,
                ),
              ],
            ),
          ),
          if (secondary != null)
            Positioned(
              right: -4,
              top: -2,
              child: _ProductImage(
                path: secondary!.imagePath,
                size: secondarySize,
                angle: 0.04,
              ),
            ),
          Positioned(
            left: secondary != null ? -10 : 0,
            bottom: secondary != null ? 2 : null,
            child: _ProductImage(
              path: primary.imagePath,
              size: primarySize,
              angle: -0.05,
            ),
          ),
        ],
      ),
    );

    final anim = float;
    if (anim == null) return stage;

    return AnimatedBuilder(
      animation: anim,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(anim.value);
        final dy = (t - 0.5) * 8;
        final rot = (t - 0.5) * 0.04;
        return Transform.translate(
          offset: Offset(0, dy),
          child: Transform.rotate(angle: rot, child: child),
        );
      },
      child: stage,
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({
    required this.path,
    required this.size,
    required this.angle,
  });

  final String path;
  final double size;
  final double angle;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: SizedBox(
        width: size,
        height: size,
        child: Image.asset(
          path,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
          gaplessPlayback: true,
        ),
      ),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  const _QtyStepper({
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
  });

  final int quantity;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            icon: Icons.remove_rounded,
            onTap: onDecrease,
            color: AppColors.textPrimary,
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 160),
            transitionBuilder: (child, anim) {
              return ScaleTransition(scale: anim, child: child);
            },
            child: SizedBox(
              key: ValueKey(quantity),
              width: 22,
              child: Text(
                '$quantity',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          _StepButton(
            icon: Icons.add_rounded,
            onTap: onIncrease,
            color: AppColors.brandRed,
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.onTap,
    required this.color,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 30,
          height: 34,
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}

class _UsualEmpty extends StatelessWidget {
  const _UsualEmpty();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.asYourUsual, style: AppTheme.sectionHeader),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            children: [
              Icon(
                Icons.coffee_rounded,
                size: 28,
                color: AppColors.brandRed.withValues(alpha: 0.55),
              ),
              const SizedBox(height: 10),
              Text(
                AppStrings.usualEmptyTitle,
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppStrings.usualEmptyHint,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
