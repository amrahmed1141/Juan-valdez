import 'package:equatable/equatable.dart';

import '../../data/models/cart_item_model.dart';

class CartState extends Equatable {
  const CartState({this.items = const []});

  final List<CartItemModel> items;

  int get totalQuantity =>
      items.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount =>
      items.fold(0.0, (sum, item) => sum + item.lineTotal);

  String get formattedTotal => 'EGP ${totalAmount.toStringAsFixed(0)}';

  bool get isEmpty => items.isEmpty;

  int quantityOf(String productId) {
    for (final item in items) {
      if (item.product.id == productId) return item.quantity;
    }
    return 0;
  }

  CartState copyWith({List<CartItemModel>? items}) {
    return CartState(items: items ?? this.items);
  }

  @override
  List<Object?> get props => [items];
}
