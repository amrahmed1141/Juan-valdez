import '../../core/constants/app_assets.dart';
import '../models/reward_model.dart';

abstract final class RewardMockData {
  static const List<RewardModel> all = [
    RewardModel(
      id: 'rw_espresso',
      title: 'Free Espresso',
      imagePath: AppAssets.juanValdezCoffee,
      costPts: 400,
    ),
    RewardModel(
      id: 'rw_americano',
      title: 'Free Americano',
      imagePath: AppAssets.juanValdezCoffee,
      costPts: 500,
    ),
    RewardModel(
      id: 'rw_cookie',
      title: 'Free Chocolate Chip Cookie',
      imagePath: AppAssets.chocolateChipCookie,
      costPts: 600,
    ),
    RewardModel(
      id: 'rw_latte',
      title: 'Free Latte',
      imagePath: AppAssets.signatureCream,
      costPts: 700,
    ),
    RewardModel(
      id: 'rw_croissant',
      title: 'Free Butter Croissant',
      imagePath: AppAssets.butterCroissant,
      costPts: 800,
    ),
    RewardModel(
      id: 'rw_frappe',
      title: 'Free Strawberry Frappe',
      imagePath: AppAssets.strawberryFrappe,
      costPts: 900,
    ),
    RewardModel(
      id: 'rw_spanish',
      title: 'Free Spanish Latte',
      imagePath: AppAssets.icedSpanishLatte,
      costPts: 1000,
    ),
    RewardModel(
      id: 'rw_choco_croissant',
      title: 'Free Chocolate Croissant',
      imagePath: AppAssets.chocolateCroissant,
      costPts: 1100,
    ),
    RewardModel(
      id: 'rw_matcha',
      title: 'Free Iced Matcha Latte',
      imagePath: AppAssets.icedMatchaLatte,
      costPts: 1200,
    ),
    RewardModel(
      id: 'rw_combo',
      title: 'Free Coffee + Cookie Combo',
      imagePath: AppAssets.nutellaCookie,
      costPts: 1500,
    ),
  ];
}
