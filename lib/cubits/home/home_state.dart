import 'package:equatable/equatable.dart';

import '../../core/constants/app_strings.dart';
import '../../data/mock/product_mock_data.dart';
import '../../data/models/product_model.dart';
import '../../data/models/store_model.dart';

enum FulfillmentMode { pickup, dineIn }

class HomeState extends Equatable {
  const HomeState({
    this.selectedCategory = AppStrings.categoryCroissant,
    this.favorites = const [],
    this.navIndex = 0,
    this.expandedProductId,
    this.rewardPoints = 640,
    this.rewardGoal = 1000,
    this.showFullMenu = true,
    this.fulfillmentMode = FulfillmentMode.dineIn,
    this.selectedStore = ProductMockData.defaultStore,
    this.tableNumber,
    this.checkedIn = false,
  });

  final String selectedCategory;
  final List<ProductModel> favorites;
  final int navIndex;
  final String? expandedProductId;
  final int rewardPoints;
  final int rewardGoal;
  final bool showFullMenu;
  final FulfillmentMode fulfillmentMode;
  final StoreModel selectedStore;
  final String? tableNumber;
  final bool checkedIn;

  bool get isPickup => fulfillmentMode == FulfillmentMode.pickup;

  String get fulfillmentLabel => AppStrings.dineIn;

  String get fulfillmentChipLabel {
    final table = tableNumber;
    if (table != null && table.isNotEmpty) {
      return '${AppStrings.dineIn} · ${selectedStore.name} · ${AppStrings.tableLabel} $table';
    }
    return '${AppStrings.dineIn} · ${selectedStore.name}';
  }

  List<ProductModel> get filteredProducts =>
      ProductMockData.byCategory(selectedCategory);

  double get rewardProgress =>
      rewardGoal == 0 ? 0 : (rewardPoints / rewardGoal).clamp(0.0, 1.0);

  int get pointsUntilReward =>
      (rewardGoal - rewardPoints).clamp(0, rewardGoal);

  bool isFavorite(String id) => favorites.any((d) => d.id == id);

  bool isExpanded(String id) => expandedProductId == id;

  HomeState copyWith({
    String? selectedCategory,
    List<ProductModel>? favorites,
    int? navIndex,
    String? expandedProductId,
    bool clearExpanded = false,
    int? rewardPoints,
    int? rewardGoal,
    bool? showFullMenu,
    FulfillmentMode? fulfillmentMode,
    StoreModel? selectedStore,
    String? tableNumber,
    bool clearTable = false,
    bool? checkedIn,
  }) {
    return HomeState(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      favorites: favorites ?? this.favorites,
      navIndex: navIndex ?? this.navIndex,
      expandedProductId:
          clearExpanded ? null : (expandedProductId ?? this.expandedProductId),
      rewardPoints: rewardPoints ?? this.rewardPoints,
      rewardGoal: rewardGoal ?? this.rewardGoal,
      showFullMenu: showFullMenu ?? this.showFullMenu,
      fulfillmentMode: fulfillmentMode ?? this.fulfillmentMode,
      selectedStore: selectedStore ?? this.selectedStore,
      tableNumber: clearTable ? null : (tableNumber ?? this.tableNumber),
      checkedIn: checkedIn ?? this.checkedIn,
    );
  }

  @override
  List<Object?> get props => [
        selectedCategory,
        favorites,
        navIndex,
        expandedProductId,
        rewardPoints,
        rewardGoal,
        showFullMenu,
        fulfillmentMode,
        selectedStore,
        tableNumber,
        checkedIn,
      ];
}
