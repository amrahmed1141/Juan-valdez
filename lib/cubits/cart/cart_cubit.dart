import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/cart_item_model.dart';
import '../../data/models/product_model.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(const CartState());

  void addToCart(ProductModel product, {int quantity = 1}) {
    final items = List<CartItemModel>.from(state.items);
    final index = items.indexWhere((item) => item.product.id == product.id);

    if (index >= 0) {
      final current = items[index];
      items[index] = current.copyWith(quantity: current.quantity + quantity);
    } else {
      items.add(CartItemModel(product: product, quantity: quantity));
    }

    emit(state.copyWith(items: items));
  }

  void increment(String productId) {
    final items = List<CartItemModel>.from(state.items);
    final index = items.indexWhere((item) => item.product.id == productId);
    if (index < 0) return;

    final current = items[index];
    items[index] = current.copyWith(quantity: current.quantity + 1);
    emit(state.copyWith(items: items));
  }

  void decrement(String productId) {
    final items = List<CartItemModel>.from(state.items);
    final index = items.indexWhere((item) => item.product.id == productId);
    if (index < 0) return;

    final current = items[index];
    if (current.quantity <= 1) {
      items.removeAt(index);
    } else {
      items[index] = current.copyWith(quantity: current.quantity - 1);
    }
    emit(state.copyWith(items: items));
  }

  void removeItem(String productId) {
    final items = state.items
        .where((item) => item.product.id != productId)
        .toList(growable: false);
    emit(state.copyWith(items: items));
  }

  void clear() => emit(const CartState());

  void placeOrder() {
    if (state.isEmpty) return;
    emit(const CartState());
  }
}
