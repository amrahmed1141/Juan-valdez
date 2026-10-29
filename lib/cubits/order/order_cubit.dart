import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/home/home_state.dart';
import '../../data/mock/product_mock_data.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/models/order_model.dart';
import '../../data/models/store_model.dart';
import 'order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  OrderCubit() : super(const OrderState());

  final Map<String, Timer> _timers = {};
  int _seq = 4800;

  /// Start a dine-in visit (no payment / cart checkout).
  OrderModel startDineInVisit({
    required StoreModel store,
    String? tableNumber,
    List<CartItemModel>? items,
  }) {
    // One active visit at a time for the demo.
    for (final existing in state.orders) {
      if (existing.isActive) {
        markCompleted(existing.id);
      }
    }

    _seq += 1;
    final id = 'JV$_seq';
    final visitItems = items ??
        [
          CartItemModel(product: ProductMockData.pickedForYou, quantity: 1),
        ];

    final order = OrderModel(
      id: id,
      items: List<CartItemModel>.unmodifiable(visitItems),
      mode: FulfillmentMode.dineIn,
      store: store,
      payment: PaymentMethod.cash,
      status: OrderStatus.placed,
      createdAt: DateTime.now(),
      etaMinutes: store.readyInMinutes.clamp(2, 8),
    );

    emit(state.copyWith(orders: [order, ...state.orders]));
    _scheduleProgress(id);
    return order;
  }

  OrderModel placeBuyNowOrder({
    required List<CartItemModel> items,
    required FulfillmentMode mode,
    required StoreModel store,
    required PaymentMethod payment,
    required TimeSlotKind timeKind,
    DateTime? scheduledFor,
  }) {
    // One active visit at a time for the demo.
    for (final existing in state.orders) {
      if (existing.isActive) {
        markCompleted(existing.id);
      }
    }

    _seq += 1;
    final id = 'JV$_seq';
    final visitItems = items.isEmpty
        ? [CartItemModel(product: ProductMockData.pickedForYou, quantity: 1)]
        : List<CartItemModel>.unmodifiable(items);

    // Keep checkout payment / schedule; café flow is dine-in oriented.
    final order = OrderModel(
      id: id,
      items: visitItems,
      mode: mode == FulfillmentMode.pickup ? FulfillmentMode.dineIn : mode,
      store: store,
      payment: payment,
      status: OrderStatus.placed,
      createdAt: DateTime.now(),
      etaMinutes: store.readyInMinutes.clamp(2, 8),
      scheduledFor:
          timeKind == TimeSlotKind.scheduled ? scheduledFor : null,
    );

    emit(state.copyWith(orders: [order, ...state.orders]));
    _scheduleProgress(id);
    return order;
  }

  void dismissHomeTracking(String orderId) {
    _updateOrder(
      orderId,
      (order) => order.copyWith(dismissedFromHome: true),
    );
  }

  void markCompleted(String orderId) {
    _cancelTimer(orderId);
    _updateOrder(
      orderId,
      (order) => order.copyWith(status: OrderStatus.completed),
    );
  }

  void _scheduleProgress(String orderId) {
    _cancelTimer(orderId);

    _timers[orderId] = Timer(const Duration(seconds: 2), () {
      _updateOrder(
        orderId,
        (order) => order.copyWith(status: OrderStatus.preparing),
      );

      _timers[orderId] = Timer(const Duration(seconds: 6), () {
        _updateOrder(
          orderId,
          (order) => order.copyWith(status: OrderStatus.ready),
        );

        _timers[orderId] = Timer(const Duration(seconds: 20), () {
          _updateOrder(
            orderId,
            (order) => order.copyWith(status: OrderStatus.completed),
          );
          _cancelTimer(orderId);
        });
      });
    });
  }

  void _updateOrder(
    String orderId,
    OrderModel Function(OrderModel order) transform,
  ) {
    final orders = state.orders.map((order) {
      if (order.id != orderId) return order;
      return transform(order);
    }).toList(growable: false);
    emit(state.copyWith(orders: orders));
  }

  void _cancelTimer(String orderId) {
    _timers.remove(orderId)?.cancel();
  }

  @override
  Future<void> close() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    return super.close();
  }
}
