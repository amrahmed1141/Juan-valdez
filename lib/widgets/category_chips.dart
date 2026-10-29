import 'package:flutter/material.dart';

import '../core/constants/app_assets.dart';
import '../core/constants/app_colors.dart';
import 'story_category_item.dart';

class CategoryChips extends StatelessWidget {
  const CategoryChips({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                for (var i = 0; i < categories.length; i++) ...[
                  if (i > 0) const SizedBox(width: 18),
                  StoryCategoryItem(
                    iconPath: AppAssets.categoryIcons[categories[i]] ??
                        AppAssets.categorySignature,
                    label: categories[i],
                    isSelected: categories[i] == selected,
                    onTap: () => onSelected(categories[i]),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.searchBorder),
          ),
          child: const Icon(
            Icons.tune_rounded,
            size: 20,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
