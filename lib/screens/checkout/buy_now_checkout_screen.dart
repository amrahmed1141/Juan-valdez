import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/routes/app_routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../cubits/home/home_cubit.dart';
import '../../cubits/home/home_state.dart';
import '../../cubits/order/order_cubit.dart';
import '../../data/models/buy_now_args.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/models/order_model.dart';
import '../../widgets/dunkin_brand.dart';
import 'widgets/checkout_bottom_bar.dart';
import 'widgets/checkout_order_section.dart';
import 'widgets/checkout_time_section.dart';
import 'widgets/payment_section.dart';

/// Checkout screen for "Buy Now" flow.
/// Orchestrates order items, delivery/pickup time choice, payment selection,
/// and order placement with clean modular widgets.
class BuyNowCheckoutScreen extends StatefulWidget {
  const BuyNowCheckoutScreen({super.key, required this.args});

  final BuyNowArgs args;

  @override
  State<BuyNowCheckoutScreen> createState() => _BuyNowCheckoutScreenState();
}

class _BuyNowCheckoutScreenState extends State<BuyNowCheckoutScreen> {
  late List<CartItemModel> _items;
  late bool _editing;
  TimeSlotKind _timeKind = TimeSlotKind.now;
  DateTime? _scheduledFor;
  int? _selectedSlotIndex;
  PaymentMethod _payment = PaymentMethod.applePay;

  @override
  void initState() {
    super.initState();
    _items = widget.args.items
        .map((e) => CartItemModel(product: e.product, quantity: e.quantity))
        .toList();
    _editing = false;
  }

  double get _total =>
      _items.fold(0.0, (sum, item) => sum + item.lineTotal);

  String get _formattedTotal => 'EGP ${_total.toStringAsFixed(0)}';

  List<DateTime> get _slots {
    final now = DateTime.now();
    final base = DateTime(now.year, now.month, now.day, now.hour, now.minute);
    final startMinute = ((base.minute ~/ 15) + 1) * 15;
    var cursor = base.add(Duration(minutes: startMinute - base.minute));
    if (cursor.isBefore(now.add(const Duration(minutes: 10)))) {
      cursor = cursor.add(const Duration(minutes: 15));
    }
    return List.generate(6, (i) => cursor.add(Duration(minutes: 15 * i)));
  }

  void _increment(String id) {
    setState(() {
      final i = _items.indexWhere((e) => e.product.id == id);
      if (i < 0) return;
      _items[i] = _items[i].copyWith(quantity: _items[i].quantity + 1);
    });
  }

  void _decrement(String id) {
    setState(() {
      final i = _items.indexWhere((e) => e.product.id == id);
      if (i < 0) return;
      if (_items[i].quantity <= 1) {
        if (_items.length > 1) _items.removeAt(i);
      } else {
        _items[i] = _items[i].copyWith(quantity: _items[i].quantity - 1);
      }
    });
  }

  void _remove(String id) {
    if (_items.length <= 1) return;
    setState(() => _items.removeWhere((e) => e.product.id == id));
  }

  void _placeOrder() {
    if (_items.isEmpty) return;
    if (_timeKind == TimeSlotKind.scheduled && _scheduledFor == null) {
      AppSnackbars.show(context, AppStrings.pickTimeSlot);
      return;
    }

    HapticFeedback.mediumImpact();
    final home = context.read<HomeCubit>().state;
    context.read<HomeCubit>().checkInAtCafe(
          store: widget.args.store,
          table: home.tableNumber ?? '4',
        );

    final order = context.read<OrderCubit>().placeBuyNowOrder(
          items: List.unmodifiable(_items),
          mode: widget.args.mode,
          store: widget.args.store,
          payment: _payment,
          timeKind: _timeKind,
          scheduledFor: _scheduledFor,
        );

    final points = (_total / 1.25).round().clamp(5, 120);
    context.read<HomeCubit>().earnPoints(points);

    Navigator.of(context).pushReplacementNamed(
      AppRoutes.orderDetails,
      arguments: order.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDineIn = widget.args.mode == FulfillmentMode.dineIn;
    final modeLabel = isDineIn ? AppStrings.dineIn : AppStrings.pickup;

    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  DunkinIconButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Navigator.of(context).pop(),
                    size: 40,
                    iconSize: 20,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          AppStrings.buyNow,
                          style: GoogleFonts.nunito(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '$modeLabel · ${widget.args.store.name}',
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                physics: const BouncingScrollPhysics(),
                children: [
                  // Order Summary Section
                  CheckoutOrderSection(
                    items: _items,
                    editing: _editing,
                    onToggleEdit: () => setState(() => _editing = !_editing),
                    onIncrement: _increment,
                    onDecrement: _decrement,
                    onRemove: _remove,
                  ),
                  const SizedBox(height: 12),

                  // Time Selection Section
                  CheckoutTimeSection(
                    timeKind: _timeKind,
                    store: widget.args.store,
                    slots: _slots,
                    selectedSlotIndex: _selectedSlotIndex,
                    onSelectNow: () {
                      setState(() {
                        _timeKind = TimeSlotKind.now;
                        _scheduledFor = null;
                        _selectedSlotIndex = null;
                      });
                    },
                    onSelectSchedule: () {
                      setState(() {
                        _timeKind = TimeSlotKind.scheduled;
                        _selectedSlotIndex ??= 0;
                        _scheduledFor = _slots[_selectedSlotIndex!];
                      });
                    },
                    onSelectSlot: (index) {
                      setState(() {
                        _selectedSlotIndex = index;
                        _scheduledFor = _slots[index];
                      });
                    },
                  ),
                  const SizedBox(height: 12),

                  // Enhanced Payment Section (styled like the attached photo)
                  CheckoutPaymentSection(
                    selectedMethod: _payment,
                    onChanged: (method) {
                      setState(() => _payment = method);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Subtotal Row
                  Row(
                    children: [
                      Text(
                        AppStrings.subtotal,
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formattedTotal,
                        style: GoogleFonts.nunito(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Pinned Bottom Bar
            CheckoutBottomBar(
              onCancel: () => Navigator.of(context).pop(),
              onPlaceOrder: _placeOrder,
            ),
          ],
        ),
      ),
    );
  }
}
