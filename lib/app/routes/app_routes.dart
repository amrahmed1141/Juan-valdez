import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../data/models/buy_now_args.dart';
import '../../data/models/product_model.dart';
import '../../data/models/product_details_args.dart';
import '../../screens/cart/cart_screen.dart';
import '../../screens/checkout/buy_now_checkout_screen.dart';
import '../../screens/details/product_details_screen.dart';
import '../../screens/onboarding/onboarding_screen.dart';
import '../../screens/order/order_details_screen.dart';
import '../../screens/quick_reorder/quick_reorder_screen.dart';
import '../../screens/rewards/rewards_screen.dart';
import '../../screens/shell/main_shell_screen.dart';
import '../../screens/splash/splash_screen.dart';

abstract final class AppRoutes {
  static const String splash = '/';
  static const String quickReorder = '/quick-reorder';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String details = '/details';
  static const String cart = '/cart';
  static const String buyNowCheckout = '/buy-now-checkout';
  static const String orderDetails = '/order-details';
  static const String rewards = '/rewards';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _fade(const SplashScreen(), settings);
      case quickReorder:
        return _fade(const QuickReorderScreen(), settings);
      case onboarding:
        return _fade(const OnboardingScreen(), settings);
      case home:
        return _fade(const MainShellScreen(), settings);
      case details:
        final args = _resolveDetailsArgs(settings.arguments);
        return _detailsRoute(ProductDetailsScreen(args: args), settings);
      case cart:
        return _slideUp(const CartScreen(), settings);
      case buyNowCheckout:
        final args = settings.arguments;
        if (args is! BuyNowArgs) {
          throw ArgumentError(
            'Buy Now checkout expects BuyNowArgs, got ${args.runtimeType}',
          );
        }
        return _slideUp(BuyNowCheckoutScreen(args: args), settings);
      case orderDetails:
        final id = settings.arguments;
        if (id is! String) {
          throw ArgumentError(
            'Order details expects String order id, got ${id.runtimeType}',
          );
        }
        return _heroRoute(OrderDetailsScreen(orderId: id), settings);
      case rewards:
        return _slideUp(const RewardsScreen(), settings);
      default:
        return _fade(const SplashScreen(), settings);
    }
  }

  static PageRouteBuilder<dynamic> _fade(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }

  static PageRouteBuilder<dynamic> _slideUp(
    Widget page,
    RouteSettings settings,
  ) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        final tween = Tween(begin: const Offset(0, 0.08), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeOutCubic));
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: animation.drive(tween),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 320),
    );
  }

  /// Hero-friendly transition for product details.
  static PageRouteBuilder<dynamic> _detailsRoute(
    Widget page,
    RouteSettings settings,
  ) {
    return _heroRoute(page, settings);
  }

  /// Shared Hero route: do **not** wrap [child] in FadeTransition.
  ///
  /// Fading the whole page (including the destination [Hero]) prevents a
  /// visible flight. Chrome fades are handled inside each destination screen
  /// via [ModalRoute.animation] instead.
  static PageRouteBuilder<dynamic> _heroRoute(
    Widget page,
    RouteSettings settings,
  ) {
    return PageRouteBuilder(
      settings: settings,
      opaque: false,
      barrierColor: Colors.black.withValues(alpha: 0.08),
      barrierDismissible: false,
      pageBuilder: (_, __, ___) => page,
      // Jump-cut page; Hero overlay + in-screen chrome animations do the work.
      transitionsBuilder: (_, __, ___, child) => child,
      transitionDuration: const Duration(milliseconds: 480),
      reverseTransitionDuration: const Duration(milliseconds: 400),
    );
  }
}

ProductDetailsArgs _resolveDetailsArgs(Object? arguments) {
  if (arguments is ProductDetailsArgs) return arguments;
  if (arguments is ProductModel) {
    return ProductDetailsArgs.single(arguments);
  }
  throw ArgumentError(
    'Details route expects ProductDetailsArgs or ProductModel, '
    'got ${arguments.runtimeType}',
  );
}

abstract final class AppSnackbars {
  static void show(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
