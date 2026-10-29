import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/order_model.dart';
import '../../../data/models/store_model.dart';
import 'checkout_section_card.dart';

/// The "WHEN" section card allowing the user to select "Now" or "Schedule".
class CheckoutTimeSection extends StatelessWidget {
  const CheckoutTimeSection({
    super.key,
    required this.timeKind,
    required this.store,
    required this.slots,
    required this.selectedSlotIndex,
    required this.onSelectNow,
    required this.onSelectSchedule,
    required this.onSelectSlot,
  });

  final TimeSlotKind timeKind;
  final StoreModel store;
  final List<DateTime> slots;
  final int? selectedSlotIndex;
  final VoidCallback onSelectNow;
  final VoidCallback onSelectSchedule;
  final ValueChanged<int> onSelectSlot;

  @override
  Widget build(BuildContext context) {
    return CheckoutSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.whenLabel,
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TimeChoiceCard(
                  selected: timeKind == TimeSlotKind.now,
                  title: AppStrings.orderNow,
                  subtitle: '~${store.readyInMinutes} min',
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onSelectNow();
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TimeChoiceCard(
                  selected: timeKind == TimeSlotKind.scheduled,
                  title: AppStrings.schedule,
                  subtitle: AppStrings.pickTime,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onSelectSchedule();
                  },
                ),
              ),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            child: timeKind == TimeSlotKind.scheduled
                ? Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: slots.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final slot = slots[index];
                          final selected = selectedSlotIndex == index;
                          final label =
                              '${slot.hour.toString().padLeft(2, '0')}:${slot.minute.toString().padLeft(2, '0')}';

                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              onSelectSlot(index);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.orange
                                    : AppColors.cream,
                                borderRadius: BorderRadius.circular(99),
                                border: Border.all(
                                  color: selected
                                      ? AppColors.orange
                                      : AppColors.divider,
                                ),
                              ),
                              child: Text(
                                label,
                                style: GoogleFonts.nunito(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: selected
                                      ? AppColors.white
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

/// Radio-style choice card for "Now" vs "Schedule".
class TimeChoiceCard extends StatelessWidget {
  const TimeChoiceCard({
    super.key,
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final bool selected;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.orange.withValues(alpha: 0.12)
              : AppColors.cream,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.orange : AppColors.divider,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  size: 18,
                  color: selected ? AppColors.orange : AppColors.navInactive,
                ),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: Text(
                subtitle,
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
