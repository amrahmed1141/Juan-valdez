import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app/routes/app_routes.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../core/theme/app_theme.dart';
import '../cubits/order/order_cubit.dart';
import '../cubits/order/order_state.dart';
import '../data/models/order_model.dart';
import 'product_hero.dart';

class OrderTrackingCard extends StatelessWidget {
  const OrderTrackingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderCubit, OrderState>(
      listenWhen: (prev, next) {
        final wasReady = prev.homeTrackingOrder?.status == OrderStatus.ready;
        final isReady = next.homeTrackingOrder?.status == OrderStatus.ready;
        return !wasReady && isReady;
      },
      listener: (context, state) {
        HapticFeedback.mediumImpact();
      },
      child: BlocBuilder<OrderCubit, OrderState>(
        builder: (context, state) {
          final order = state.homeTrackingOrder;
          return AnimatedSize(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: order == null
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _LiveCard(
                      key: ValueKey(order.id),
                      order: order,
                    ),
                  ),
          );
        },
      ),
    );
  }
}

class _LiveCard extends StatefulWidget {
  const _LiveCard({super.key, required this.order});

  final OrderModel order;

  @override
  State<_LiveCard> createState() => _LiveCardState();
}

class _LiveCardState extends State<_LiveCard>
    with TickerProviderStateMixin {
  late final AnimationController _shimmer;
  late final AnimationController _enter;
  late final AnimationController _pulse;
  late final Animation<double> _enterFade;
  late final Animation<Offset> _enterSlide;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _enterFade = CurvedAnimation(parent: _enter, curve: Curves.easeOutCubic);
    _enterSlide = Tween<Offset>(
      begin: const Offset(0, -0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _enter, curve: Curves.easeOutCubic));
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _syncPulse(widget.order.status);
    _enter.forward();
  }

  @override
  void didUpdateWidget(covariant _LiveCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.order.status != widget.order.status) {
      _syncPulse(widget.order.status);
    }
  }

  void _syncPulse(OrderStatus status) {
    if (status == OrderStatus.preparing || status == OrderStatus.ready) {
      if (!_pulse.isAnimating) _pulse.repeat(reverse: true);
    } else {
      _pulse
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _shimmer.dispose();
    _enter.dispose();
    _pulse.dispose();
    super.dispose();
  }

  void _openDetails() {
    HapticFeedback.selectionClick();
    Navigator.of(context).pushNamed(
      AppRoutes.orderDetails,
      arguments: widget.order.id,
    );
  }

  void _takeIt() {
    HapticFeedback.mediumImpact();
    final id = widget.order.id;
    context.read<OrderCubit>().markCompleted(id);
    context.read<OrderCubit>().dismissHomeTracking(id);
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final accent = order.status == OrderStatus.completed
        ? const Color(0xFF2E7D32)
        : order.status == OrderStatus.ready
            ? const Color(0xFF2E7D32)
            : AppColors.brandRed;
    const modeLabel = AppStrings.dineIn;
    final showTakeIt = order.status == OrderStatus.ready;

    return FadeTransition(
      opacity: _enterFade,
      child: SlideTransition(
        position: _enterSlide,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _openDetails,
            borderRadius: BorderRadius.circular(22),
            child: Ink(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: accent.withOpacity(0.35)),
                boxShadow: AppTheme.softShadowLight,
              ),
              padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (order.primaryImagePath != null) ...[
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color:
                                order.primaryPastelColor ?? AppColors.pastelPink,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: ProductHero(
                            tag: order.heroTag,
                            imagePath: order.primaryImagePath!,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                AnimatedBuilder(
                                  animation: _pulse,
                                  builder: (context, child) {
                                    final glow = order.status ==
                                                OrderStatus.preparing ||
                                            order.status == OrderStatus.ready
                                        ? 0.35 + (_pulse.value * 0.45)
                                        : 0.5;
                                    return Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: accent,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: accent.withOpacity(glow),
                                            blurRadius: 6 + (_pulse.value * 4),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 280),
                                    child: Text(
                                      _title(order),
                                      key: ValueKey(order.status),
                                      style: GoogleFonts.nunito(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${order.primaryItemName} · $modeLabel',
                              style: GoogleFonts.nunito(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          context
                              .read<OrderCubit>()
                              .dismissHomeTracking(order.id);
                        },
                        icon: const Icon(Icons.close_rounded, size: 18),
                        color: AppColors.navInactive,
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _MiniStepper(order: order, accent: accent),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: Stack(
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: order.progress),
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, _) {
                            return LinearProgressIndicator(
                              value: value,
                              minHeight: 7,
                              backgroundColor: AppColors.progressTrack,
                              color: accent,
                            );
                          },
                        ),
                        if (order.status == OrderStatus.preparing)
                          AnimatedBuilder(
                            animation: _shimmer,
                            builder: (context, _) {
                              return FractionallySizedBox(
                                widthFactor: order.progress,
                                child: Align(
                                  alignment: Alignment(
                                    -1 + 2 * _shimmer.value,
                                    0,
                                  ),
                                  child: Container(
                                    width: 40,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.white.withOpacity(0),
                                          Colors.white.withOpacity(0.45),
                                          Colors.white.withOpacity(0),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        order.status == OrderStatus.completed
                            ? AppStrings.statusCompleted
                            : order.status == OrderStatus.ready
                                ? AppStrings.readyNow
                                : '~${order.etaMinutes} min',
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: accent,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        AppStrings.detailsArrow,
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.brandRed,
                        ),
                      ),
                    ],
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.topCenter,
                    child: showTakeIt
                        ? Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: SizedBox(
                              width: double.infinity,
                              height: 44,
                              child: FilledButton(
                                onPressed: _takeIt,
                                style: FilledButton.styleFrom(
                                  backgroundColor: accent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                ),
                                child: Text(
                                  AppStrings.takeIt,
                                  style: GoogleFonts.nunito(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _title(OrderModel order) {
    switch (order.status) {
      case OrderStatus.placed:
        return AppStrings.trackingPlaced;
      case OrderStatus.preparing:
        return AppStrings.trackingPreparing;
      case OrderStatus.ready:
        return AppStrings.trackingReady;
      case OrderStatus.completed:
        return AppStrings.statusCompleted;
    }
  }
}

class _MiniStepper extends StatelessWidget {
  const _MiniStepper({required this.order, required this.accent});

  final OrderModel order;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final steps = [
      AppStrings.stepPlaced,
      AppStrings.stepPreparing,
      AppStrings.stepReady,
    ];
    final active = order.statusStep.clamp(0, 2);

    return Row(
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          if (i > 0)
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                height: 3,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: i <= active
                      ? accent
                      : AppColors.progressTrack,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
          Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutCubic,
                width: i == active ? 22 : 18,
                height: i == active ? 22 : 18,
                decoration: BoxDecoration(
                  color: i <= active ? accent : AppColors.progressTrack,
                  shape: BoxShape.circle,
                ),
                child: i < active ||
                        (i == active &&
                            (order.status == OrderStatus.ready ||
                                order.status == OrderStatus.completed))
                    ? Icon(
                        Icons.check_rounded,
                        size: i == active ? 12 : 10,
                        color: AppColors.white,
                      )
                    : null,
              ),
              const SizedBox(height: 4),
              Text(
                steps[i],
                style: GoogleFonts.nunito(
                  fontSize: 10,
                  fontWeight: i == active ? FontWeight.w800 : FontWeight.w600,
                  color: i <= active
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
