import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';

/// Trailing selection indicator:
/// - Selected: Orange filled circle with white checkmark
/// - Unselected: Subtle ring using the app divider color
class PaymentSelectionIndicator extends StatelessWidget {
  const PaymentSelectionIndicator({super.key, required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? AppColors.orange : Colors.transparent,
        border: Border.all(
          color: selected ? AppColors.orange : AppColors.divider,
          width: 1.8,
        ),
      ),
      child: selected
          ? const Center(
              child: Icon(
                Icons.check_rounded,
                size: 13,
                color: Colors.white,
              ),
            )
          : null,
    );
  }
}

/// A payment option row tile for the light checkout card.
class PaymentOptionTile extends StatelessWidget {
  const PaymentOptionTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String? subtitle;
  final Widget icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: AppColors.orange.withValues(alpha: 0.12),
        highlightColor: AppColors.orange.withValues(alpha: 0.06),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          child: Row(
            children: [
              SizedBox(
                width: 34,
                height: 26,
                child: Center(child: icon),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const Spacer(),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                  ],
                ),
              ),
              PaymentSelectionIndicator(selected: selected),
            ],
          ),
        ),
      ),
    );
  }
}

/// Visual brand icons for Mastercard, PayPal, Apple Pay, Visa, and Cash.
class PaymentBrandIcon extends StatelessWidget {
  const PaymentBrandIcon.masterCard({super.key}) : _type = _BrandType.masterCard;
  const PaymentBrandIcon.payPal({super.key}) : _type = _BrandType.payPal;
  const PaymentBrandIcon.applePay({super.key}) : _type = _BrandType.applePay;
  const PaymentBrandIcon.visa({super.key}) : _type = _BrandType.visa;
  const PaymentBrandIcon.cash({super.key}) : _type = _BrandType.cash;
  const PaymentBrandIcon.custom({super.key}) : _type = _BrandType.custom;

  final _BrandType _type;

  @override
  Widget build(BuildContext context) {
    switch (_type) {
      case _BrandType.masterCard:
        return const _MasterCardLogo();
      case _BrandType.payPal:
        return const _PayPalLogo();
      case _BrandType.applePay:
        return const Icon(
          Icons.apple,
          color: AppColors.textPrimary,
          size: 24,
        );
      case _BrandType.visa:
        return const _VisaLogo();
      case _BrandType.cash:
        return Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: AppColors.cream,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Icon(
              Icons.payments_rounded,
              color: AppColors.orange,
              size: 16,
            ),
          ),
        );
      case _BrandType.custom:
        return Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: AppColors.cream,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Icon(
              Icons.credit_card_rounded,
              color: AppColors.primaryPink,
              size: 16,
            ),
          ),
        );
    }
  }
}

enum _BrandType { masterCard, payPal, applePay, visa, cash, custom }

/// Authentic Mastercard interlocking red & amber circles.
class _MasterCardLogo extends StatelessWidget {
  const _MasterCardLogo();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 20,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 2,
            child: Container(
              width: 17,
              height: 17,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFEB001B),
              ),
            ),
          ),
          Positioned(
            right: 2,
            child: Container(
              width: 17,
              height: 17,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF79E1B),
              ),
            ),
          ),
          Positioned(
            left: 9.5,
            child: ClipRect(
              child: Align(
                alignment: Alignment.centerRight,
                widthFactor: 0.5,
                child: Container(
                  width: 17,
                  height: 17,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFFF5F00),
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

/// Authentic stylized PayPal logo.
class _PayPalLogo extends StatelessWidget {
  const _PayPalLogo();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 26,
      height: 22,
      child: Stack(
        children: [
          Positioned(
            left: 2,
            top: 2,
            child: Text(
              'P',
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                color: const Color(0xFF003087),
                height: 1,
              ),
            ),
          ),
          Positioned(
            left: 8,
            top: 0,
            child: Text(
              'P',
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                color: const Color(0xFF0079C1),
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Visa stylized card logo.
class _VisaLogo extends StatelessWidget {
  const _VisaLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F71),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'VISA',
        style: GoogleFonts.nunito(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
          color: Colors.white,
        ),
      ),
    );
  }
}
