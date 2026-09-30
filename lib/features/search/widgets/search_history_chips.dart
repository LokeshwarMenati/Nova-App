import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';

/// Renders recent search history and curated trending tags.
class SearchHistoryChips extends StatelessWidget {
  final List<String> recentSearches;
  final List<String> trendingSearches;
  final ValueChanged<String> onSelectSearch;
  final VoidCallback onClearRecent;

  const SearchHistoryChips({
    super.key,
    required this.recentSearches,
    required this.trendingSearches,
    required this.onSelectSearch,
    required this.onClearRecent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent Searches section
          if (recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Searches',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: onClearRecent,
                  child: Text(
                    'Clear All',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.primaryLight : AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: recentSearches.map((query) {
                return ActionChip(
                  avatar: Icon(
                    Icons.history_rounded,
                    size: 14,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                  label: Text(query),
                  backgroundColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusFull),
                  side: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                  labelStyle: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                  onPressed: () => onSelectSearch(query),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
          ],

          // Trending Searches section
          Row(
            children: [
              const Icon(Icons.local_fire_department_rounded, size: 18, color: AppColors.accent),
              const SizedBox(width: 6),
              Text(
                'Trending Right Now',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: trendingSearches.map((tag) {
              return ActionChip(
                label: Text(tag),
                backgroundColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusFull),
                side: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
                labelStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
                onPressed: () => onSelectSearch(tag),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
