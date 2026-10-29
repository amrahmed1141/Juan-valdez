import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/order_model.dart';
import 'payment_option_tile.dart';

/// Data returned when a new card is added.
class AddedPaymentCard {
  const AddedPaymentCard({
    required this.id,
    required this.title,
    required this.maskedNumber,
    required this.paymentMethod,
  });

  final String id;
  final String title;
  final String maskedNumber;
  final PaymentMethod paymentMethod;
}

/// A modal bottom sheet to add a new payment method.
class AddPaymentSheet extends StatefulWidget {
  const AddPaymentSheet({super.key});

  static Future<AddedPaymentCard?> show(BuildContext context) {
    return showModalBottomSheet<AddedPaymentCard>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddPaymentSheet(),
    );
  }

  @override
  State<AddPaymentSheet> createState() => _AddPaymentSheetState();
}

class _AddPaymentSheetState extends State<AddPaymentSheet> {
  final _cardNumberController = TextEditingController();
  final _holderNameController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  PaymentMethod _selectedType = PaymentMethod.masterCard;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _holderNameController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _onSave() {
    final rawNumber = _cardNumberController.text.replaceAll(' ', '');
    final lastFour = rawNumber.length >= 4
        ? rawNumber.substring(rawNumber.length - 4)
        : '8463';

    final name = _holderNameController.text.trim();
    final title = name.isNotEmpty
        ? name
        : (_selectedType == PaymentMethod.masterCard
            ? 'Master Card'
            : (_selectedType == PaymentMethod.visa ? 'Visa' : 'Paypal'));

    HapticFeedback.mediumImpact();
    Navigator.of(context).pop(
      AddedPaymentCard(
        id: 'card_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        maskedNumber: '•••••••• $lastFour',
        paymentMethod: _selectedType,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Text(
                  'Add Payment Method',
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.textSecondary,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'CHOOSE TYPE',
              style: GoogleFonts.nunito(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _TypePill(
                  title: 'Mastercard',
                  icon: const PaymentBrandIcon.masterCard(),
                  selected: _selectedType == PaymentMethod.masterCard,
                  onTap: () =>
                      setState(() => _selectedType = PaymentMethod.masterCard),
                ),
                const SizedBox(width: 8),
                _TypePill(
                  title: 'Visa',
                  icon: const PaymentBrandIcon.visa(),
                  selected: _selectedType == PaymentMethod.visa,
                  onTap: () =>
                      setState(() => _selectedType = PaymentMethod.visa),
                ),
                const SizedBox(width: 8),
                _TypePill(
                  title: 'PayPal',
                  icon: const PaymentBrandIcon.payPal(),
                  selected: _selectedType == PaymentMethod.payPal,
                  onTap: () =>
                      setState(() => _selectedType = PaymentMethod.payPal),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _InputField(
              controller: _cardNumberController,
              label: 'Card Number',
              hint: '•••• •••• •••• 8463',
              keyboardType: TextInputType.number,
              prefixIcon: const Icon(
                Icons.credit_card_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ),
            const SizedBox(height: 12),
            _InputField(
              controller: _holderNameController,
              label: 'Cardholder Name',
              hint: 'e.g. Amr Mohamed',
              prefixIcon: const Icon(
                Icons.person_outline_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _InputField(
                    controller: _expiryController,
                    label: 'Expiry',
                    hint: 'MM/YY',
                    keyboardType: TextInputType.datetime,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InputField(
                    controller: _cvvController,
                    label: 'CVV',
                    hint: '•••',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: Material(
                color: AppColors.orange,
                borderRadius: BorderRadius.circular(28),
                child: InkWell(
                  onTap: _onSave,
                  borderRadius: BorderRadius.circular(28),
                  child: Center(
                    child: Text(
                      'Save Payment Method',
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
          ],
        ),
      ),
    );
  }
}

class _TypePill extends StatelessWidget {
  const _TypePill({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final Widget icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 48,
          decoration: BoxDecoration(
            color: selected
                ? AppColors.orange.withValues(alpha: 0.12)
                : AppColors.cream,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.orange : AppColors.divider,
              width: selected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  title,
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
          ),
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType,
    this.prefixIcon,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.nunito(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.cream,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            cursorColor: AppColors.orange,
            decoration: InputDecoration(
              isDense: true,
              hintText: hint,
              hintStyle: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.navInactive,
              ),
              prefixIcon: prefixIcon,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
