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
import '../../widgets/soft_bottom_nav_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontal =
        width >= 900 ? width * 0.18 : (width >= 700 ? 48.0 : 20.0);
    final bottomInset = SoftBottomNavBar.contentInset(context);

    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: BlocBuilder<HomeCubit, HomeState>(
          buildWhen: (p, n) =>
              p.rewardPoints != n.rewardPoints || p.rewardGoal != n.rewardGoal,
          builder: (context, state) {
            return ListView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                horizontal,
                12,
                horizontal,
                bottomInset + 8,
              ),
              children: [
                const _ProfileHeader(),
                const SizedBox(height: 22),
                _DunkinCard(points: state.rewardPoints, goal: state.rewardGoal),
                const SizedBox(height: 18),
                _PointsSection(
                  points: state.rewardPoints,
                  goal: state.rewardGoal,
                ),
                const SizedBox(height: 18),
                const _OrdersSection(),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.brandGradient,
            boxShadow: AppTheme.softShadowLight,
            border: Border.all(color: AppColors.white, width: 3),
          ),
          child: const Icon(
            Icons.person_rounded,
            color: AppColors.white,
            size: 32,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.profileName,
                style: GoogleFonts.nunito(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                AppStrings.profileEmail,
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Material(
          color: AppColors.white,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () {
              AppSnackbars.show(context, AppStrings.comingSoon);
            },
            child: const SizedBox(
              width: 42,
              height: 42,
              child: Icon(
                Iconsax.setting_2,
                size: 20,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DunkinCard extends StatelessWidget {
  const _DunkinCard({required this.points, required this.goal});

  final int points;
  final int goal;

  @override
  Widget build(BuildContext context) {
    final progress = goal == 0 ? 0.0 : (points / goal).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.profileCard, style: AppTheme.sectionHeader),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2D2926),
                Color(0xFF4A2C3A),
                Color(0xFFDA1884),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryPink.withValues(alpha: 0.28),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    AppStrings.appName,
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.orange,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      AppStrings.profileMember,
                      style: GoogleFonts.nunito(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text(
                AppStrings.profileName.toUpperCase(),
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.white,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppStrings.profileCardHint,
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 18),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  valueColor: const AlwaysStoppedAnimation(AppColors.orange),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$points / $goal ${AppStrings.pointsLabel.toLowerCase()}',
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PointsSection extends StatelessWidget {
  const _PointsSection({required this.points, required this.goal});

  final int points;
  final int goal;

  @override
  Widget build(BuildContext context) {
    final until = (goal - points).clamp(0, goal);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.profilePoints, style: AppTheme.sectionHeader),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppTheme.softShadowLight,
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.rewardsSection,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Iconsax.cup,
                  color: AppColors.primaryPink,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$points',
                      style: GoogleFonts.nunito(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryPink,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      until == 0
                          ? AppStrings.profileRewardReady
                          : '$until ${AppStrings.pointsUntilFree} ${AppStrings.freeCoffee}',
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.rewards);
                },
                child: Text(
                  AppStrings.viewRewards,
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.orange,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OrdersSection extends StatelessWidget {
  const _OrdersSection();

  static const _orders = <_OrderPreview>[
    _OrderPreview(
      title: '2 Glazed · Iced Latte',
      subtitle: 'Yesterday · Pickup',
      price: '145 EGP',
      status: 'Completed',
    ),
    _OrderPreview(
      title: 'Strawberry Frappe · Cold Foam',
      subtitle: 'Mon · Dine in',
      price: '98 EGP',
      status: 'Completed',
    ),
    _OrderPreview(
      title: 'Breakfast Sandwich',
      subtitle: 'Last week · Pickup',
      price: '120 EGP',
      status: 'Completed',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(AppStrings.profileOrders, style: AppTheme.sectionHeader),
            ),
            GestureDetector(
              onTap: () {
                AppSnackbars.show(context, AppStrings.comingSoon);
              },
              child: Text(
                AppStrings.profileSeeAll,
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryPink,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._orders.map(
          (order) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _OrderTile(order: order),
          ),
        ),
      ],
    );
  }
}

class _OrderPreview {
  const _OrderPreview({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.status,
  });

  final String title;
  final String subtitle;
  final String price;
  final String status;
}

class _OrderTile extends StatelessWidget {
  const _OrderTile({required this.order});

  final _OrderPreview order;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          context.read<HomeCubit>().setNavIndex(1);
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: AppTheme.softShadowLight,
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.pastelPeach,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Iconsax.receipt_2,
                  color: AppColors.orange,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.title,
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order.subtitle,
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    order.price,
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryPink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    order.status,
                    style: GoogleFonts.nunito(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF5A8A1A),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
