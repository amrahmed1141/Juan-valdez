class RewardModel {
  const RewardModel({
    required this.id,
    required this.title,
    required this.imagePath,
    required this.costPts,
  });

  final String id;
  final String title;
  final String imagePath;
  final int costPts;

  bool isUnlocked(int userPoints) => userPoints >= costPts;
}
