import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/routes/app_routes.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../cubits/home/home_cubit.dart';
import '../../cubits/home/home_state.dart';
import '../../cubits/order/order_cubit.dart';
import '../../cubits/order/order_state.dart';
import '../../data/mock/product_mock_data.dart';
import '../../data/models/product_model.dart';
import '../../data/models/product_details_args.dart';
import '../../widgets/craving_section.dart';
import '../../widgets/explore_category_item.dart';
import '../../widgets/fulfillment_chip.dart';
import '../../widgets/order_tracking_card.dart';
import '../../widgets/picked_for_you_card.dart';
import '../../widgets/reward_progress_card.dart';
import '../../widgets/section_reveal.dart';
import '../../widgets/soft_bottom_nav_bar.dart';
import '../../widgets/trending_product_card.dart';
import '../../widgets/usual_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
          builder: (context, state) {
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontal,
                      8,
                      horizontal,
                      0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _HomeHeader(),
                        const SizedBox(height: 16),
                        const _ModernSearchBar(),
                        const SizedBox(height: 12),
                        const FulfillmentChip(),
                        const SizedBox(height: 12),
                        const _DineInCheckInCard(),
                        const SizedBox(height: 16),
                        const OrderTrackingCard(),
                        const SizedBox(height: 8),

                        // 0) As Your Usual — habitual reorder
                        const SectionReveal(
                          delay: Duration(milliseconds: 20),
                          child: UsualSection(),
                        ),
                        const SizedBox(height: 20),

                        // 1) Picked For You
                        SectionReveal(
                          delay: const Duration(milliseconds: 80),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppStrings.pickedForYou,
                                style: AppTheme.sectionHeader,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                AppStrings.pickedForYouHint,
                                style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 22),
                              PickedForYouCard(
                                product: ProductMockData.pickedForYou,
                                heroTag:
                                    'hero_picked_${ProductMockData.pickedForYou.id}',
                                isFavorite: state.isFavorite(
                                  ProductMockData.pickedForYou.id,
                                ),
                                onFavorite: () {
                                  context.read<HomeCubit>().toggleFavorite(
                                        ProductMockData.pickedForYou,
                                      );
                                },
                                onAddToCart: () {
                                  AppSnackbars.show(
                                    context,
                                    AppStrings.orderingDisabled,
                                  );
                                },
                                onOpenDetails: () {
                                  Navigator.of(context).pushNamed(
                                    AppRoutes.details,
                                    arguments:
                                        ProductDetailsArgs.fromSection(
                                      product: ProductMockData.pickedForYou,
                                      products: ProductMockData.allProducts,
                                      sectionTitle: AppStrings.pickedForYou,
                                      heroTag:
                                          'hero_picked_${ProductMockData.pickedForYou.id}',
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 2) Dunkin Rewards — directly under Picked For You
                        SectionReveal(
                          delay: const Duration(milliseconds: 100),
                          child: RewardProgressCard(
                            points: state.rewardPoints,
                            goal: state.rewardGoal,
                            onViewRewards: () {
                              Navigator.of(context)
                                  .pushNamed(AppRoutes.rewards);
                            },
                          ),
                        ),
                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                ),

                // 3) Trending Now — colored section wash
                SliverToBoxAdapter(
                  child: SectionReveal(
                    delay: const Duration(milliseconds: 160),
                    child: _ColoredSection(
                      color: AppColors.trendingSection,
                      child: _TrendingNowSection(
                        horizontal: horizontal,
                        onAdd: (context, product) {
                          AppSnackbars.show(
                            context,
                            AppStrings.orderingDisabled,
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // 4) Explore — colored section wash
                SliverToBoxAdapter(
                  child: SectionReveal(
                    delay: const Duration(milliseconds: 220),
                    child: _ColoredSection(
                      color: AppColors.exploreSection,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          horizontal,
                          22,
                          horizontal,
                          22,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.explore,
                              style: AppTheme.sectionHeader.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const _ExploreStrip(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontal,
                      28,
                      horizontal,
                      0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 5) What Are You Craving? (A+B+C)
                        SectionReveal(
                          delay: const Duration(milliseconds: 300),
                          child: CravingSection(
                            state: state,
                            heroScope: 'craving_home',
                          ),
                        ),
                        SizedBox(height: bottomInset + 8),
                      ],
                    ),
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


class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.brandRed,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Image.asset(
                  AppAssets.logo,
                  height: 22,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Text(
                    AppStrings.appName,
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.homeGreeting,
                style: GoogleFonts.nunito(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
        _HeaderCircleButton(
          icon: Icons.notifications_none_rounded,
          onTap: () {
            AppSnackbars.show(context, AppStrings.comingSoon);
          },
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () {
            context.read<HomeCubit>().setNavIndex(2);
          },
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.brandRed,
              border: Border.all(color: AppColors.white, width: 2),
              boxShadow: AppTheme.softShadowLight,
            ),
            child: const Icon(
              Icons.table_restaurant_rounded,
              color: AppColors.white,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }
}

class _DineInCheckInCard extends StatefulWidget {
  const _DineInCheckInCard();

  @override
  State<_DineInCheckInCard> createState() => _DineInCheckInCardState();
}

class _DineInCheckInCardState extends State<_DineInCheckInCard> {
  bool _autoStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_autoStarted) return;
    final home = context.read<HomeCubit>().state;
    final orders = context.read<OrderCubit>().state;
    if (home.checkedIn && orders.activeOrder == null) {
      _autoStarted = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<OrderCubit>().startDineInVisit(
              store: home.selectedStore,
              tableNumber: home.tableNumber,
            );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, home) {
        return BlocBuilder<OrderCubit, OrderState>(
          builder: (context, orders) {
            if (orders.activeOrder != null) {
              return const SizedBox.shrink();
            }

            final table = home.tableNumber;
            final subtitle = table != null && table.isNotEmpty
                ? '${home.selectedStore.name} · ${AppStrings.tableLabel} $table'
                : '${home.selectedStore.name} · ${AppStrings.menuBrowseHint}';

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
              decoration: BoxDecoration(
                color: AppColors.brandRed,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppTheme.softShadowLight,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.startDineIn,
                          style: GoogleFonts.nunito(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  FilledButton(
                    onPressed: () {
                      final cubit = context.read<HomeCubit>();
                      cubit.checkInAtCafe(
                        store: home.selectedStore,
                        table: home.tableNumber ?? '4',
                      );
                      context.read<OrderCubit>().startDineInVisit(
                            store: cubit.state.selectedStore,
                            tableNumber: cubit.state.tableNumber,
                          );
                      AppSnackbars.show(context, AppStrings.orderPlaced);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.white,
                      foregroundColor: AppColors.brandRed,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      AppStrings.imAtCafe,
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _HeaderCircleButton extends StatelessWidget {
  const _HeaderCircleButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primaryPink,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: AppColors.white, size: 22),
        ),
      ),
    );
  }
}


class _ModernSearchBar extends StatelessWidget {
  const _ModernSearchBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppTheme.softShadowLight,
      ),
      child: TextField(
        readOnly: true,
        onTap: () {
          AppSnackbars.show(context, AppStrings.comingSoon);
        },
        style: GoogleFonts.nunito(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: AppStrings.homeSearchHint,
          hintStyle: GoogleFonts.nunito(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.primaryPink,
            size: 22,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

class _ColoredSection extends StatelessWidget {
  const _ColoredSection({
    required this.color,
    required this.child,
  });

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: color,
      child: child,
    );
  }
}

class _ExploreStrip extends StatefulWidget {
  const _ExploreStrip();

  @override
  State<_ExploreStrip> createState() => _ExploreStripState();
}

class _ExploreStripState extends State<_ExploreStrip> {
  late final ScrollController _controller;
  double _offset = 0;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController()
      ..addListener(() {
        setState(() => _offset = _controller.offset);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 142,
      child: ListView.separated(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: ProductMockData.exploreCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final item = ProductMockData.exploreCategories[index];
          return ExploreCategoryItem(
            imagePath: item.imagePath,
            label: item.label,
            index: index,
            scrollOffset: _offset,
            onTap: () {
              final cubit = context.read<HomeCubit>();
              cubit.selectCategory(item.label);
              cubit.revealFullMenu();
            },
          );
        },
      ),
    );
  }
}

class _TrendingNowSection extends StatefulWidget {
  const _TrendingNowSection({
    required this.horizontal,
    required this.onAdd,
  });

  final double horizontal;
  final void Function(BuildContext context, ProductModel product) onAdd;

  @override
  State<_TrendingNowSection> createState() => _TrendingNowSectionState();
}

class _TrendingNowSectionState extends State<_TrendingNowSection> {
  late final ScrollController _controller;
  double _offset = 0;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController()
      ..addListener(() {
        setState(() => _offset = _controller.offset);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        widget.horizontal,
        12,
        0,
        12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              right: widget.horizontal,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.trendingNow,
                  style: AppTheme.sectionHeader,
                ),
                const SizedBox(height: 2),
                Text(
                  AppStrings.trendingHint,
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            height: TrendingProductCard.totalHeight,
            child: ListView.separated(
              controller: _controller,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              clipBehavior: Clip.none,
              padding: EdgeInsets.only(
                right: widget.horizontal,
              ),
              itemCount: ProductMockData.trending.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final product = ProductMockData.trending[index];
                final tag = 'hero_trending_${product.id}';
                return TrendingProductCard(
                  product: product,
                  index: index,
                  scrollOffset: _offset,
                  heroTag: tag,
                  onAdd: () => widget.onAdd(context, product),
                  onOpen: () {
                    Navigator.of(context).pushNamed(
                      AppRoutes.details,
                      arguments: ProductDetailsArgs.fromSection(
                        product: product,
                        products: ProductMockData.trending,
                        sectionTitle: AppStrings.trendingNow,
                        heroTag: tag,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
