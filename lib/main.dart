import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app/routes/app_routes.dart';
import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'cubits/cart/cart_cubit.dart';
import 'cubits/home/home_cubit.dart';
import 'cubits/order/order_cubit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const JuanValdezApp());
}

class JuanValdezApp extends StatelessWidget {
  const JuanValdezApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => CartCubit()),
        BlocProvider(create: (_) {
          final home = HomeCubit();
          _applyLaunchQr(home);
          return home;
        }),
        BlocProvider(create: (_) => OrderCubit()),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }

  /// Table QR example: `/?dine-in&store=zamalek&table=4`
  static void _applyLaunchQr(HomeCubit home) {
    final uri = Uri.base;
    final params = uri.queryParameters;
    final pathSaysDineIn = uri.path.contains('dine-in');
    final flag = params.containsKey('dine-in') ||
        params['mode'] == 'dine-in' ||
        pathSaysDineIn;
    if (!flag && params['store'] == null && params['table'] == null) {
      return;
    }
    home.applyQrCheckIn(
      storeId: params['store'],
      table: params['table'],
    );
  }
}
