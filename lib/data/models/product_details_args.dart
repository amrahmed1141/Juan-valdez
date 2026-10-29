import 'product_model.dart';

/// Arguments for the swipeable product details gallery.
class ProductDetailsArgs {
  const ProductDetailsArgs({
    required this.products,
    required this.sectionTitle,
    this.initialIndex = 0,
    this.heroTag,
  }) : assert(products.length > 0, 'products must not be empty');

  /// Convenience for opening a single product (no siblings to swipe).
  factory ProductDetailsArgs.single(
    ProductModel product, {
    String sectionTitle = 'Details',
    String? heroTag,
  }) {
    return ProductDetailsArgs(
      products: [product],
      sectionTitle: sectionTitle,
      initialIndex: 0,
      heroTag: heroTag,
    );
  }

  /// Opens [product] inside [products], starting at its index when found.
  factory ProductDetailsArgs.fromSection({
    required ProductModel product,
    required List<ProductModel> products,
    required String sectionTitle,
    String? heroTag,
  }) {
    final list = products.isEmpty ? [product] : List<ProductModel>.from(products);
    var index = list.indexWhere((d) => d.id == product.id);
    if (index < 0) {
      list.insert(0, product);
      index = 0;
    }
    return ProductDetailsArgs(
      products: list,
      sectionTitle: sectionTitle,
      initialIndex: index,
      heroTag: heroTag,
    );
  }

  final List<ProductModel> products;
  final String sectionTitle;
  final int initialIndex;
  final String? heroTag;

  ProductModel get initialProduct =>
      products[initialIndex.clamp(0, products.length - 1)];

  String get effectiveHeroTag => heroTag ?? 'product_${initialProduct.id}';
}
