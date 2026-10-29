import '../../cubits/home/home_state.dart';
import 'cart_item_model.dart';
import 'store_model.dart';

class BuyNowArgs {
  const BuyNowArgs({
    required this.items,
    required this.mode,
    required this.store,
  });

  final List<CartItemModel> items;
  final FulfillmentMode mode;
  final StoreModel store;
}
