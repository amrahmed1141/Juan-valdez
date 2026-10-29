import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/order_model.dart';
import 'add_payment_sheet.dart';
import 'checkout_section_card.dart';
import 'payment_option_tile.dart';

/// Representation of a payment option row inside the payment card.
class PaymentOptionModel {
  const PaymentOptionModel({
    required this.id,
    required this.title,
    this.subtitle,
    required this.method,
    required this.icon,
  });

  final String id;
  final String title;
  final String? subtitle;
  final PaymentMethod method;
  final Widget icon;
}

/// Payment section matching the light checkout cards (YOUR ORDER / WHEN).
class CheckoutPaymentSection extends StatefulWidget {
  const CheckoutPaymentSection({
    super.key,
    required this.selectedMethod,
    required this.onChanged,
  });

  final PaymentMethod selectedMethod;
  final ValueChanged<PaymentMethod> onChanged;

  @override
  State<CheckoutPaymentSection> createState() => _CheckoutPaymentSectionState();
}

class _CheckoutPaymentSectionState extends State<CheckoutPaymentSection> {
  final List<PaymentOptionModel> _customCards = [];

  List<PaymentOptionModel> get _defaultCards => const [
        PaymentOptionModel(
          id: 'mastercard_default',
          title: 'Master Card',
          subtitle: '•••••••• 8463',
          method: PaymentMethod.masterCard,
          icon: PaymentBrandIcon.masterCard(),
        ),
        PaymentOptionModel(
          id: 'paypal_default',
          title: 'Paypal',
          subtitle: '•••••••• 8463',
          method: PaymentMethod.payPal,
          icon: PaymentBrandIcon.payPal(),
        ),
        PaymentOptionModel(
          id: 'apple_pay_default',
          title: 'Apple Pay',
          subtitle: '•••••••• 8463',
          method: PaymentMethod.applePay,
          icon: PaymentBrandIcon.applePay(),
        ),
      ];

  Future<void> _onAddPaymentMethod() async {
    HapticFeedback.selectionClick();
    final card = await AddPaymentSheet.show(context);
    if (card == null || !mounted) return;

    setState(() {
      _customCards.add(
        PaymentOptionModel(
          id: card.id,
          title: card.title,
          subtitle: card.maskedNumber,
          method: card.paymentMethod,
          icon: card.paymentMethod == PaymentMethod.masterCard
              ? const PaymentBrandIcon.masterCard()
              : (card.paymentMethod == PaymentMethod.payPal
                  ? const PaymentBrandIcon.payPal()
                  : const PaymentBrandIcon.visa()),
        ),
      );
    });

    widget.onChanged(card.paymentMethod);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Added ${card.title} successfully!',
          style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.dark,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allCards = [..._defaultCards, ..._customCards];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              AppStrings.payLabel,
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            Text(
              'SECURE CHECKOUT',
              style: GoogleFonts.nunito(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        CheckoutSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...allCards.map((card) {
                final isSelected = widget.selectedMethod == card.method;
                return PaymentOptionTile(
                  title: card.title,
                  subtitle: card.subtitle,
                  icon: card.icon,
                  selected: isSelected,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    widget.onChanged(card.method);
                  },
                );
              }),
              const SizedBox(height: 6),
              _AddPaymentPillButton(onTap: _onAddPaymentMethod),
              const SizedBox(height: 10),
              PaymentOptionTile(
                title: AppStrings.cashAtCounter,
                subtitle: 'Pay when ready',
                icon: const PaymentBrandIcon.cash(),
                selected: widget.selectedMethod == PaymentMethod.cash,
                onTap: () {
                  HapticFeedback.selectionClick();
                  widget.onChanged(PaymentMethod.cash);
                },
              ),
            ],
          ),
        ),
        if (widget.selectedMethod == PaymentMethod.cash) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.exploreSection,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 18,
                  color: AppColors.orange,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppStrings.cashHint,
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Full-width "+ Add Payment Method" button styled for the light card.
class _AddPaymentPillButton extends StatelessWidget {
  const _AddPaymentPillButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cream,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        splashColor: AppColors.primaryPink.withValues(alpha: 0.12),
        highlightColor: AppColors.primaryPink.withValues(alpha: 0.08),
        child: Container(
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.add_rounded,
                size: 18,
                color: AppColors.primaryPink,
              ),
              const SizedBox(width: 6),
              Text(
                AppStrings.addPaymentMethod,
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryPink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
