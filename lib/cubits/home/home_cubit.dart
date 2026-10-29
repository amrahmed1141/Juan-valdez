import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/mock/product_mock_data.dart';
import '../../data/models/product_model.dart';
import '../../data/models/store_model.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeState());

  void setFulfillment({
    required FulfillmentMode mode,
    required StoreModel store,
  }) {
    emit(
      state.copyWith(
        fulfillmentMode: FulfillmentMode.dineIn,
        selectedStore: store,
      ),
    );
  }

  /// Apply QR / deep-link params: store id + optional table.
  void applyQrCheckIn({
    String? storeId,
    String? table,
  }) {
    final store = storeId != null
        ? ProductMockData.storeById(storeId)
        : state.selectedStore;
    emit(
      state.copyWith(
        fulfillmentMode: FulfillmentMode.dineIn,
        selectedStore: store,
        tableNumber: table,
        checkedIn: true,
      ),
    );
  }

  void checkInAtCafe({StoreModel? store, String? table}) {
    emit(
      state.copyWith(
        fulfillmentMode: FulfillmentMode.dineIn,
        selectedStore: store ?? state.selectedStore,
        tableNumber: table ?? state.tableNumber ?? '4',
        checkedIn: true,
      ),
    );
  }

  void selectCategory(String category) {
    emit(
      state.copyWith(
        selectedCategory: category,
        clearExpanded: true,
      ),
    );
  }

  void setNavIndex(int index) {
    emit(state.copyWith(navIndex: index.clamp(0, 2)));
  }

  void toggleExpanded(String productId) {
    if (state.expandedProductId == productId) {
      emit(state.copyWith(clearExpanded: true));
    } else {
      emit(state.copyWith(expandedProductId: productId));
    }
  }

  void expandProduct(String productId) {
    emit(state.copyWith(expandedProductId: productId));
  }

  void collapseExpanded() {
    emit(state.copyWith(clearExpanded: true));
  }

  void toggleFavorite(ProductModel product) {
    final favorites = List<ProductModel>.from(state.favorites);
    final exists = favorites.any((d) => d.id == product.id);
    if (exists) {
      favorites.removeWhere((d) => d.id == product.id);
    } else {
      favorites.add(product);
    }
    emit(state.copyWith(favorites: favorites));
  }

  void revealFullMenu() {
    emit(state.copyWith(showFullMenu: true));
  }

  void earnPoints(int amount) {
    if (amount <= 0) return;
    final next = (state.rewardPoints + amount).clamp(0, state.rewardGoal);
    if (next == state.rewardPoints) return;
    emit(state.copyWith(rewardPoints: next));
  }
}
