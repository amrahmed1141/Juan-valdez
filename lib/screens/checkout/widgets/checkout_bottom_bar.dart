import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

/// Bottom action bar pinned to the bottom of the checkout screen.
class CheckoutBottomBar extends StatelessWidget {
  const CheckoutBottomBar({
    super.key,
    required this.onCancel,
    required this.onPlaceOrder,
  });

  final VoidCallback onCancel;
  final VoidCallback onPlaceOrder;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottom),
      decoration: BoxDecoration(
        color: AppColors.cream,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 52,
              child: Material(
                color: AppColors.exploreSection,
                borderRadius: BorderRadius.circular(28),
                child: InkWell(
                  onTap: onCancel,
                  borderRadius: BorderRadius.circular(28),
                  child: Center(
                    child: Text(
                      AppStrings.cancel,
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
            flex: 2,
            child: SizedBox(
              height: 52,
              child: Material(
                color: AppColors.orange,
                borderRadius: BorderRadius.circular(28),
                child: InkWell(
                  onTap: onPlaceOrder,
                  borderRadius: BorderRadius.circular(28),
                  child: Center(
                    child: Text(
                      AppStrings.placeOrder,
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
        ],
      ),
    );
  }
}
