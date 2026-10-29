import 'package:flutter/material.dart';

/// Juan Valdez Café brand palette (aligned with juanvaldez.eg / cup identity).
abstract final class AppColors {
  // Core brand
  static const Color brandRed = Color(0xFF7A1E2B);
  static const Color brandGold = Color(0xFFC6A15B);
  static const Color cream = Color(0xFFF8F4EF);
  static const Color dark = Color(0xFF2A1816);
  static const Color white = Color(0xFFFFFFFF);

  /// Legacy aliases so existing widgets keep compiling during rebrand.
  static const Color primaryPink = brandRed;
  static const Color orange = brandRed;
  static const Color accent = brandRed;
  static const Color badgeOrange = brandGold;

  static const Color background = cream;
  static const Color backgroundAlt = Color(0xFFF3EBE3);
  static const Color card = white;
  static const Color accentSoft = Color(0xFFD4A0A8);
  static const Color textPrimary = dark;
  static const Color textSecondary = Color(0xFF8A7A74);
  static const Color divider = Color(0xFFE8E0D8);
  static const Color navInactive = Color(0xFFB0A49C);
  static const Color shadow = Color(0x1A2A1816);
  static const Color searchBorder = Color(0xFFE0D8D0);
  static const Color progressTrack = Color(0xFFE8E0D8);
  static const Color offerGreen = Color(0xFFC6F54F);

  /// Soft section washes
  static const Color exploreSection = Color(0xFFF3EDE4);
  static const Color trendingSection = Color(0xFFF5E8EA);
  static const Color rewardsSection = Color(0xFFF8EEE8);

  // Soft product backdrops
  static const Color pastelTeal = Color(0xFFB8E8E0);
  static const Color pastelPink = Color(0xFFFFD6E5);
  static const Color pastelYellow = Color(0xFFFFF0C2);
  static const Color pastelMint = Color(0xFFD4F5D4);
  static const Color pastelLavender = Color(0xFFE8D5F5);
  static const Color pastelPeach = Color(0xFFFFE0CC);
  static const Color pastelBlue = Color(0xFFD0E8FF);
  static const Color pastelCream = Color(0xFFFFF5E6);

  static const Color storyBorderInactive = Color(0xFFE8C4D0);

  static const LinearGradient primaryPinkGradient = LinearGradient(
    colors: [
      Color(0xFF7A1E2B),
      Color(0xFF9A2E3D),
      Color(0xFFD4A0A8),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient brandGradient = LinearGradient(
    colors: [
      Color(0xFF7A1E2B),
      Color(0xFFC6A15B),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [
      Color(0xFF7A1E2B),
      Color(0xFF5C1520),
      Color(0xFF7A1E2B),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
