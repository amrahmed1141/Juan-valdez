import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/cart_item_model.dart';
import 'checkout_section_card.dart';

/// The "YOUR ORDER" section card with edit mode and quantity controls.
class CheckoutOrderSection extends StatelessWidget {
  const CheckoutOrderSection({
    super.key,
    required this.items,
    required this.editing,
    required this.onToggleEdit,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  final List<CartItemModel> items;
  final bool editing;
  final VoidCallback onToggleEdit;
  final ValueChanged<String> onIncrement;
  final ValueChanged<String> onDecrement;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    return CheckoutSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                AppStrings.yourOrder,
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  onToggleEdit();
                },
                child: Text(
                  editing ? AppStrings.doneEdit : AppStrings.editOrder,
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryPink,
                  ),
                ),
              ),
            ],
          ),
          ...items.map(
            (item) => CheckoutItemRow(
              item: item,
              editing: editing,
              canRemove: items.length > 1,
              onIncrement: () => onIncrement(item.product.id),
              onDecrement: () => onDecrement(item.product.id),
              onRemove: () => onRemove(item.product.id),
            ),
          ),
        ],
      ),
    );
  }
}

/// An individual item row inside the checkout order section.
class CheckoutItemRow extends StatelessWidget {
  const CheckoutItemRow({
    super.key,
    required this.item,
    required this.editing,
    required this.canRemove,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  final CartItemModel item;
  final bool editing;
  final bool canRemove;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: item.product.pastelColor,
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.all(4),
            child: Image.asset(item.product.imagePath, fit: BoxFit.contain),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'qty ${item.quantity} · ${item.product.formattedPrice}',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (editing) ...[
            MiniQtyButton(icon: Icons.remove_rounded, onTap: onDecrement),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                '${item.quantity}',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            MiniQtyButton(icon: Icons.add_rounded, onTap: onIncrement),
            if (canRemove) ...[
              const SizedBox(width: 4),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.close_rounded, size: 18),
                color: AppColors.textSecondary,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ] else
            Text(
              'EGP ${item.lineTotal.toStringAsFixed(0)}',
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
        ],
      ),
    );
  }
}

/// Small circular increment/decrement counter button.
class MiniQtyButton extends StatelessWidget {
  const MiniQtyButton({super.key, required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cream,
      borderRadius: BorderRadius.circular(99),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(99),
        child: SizedBox(
          width: 28,
          height: 28,
          child: Icon(icon, size: 16, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
