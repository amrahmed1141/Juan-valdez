import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/routes/app_routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../cubits/order/order_cubit.dart';
import '../../cubits/order/order_state.dart';
import '../../data/models/order_model.dart';
import '../../widgets/dunkin_brand.dart';
import '../../widgets/product_hero.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderCubit, OrderState>(
      builder: (context, state) {
        final order = state.byId(orderId);
        if (order == null) {
          return Scaffold(
            backgroundColor: AppColors.backgroundAlt,
            body: SafeArea(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppStrings.orderNotFound,
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Navigator.of(context)
                          .popUntil((r) => r.isFirst),
                      child: const Text(AppStrings.backToHome),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final routeAnimation = ModalRoute.of(context)?.animation;
        final chromeFade = routeAnimation != null
            ? CurvedAnimation(
                parent: routeAnimation,
                curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
                reverseCurve:
                    const Interval(0.2, 1.0, curve: Curves.easeInCubic),
              )
            : null;

        Widget fadeChrome(Widget child) {
          if (chromeFade == null) return child;
          return FadeTransition(opacity: chromeFade, child: child);
        }

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // Opaque base — Hero route is non-opaque, so never leave holes.
              const Positioned.fill(
                child: ColoredBox(color: AppColors.backgroundAlt),
              ),
              SafeArea(
                child: Column(
                  children: [
                    fadeChrome(
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: Row(
                          children: [
                            DunkinIconButton(
                              icon: Icons.arrow_back_rounded,
                              onTap: () {
                                final nav = Navigator.of(context);
                                if (nav.canPop()) {
                                  nav.pop();
                                } else {
                                  nav.pushNamedAndRemoveUntil(
                                    AppRoutes.home,
                                    (route) => false,
                                  );
                                }
                              },
                              size: 40,
                              iconSize: 20,
                            ),
                            Expanded(
                              child: Text(
                                '${AppStrings.orderLabel} #${order.shortId}',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.nunito(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 40),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _LiveStatusHero(
                            order: order,
                            chromeAnimation: chromeFade,
                          ),
                          fadeChrome(const SizedBox(height: 18)),
                          fadeChrome(_StatusStepper(order: order)),
                          fadeChrome(const SizedBox(height: 18)),
                          fadeChrome(
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: AppTheme.softShadowLight,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    order.isDineIn
                                        ? AppStrings.dineInAt
                                        : AppStrings.pickupAt,
                                    style: GoogleFonts.nunito(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.6,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    order.store.name,
                                    style: GoogleFonts.nunito(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  if (order.store.address.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      order.store.address,
                                      style: GoogleFonts.nunito(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 12),
                                  const Divider(height: 1),
                                  const SizedBox(height: 12),
                                  ...order.items.map(
                                    (item) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 44,
                                            height: 44,
                                            decoration: BoxDecoration(
                                              color: item.product.pastelColor,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            padding: const EdgeInsets.all(4),
                                            child: Image.asset(
                                              item.product.imagePath,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              '${item.quantity}× ${item.product.name}',
                                              style: GoogleFonts.nunito(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            'EGP ${item.lineTotal.toStringAsFixed(0)}',
                                            style: GoogleFonts.nunito(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const Divider(height: 1),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Text(
                                        AppStrings.totalAmount,
                                        style: GoogleFonts.nunito(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        order.formattedTotal,
                                        style: GoogleFonts.nunito(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _paymentLabel(order.payment),
                                    style: GoogleFonts.nunito(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (order.status == OrderStatus.ready ||
                              order.status == OrderStatus.completed) ...[
                            fadeChrome(const SizedBox(height: 16)),
                            fadeChrome(
                              SizedBox(
                                height: 52,
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed: () {
                                    HapticFeedback.mediumImpact();
                                    context
                                        .read<OrderCubit>()
                                        .markCompleted(order.id);
                                    context
                                        .read<OrderCubit>()
                                        .dismissHomeTracking(order.id);
                                    Navigator.of(context)
                                        .pushNamedAndRemoveUntil(
                                      AppRoutes.home,
                                      (route) => false,
                                    );
                                  },
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.brandRed,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(28),
                                    ),
                                  ),
                                  child: Text(
                                    order.status == OrderStatus.completed
                                        ? AppStrings.backToHome
                                        : AppStrings.imAtStore,
                                    style: GoogleFonts.nunito(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _paymentLabel(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.applePay:
        return AppStrings.paidWithApplePay;
      case PaymentMethod.visa:
        return AppStrings.paidWithVisa;
      case PaymentMethod.masterCard:

        return AppStrings.paidWithMasterCard;
      case PaymentMethod.payPal:
        return AppStrings.paidWithPayPal;

      case PaymentMethod.cash:
        return AppStrings.payCashAtCounter;
    }
  }
}

class _LiveStatusHero extends StatefulWidget {
  const _LiveStatusHero({
    required this.order,
    this.chromeAnimation,
  });

  final OrderModel order;
  final Animation<double>? chromeAnimation;

  @override
  State<_LiveStatusHero> createState() => _LiveStatusHeroState();
}

class _LiveStatusHeroState extends State<_LiveStatusHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _LiveStatusHero oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.order.status != widget.order.status) {
      HapticFeedback.lightImpact();
    }
    final animate = widget.order.status == OrderStatus.placed ||
        widget.order.status == OrderStatus.preparing;
    if (animate && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    } else if (!animate && _pulse.isAnimating) {
      _pulse.stop();
      _pulse.value = 1;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final accent = order.status == OrderStatus.ready ||
            order.status == OrderStatus.completed
        ? const Color(0xFF2E7D32)
        : AppColors.brandRed;
    final imagePath = order.primaryImagePath;

    Widget maybeFadeChrome(Widget child) {
      final anim = widget.chromeAnimation;
      if (anim == null) return child;
      return FadeTransition(opacity: anim, child: child);
    }

    final productVisual = AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_pulse.value);
        return Stack(
          alignment: Alignment.center,
          children: [
            if (order.status == OrderStatus.placed ||
                order.status == OrderStatus.preparing)
              Container(
                width: 118 + t * 18,
                height: 118 + t * 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withOpacity(0.10 + t * 0.08),
                ),
              ),
            Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: order.primaryPastelColor ?? accent.withOpacity(0.15),
                boxShadow: [
                  BoxShadow(
                    color: accent.withOpacity(0.28),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(14),
              child: imagePath != null
                  ? ProductHero(
                      tag: order.heroTag,
                      imagePath: imagePath,
                    )
                  : Icon(
                      _statusIcon(order.status),
                      color: accent,
                      size: 40,
                    ),
            ),
            if (imagePath != null)
              Positioned(
                right: 4,
                bottom: 4,
                child: maybeFadeChrome(
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accent,
                      border: Border.all(color: AppColors.white, width: 2),
                    ),
                    child: Icon(
                      _statusIcon(order.status),
                      color: AppColors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppTheme.softShadowLight,
      ),
      child: Column(
        children: [
          productVisual,
          const SizedBox(height: 18),
          maybeFadeChrome(
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 320),
              child: Text(
                _statusTitle(order),
                key: ValueKey(order.status),
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          maybeFadeChrome(
            Text(
              order.status == OrderStatus.completed
                  ? AppStrings.visitFinishedHint
                  : order.status == OrderStatus.ready
                      ? AppStrings.readyDineInHint
                      : '${AppStrings.estReady} ~${order.etaMinutes} min',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          maybeFadeChrome(
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: order.progress),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  return LinearProgressIndicator(
                    value: value,
                    minHeight: 8,
                    backgroundColor: AppColors.progressTrack,
                    color: accent,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _statusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.placed:
        return Icons.receipt_long_rounded;
      case OrderStatus.preparing:
        return Icons.local_cafe_rounded;
      case OrderStatus.ready:
        return Icons.check_rounded;
      case OrderStatus.completed:
        return Icons.done_all_rounded;
    }
  }

  String _statusTitle(OrderModel order) {
    switch (order.status) {
      case OrderStatus.placed:
        return AppStrings.statusPlaced;
      case OrderStatus.preparing:
        return AppStrings.statusPreparing;
      case OrderStatus.ready:
        return order.isDineIn
            ? AppStrings.statusReadyDineIn
            : AppStrings.statusReadyPickup;
      case OrderStatus.completed:
        return AppStrings.statusCompleted;
    }
  }
}

class _StatusStepper extends StatelessWidget {
  const _StatusStepper({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final steps = [
      AppStrings.stepPlaced,
      AppStrings.stepPreparing,
      order.isDineIn ? AppStrings.stepReady : AppStrings.stepReadyPickup,
    ];
    final active = order.statusStep.clamp(0, 2);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppTheme.softShadowLight,
      ),
      child: Row(
        children: [
          for (var i = 0; i < steps.length; i++) ...[
            if (i > 0)
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  height: 3,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: i <= active
                        ? AppColors.brandRed
                        : AppColors.progressTrack,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
            Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i <= active
                        ? AppColors.brandRed
                        : AppColors.progressTrack,
                  ),
                  child: Icon(
                    i < active
                        ? Icons.check_rounded
                        : Icons.circle,
                    size: i < active ? 16 : 10,
                    color: i <= active
                        ? AppColors.white
                        : AppColors.navInactive,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  steps[i],
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: i <= active
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
