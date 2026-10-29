import 'package:equatable/equatable.dart';

import '../../data/models/order_model.dart';

class OrderState extends Equatable {
  const OrderState({this.orders = const []});

  final List<OrderModel> orders;

  OrderModel? get activeOrder {
    for (final order in orders) {
      if (order.isActive) return order;
    }
    return null;
  }

  OrderModel? get homeTrackingOrder {
    for (final order in orders) {
      if (order.showOnHome) return order;
    }
    return null;
  }

  OrderModel? byId(String id) {
    for (final order in orders) {
      if (order.id == id) return order;
    }
    return null;
  }

  OrderState copyWith({List<OrderModel>? orders}) {
    return OrderState(orders: orders ?? this.orders);
  }

  @override
  List<Object?> get props => [orders];
}
