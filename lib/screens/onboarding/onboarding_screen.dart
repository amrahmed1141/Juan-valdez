import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/routes/app_routes.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isWide = size.width >= 700;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                isWide ? 48 : 28,
                28,
                isWide ? 48 : 28,
                24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.brandRed,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 16,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Image.asset(
                      AppAssets.logo,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: isWide ? 36 : 28),
                  Text(
                    AppStrings.appName,
                    style: GoogleFonts.nunito(
                      fontSize: isWide ? 42 : 34,
                      fontWeight: FontWeight.w800,
                      color: AppColors.brandRed,
                      height: 1.1,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppStrings.brandTagline,
                    style: GoogleFonts.nunito(
                      fontSize: isWide ? 15 : 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryPink,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isWide ? 420 : size.width * 0.78,
                    ),
                    child: Text(
                      AppStrings.onboardingSubtitle,
                      style: GoogleFonts.nunito(
                        fontSize: isWide ? 16 : 14,
                        height: 1.55,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: isWide ? size.width * 0.05 : -size.width * 0.12,
              bottom: isWide ? 40 : 70,
              child: Image.asset(
                AppAssets.heroBrand,
                width: isWide ? size.width * 0.45 : size.width * 0.78,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
            Positioned(
              right: isWide ? 48 : 28,
              bottom: 36,
              child: Row(
                children: [
                  Text(
                    AppStrings.explore,
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Material(
                    color: AppColors.orange,
                    shape: const CircleBorder(),
                    elevation: 4,
                    shadowColor: AppColors.orange.withOpacity(0.4),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () {
                        Navigator.of(context).pushReplacementNamed(
                          AppRoutes.home,
                        );
                      },
                      child: const SizedBox(
                        width: 56,
                        height: 56,
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
