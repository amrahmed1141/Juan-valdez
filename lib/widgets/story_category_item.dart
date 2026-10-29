import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/app_colors.dart';

/// Instagram-stories style category item with a circular icon and gradient ring.
class StoryCategoryItem extends StatelessWidget {
  const StoryCategoryItem({
    super.key,
    required this.iconPath,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.size = 68,
    this.borderWidth = 2.75,
  });

  final String iconPath;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final double size;
  final double borderWidth;

  static const _animDuration = Duration(milliseconds: 280);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: size + 12,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: _animDuration,
              curve: Curves.easeOutCubic,
              width: size,
              height: size,
              padding: EdgeInsets.all(borderWidth),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // Solid inactive gradient so AnimatedContainer can lerp to pink.
                gradient: isSelected
                    ? AppColors.primaryPinkGradient
                    : const LinearGradient(
                        colors: [
                          AppColors.storyBorderInactive,
                          AppColors.storyBorderInactive,
                        ],
                      ),
              ),
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: ClipOval(
                    child: AnimatedOpacity(
                      duration: _animDuration,
                      opacity: isSelected ? 1.0 : 0.88,
                      child: Image.asset(
                        iconPath,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => ColoredBox(
                          color: AppColors.pastelPink,
                          child: Icon(
                            Icons.cake_outlined,
                            size: size * 0.35,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            AnimatedDefaultTextStyle(
              duration: _animDuration,
              style: GoogleFonts.nunito(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
                color: isSelected
                    ? AppColors.primaryPink
                    : AppColors.textSecondary,
              ),
              child: Text(
                label.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 6),
            AnimatedContainer(
              duration: _animDuration,
              width: isSelected ? 28 : 0,
              height: 3,
              decoration: BoxDecoration(
                color: AppColors.primaryPink,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
