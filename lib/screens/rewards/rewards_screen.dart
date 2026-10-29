import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../../app/routes/app_routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../cubits/home/home_cubit.dart';
import '../../cubits/home/home_state.dart';
import '../../data/mock/reward_mock_data.dart';
import '../../data/models/reward_model.dart';
import '../../widgets/dunkin_brand.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontal =
        width >= 900 ? width * 0.18 : (width >= 700 ? 48.0 : 16.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<HomeCubit, HomeState>(
          buildWhen: (p, n) =>
              p.rewardPoints != n.rewardPoints || p.rewardGoal != n.rewardGoal,
          builder: (context, state) {
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(horizontal, 8, horizontal, 0),
                  child: _RewardsHeader(points: state.rewardPoints),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      horizontal,
                      4,
                      horizontal,
                      24,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: RewardMockData.all.length,
                    itemBuilder: (context, index) {
                      final reward = RewardMockData.all[index];
                      return _RewardCard(
                        reward: reward,
                        userPoints: state.rewardPoints,
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RewardsHeader extends StatelessWidget {
  const _RewardsHeader({required this.points});

  final int points;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DunkinIconButton(
          icon: Icons.arrow_back_rounded,
          onTap: () => Navigator.of(context).pop(),
          size: 40,
          iconSize: 20,
        ),
        Expanded(
          child: Text(
            AppStrings.allRewards,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primaryPink.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text(
            '$points pts',
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryPink,
              height: 1,
            ),
          ),
        ),
      ],
    );
  }
}

class _RewardCard extends StatelessWidget {
  const _RewardCard({
    required this.reward,
    required this.userPoints,
  });

  final RewardModel reward;
  final int userPoints;

  @override
  Widget build(BuildContext context) {
    final unlocked = reward.isUnlocked(userPoints);

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          if (unlocked) {
            AppSnackbars.show(context, AppStrings.rewardUnlockedHint);
          } else {
            final need = reward.costPts - userPoints;
            AppSnackbars.show(
              context,
              '$need ${AppStrings.pointsUntilReward}',
            );
          }
        },
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: AppTheme.softShadowLight,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
            child: Column(
              children: [
                Expanded(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 220),
                    opacity: unlocked ? 1 : 0.55,
                    child: Image.asset(
                      reward.imagePath,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: unlocked
                        ? AppColors.primaryPink.withValues(alpha: 0.1)
                        : AppColors.backgroundAlt,
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                      color: unlocked
                          ? AppColors.primaryPink.withValues(alpha: 0.35)
                          : AppColors.divider,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        unlocked ? Iconsax.tick_circle5 : Iconsax.lock_1,
                        size: 14,
                        color: unlocked
                            ? AppColors.primaryPink
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${reward.costPts} pts',
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: unlocked
                              ? AppColors.primaryPink
                              : AppColors.textSecondary,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  reward.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
