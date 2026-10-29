import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../cubits/home/home_cubit.dart';
import '../cubits/home/home_state.dart';
import 'fulfillment_sheet.dart';

class FulfillmentChip extends StatefulWidget {
  const FulfillmentChip({super.key});

  @override
  State<FulfillmentChip> createState() => _FulfillmentChipState();
}

class _FulfillmentChipState extends State<FulfillmentChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;
  bool _sheetOpen = false;
  bool _pulse = false;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.97,
      upperBound: 1,
      value: 1,
    );
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  Future<void> _openSheet(HomeState state) async {
    if (_sheetOpen) return;
    final cubit = context.read<HomeCubit>();
    final navigatorContext = context;
    HapticFeedback.selectionClick();
    setState(() => _sheetOpen = true);
    await _press.reverse();
    await _press.forward();
    if (!mounted) return;

    final result = await showFulfillmentSheet(
      context: navigatorContext,
      initialMode: state.fulfillmentMode,
      initialStore: state.selectedStore,
    );

    if (!mounted) return;
    setState(() => _sheetOpen = false);

    if (result == null) return;

    final changed = result.mode != state.fulfillmentMode ||
        result.store.id != state.selectedStore.id;

    cubit.setFulfillment(
      mode: result.mode,
      store: result.store,
    );

    if (changed) {
      setState(() => _pulse = true);
      await Future<void>.delayed(const Duration(milliseconds: 520));
      if (mounted) setState(() => _pulse = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (prev, next) =>
          prev.fulfillmentMode != next.fulfillmentMode ||
          prev.selectedStore != next.selectedStore,
      builder: (context, state) {
        final isPickup = state.isPickup;
        final icon = isPickup
            ? Icons.storefront_rounded
            : Icons.table_restaurant_rounded;

        return ScaleTransition(
          scale: _press,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _openSheet(state),
              borderRadius: BorderRadius.circular(28),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: _pulse
                        ? AppColors.primaryPink.withOpacity(0.55)
                        : AppColors.searchBorder,
                    width: _pulse ? 1.6 : 1,
                  ),
                  boxShadow: _pulse
                      ? [
                          BoxShadow(
                            color: AppColors.primaryPink.withOpacity(0.22),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : AppTheme.softShadowLight,
                ),
                child: Row(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 260),
                      transitionBuilder: (child, anim) {
                        return FadeTransition(
                          opacity: anim,
                          child: ScaleTransition(
                            scale: Tween<double>(begin: 0.85, end: 1).animate(
                              CurvedAnimation(
                                parent: anim,
                                curve: Curves.easeOutBack,
                              ),
                            ),
                            child: child,
                          ),
                        );
                      },
                      child: Icon(
                        icon,
                        key: ValueKey(icon),
                        size: 22,
                        color: AppColors.primaryPink,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 280),
                        transitionBuilder: (child, anim) {
                          final offset = Tween<Offset>(
                            begin: const Offset(0, 0.35),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: anim,
                              curve: Curves.easeOutCubic,
                            ),
                          );
                          return FadeTransition(
                            opacity: anim,
                            child: SlideTransition(
                              position: offset,
                              child: child,
                            ),
                          );
                        },
                        child: Text(
                          state.fulfillmentChipLabel,
                          key: ValueKey(state.fulfillmentChipLabel),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.nunito(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    AnimatedRotation(
                      turns: _sheetOpen ? 0.5 : 0,
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeOutCubic,
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 22,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
