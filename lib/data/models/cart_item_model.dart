import 'product_model.dart';

class CartItemModel {
  const CartItemModel({
    required this.product,
    this.quantity = 1,
  });

  final ProductModel product;
  final int quantity;

  double get lineTotal => product.price * quantity;

  CartItemModel copyWith({
    ProductModel? product,
    int? quantity,
  }) {
    return CartItemModel(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}
