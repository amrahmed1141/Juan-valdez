import 'package:equatable/equatable.dart';
import 'package:flutter/painting.dart';

import '../../cubits/home/home_state.dart';
import 'cart_item_model.dart';
import 'store_model.dart';

enum OrderStatus { placed, preparing, ready, completed }

enum PaymentMethod { applePay, visa, masterCard, payPal, cash }

enum TimeSlotKind { now, scheduled }

class OrderModel extends Equatable {
  const OrderModel({
    required this.id,
    required this.items,
    required this.mode,
    required this.store,
    required this.payment,
    required this.status,
    required this.createdAt,
    required this.etaMinutes,
    this.scheduledFor,
    this.dismissedFromHome = false,
  });

  final String id;
  final List<CartItemModel> items;
  final FulfillmentMode mode;
  final StoreModel store;
  final PaymentMethod payment;
  final OrderStatus status;
  final DateTime createdAt;
  final int etaMinutes;
  final DateTime? scheduledFor;
  final bool dismissedFromHome;

  bool get isActive =>
      status == OrderStatus.placed ||
      status == OrderStatus.preparing ||
      status == OrderStatus.ready;

  bool get showOnHome =>
      (isActive || status == OrderStatus.completed) && !dismissedFromHome;

  bool get isDineIn => mode == FulfillmentMode.dineIn;

  double get totalAmount =>
      items.fold(0.0, (sum, item) => sum + item.lineTotal);

  String get formattedTotal => 'EGP ${totalAmount.toStringAsFixed(0)}';

  String get primaryItemName =>
      items.isEmpty ? 'Order' : items.first.product.name;

  String? get primaryImagePath =>
      items.isEmpty ? null : items.first.product.imagePath;

  Color? get primaryPastelColor =>
      items.isEmpty ? null : items.first.product.pastelColor;

  /// Shared [Hero] tag between home tracking card and order details.
  String get heroTag => 'hero_order_$id';

  String get shortId => id.length <= 4 ? id : id.substring(id.length - 4);

  int get statusStep {
    switch (status) {
      case OrderStatus.placed:
        return 0;
      case OrderStatus.preparing:
        return 1;
      case OrderStatus.ready:
      case OrderStatus.completed:
        return 2;
    }
  }

  double get progress {
    switch (status) {
      case OrderStatus.placed:
        return 0.18;
      case OrderStatus.preparing:
        return 0.55;
      case OrderStatus.ready:
        return 1.0;
      case OrderStatus.completed:
        return 1.0;
    }
  }

  OrderModel copyWith({
    String? id,
    List<CartItemModel>? items,
    FulfillmentMode? mode,
    StoreModel? store,
    PaymentMethod? payment,
    OrderStatus? status,
    DateTime? createdAt,
    int? etaMinutes,
    DateTime? scheduledFor,
    bool? dismissedFromHome,
  }) {
    return OrderModel(
      id: id ?? this.id,
      items: items ?? this.items,
      mode: mode ?? this.mode,
      store: store ?? this.store,
      payment: payment ?? this.payment,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      etaMinutes: etaMinutes ?? this.etaMinutes,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      dismissedFromHome: dismissedFromHome ?? this.dismissedFromHome,
    );
  }

  @override
  List<Object?> get props => [
        id,
        items,
        mode,
        store,
        payment,
        status,
        createdAt,
        etaMinutes,
        scheduledFor,
        dismissedFromHome,
      ];
}
