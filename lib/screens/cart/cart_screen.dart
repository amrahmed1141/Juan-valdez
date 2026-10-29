import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/routes/app_routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../cubits/cart/cart_cubit.dart';
import '../../cubits/cart/cart_state.dart';
import '../../cubits/home/home_cubit.dart';
import '../../widgets/cart_item_tile.dart';
import '../../widgets/dunkin_brand.dart';
import '../../widgets/soft_bottom_nav_bar.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({
    super.key,
    this.embedded = false,
  });

  /// When true, used as a shell tab — no back button, room for floating nav.
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontal =
        width >= 900 ? width * 0.2 : (width >= 700 ? 48.0 : 24.0);
    final bottomPad =
        embedded ? SoftBottomNavBar.contentInset(context) : 20.0;

    final body = SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(horizontal, 8, horizontal, bottomPad),
        child: Column(
          children: [
            Row(
              children: [
                if (!embedded)
                  DunkinIconButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Navigator.of(context).pop(),
                    size: 40,
                    iconSize: 20,
                  )
                else
                  const SizedBox(width: 40),
                Expanded(
                  child: Text(
                    AppStrings.myCart,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: BlocBuilder<CartCubit, CartState>(
                builder: (context, state) {
                  if (state.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            size: 64,
                            color: AppColors.accent.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AppStrings.cartEmpty,
                            style: GoogleFonts.nunito(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppStrings.cartEmptyHint,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (embedded) ...[
                            const SizedBox(height: 20),
                            FilledButton(
                              onPressed: () {
                                context.read<HomeCubit>().setNavIndex(1);
                              },
                              child: const Text('Browse menu'),
                            ),
                          ],
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: state.items.length,
                    itemBuilder: (context, index) {
                      final item = state.items[index];
                      return CartItemTile(
                        item: item,
                        onIncrement: () {
                          context.read<CartCubit>().increment(item.product.id);
                        },
                        onDecrement: () {
                          context.read<CartCubit>().decrement(item.product.id);
                        },
                        onDelete: () {
                          context.read<CartCubit>().removeItem(item.product.id);
                        },
                      );
                    },
                  );
                },
              ),
            ),
            BlocBuilder<CartCubit, CartState>(
              builder: (context, state) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.totalAmount,
                              style: GoogleFonts.nunito(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              state.isEmpty ? '\$ 0' : state.formattedTotal,
                              style: GoogleFonts.nunito(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryPink,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: state.isEmpty
                            ? null
                            : () {
                                context.read<CartCubit>().placeOrder();
                                AppSnackbars.show(
                                  context,
                                  AppStrings.orderPlaced,
                                );
                                if (embedded) {
                                  context.read<HomeCubit>().setNavIndex(0);
                                } else {
                                  Navigator.of(context).popUntil(
                                    (route) =>
                                        route.settings.name == AppRoutes.home,
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.orange,
                          disabledBackgroundColor:
                              AppColors.orange.withValues(alpha: 0.4),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          AppStrings.placeOrder,
                          style: GoogleFonts.nunito(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );

    if (embedded) {
      return ColoredBox(color: AppColors.background, child: body);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: body,
    );
  }
}
