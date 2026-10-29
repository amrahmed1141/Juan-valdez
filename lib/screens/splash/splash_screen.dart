import 'package:flutter/material.dart';

import '../../app/routes/app_routes.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../shell/main_shell_screen.dart';

/// Juan Valdez splash — solid brand red with logo only, then home.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const int _totalMs = 1800;

  late final AnimationController _controller;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _totalMs),
    );

    _logoOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 200),
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 500,
      ),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 1100),
    ]).animate(_controller);

    _logoScale = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(0.88), weight: 200),
      TweenSequenceItem(
        tween: Tween(begin: 0.88, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 500,
      ),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 1100),
    ]).animate(_controller);

    _controller.forward();
    _controller.addStatusListener(_onStatus);
  }

  void _onStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || !mounted) return;
    _goHome();
  }

  void _goHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        settings: const RouteSettings(name: AppRoutes.home),
        pageBuilder: (_, __, ___) => const MainShellScreen(),
        transitionDuration: const Duration(milliseconds: 480),
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return ColoredBox(
            color: AppColors.brandRed,
            child: FadeTransition(
              opacity: curved,
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_onStatus);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final logoWidth = size.width >= 700 ? 300.0 : size.width * 0.62;

    return Scaffold(
      backgroundColor: AppColors.brandRed,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return ColoredBox(
            color: AppColors.brandRed,
            child: SizedBox.expand(
              child: Center(
                child: Opacity(
                  opacity: _logoOpacity.value.clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: _logoScale.value,
                    child: Image.asset(
                      AppAssets.logo,
                      width: logoWidth,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                      errorBuilder: (_, __, ___) {
                        return Text(
                          'Juan Valdez',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: size.width * 0.08,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
