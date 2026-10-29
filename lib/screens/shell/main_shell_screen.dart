import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_colors.dart';
import '../../cubits/home/home_cubit.dart';
import '../../cubits/home/home_state.dart';
import '../../widgets/soft_bottom_nav_bar.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../shop/shop_screen.dart';

/// Root shell: Home · Menu · Visit.
class MainShellScreen extends StatelessWidget {
  const MainShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          BlocBuilder<HomeCubit, HomeState>(
            buildWhen: (prev, next) => prev.navIndex != next.navIndex,
            builder: (context, state) {
              return IndexedStack(
                index: state.navIndex.clamp(0, 2),
                sizing: StackFit.expand,
                children: const [
                  HomeScreen(),
                  ShopScreen(),
                  ProfileScreen(),
                ],
              );
            },
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BlocBuilder<HomeCubit, HomeState>(
              buildWhen: (prev, next) => prev.navIndex != next.navIndex,
              builder: (context, state) {
                return SoftBottomNavBar(
                  currentIndex: state.navIndex.clamp(0, 2),
                  onTap: (index) {
                    context.read<HomeCubit>().setNavIndex(index);
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
