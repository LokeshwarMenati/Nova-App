import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/app_button.dart';
import '../../../data/models/filter_options.dart';
import '../../../core/utils/formatters.dart';

/// Interactive modal bottom sheet for filtering and sorting products.
class FilterBottomSheet extends StatefulWidget {
  final FilterOptions initialOptions;
  final ValueChanged<FilterOptions> onApply;

  const FilterBottomSheet({
    super.key,
    required this.initialOptions,
    required this.onApply,
  });

  static Future<void> show({
    required BuildContext context,
    required FilterOptions initialOptions,
    required ValueChanged<FilterOptions> onApply,
  }) {
    return AppBottomSheetWrapper.show(
      context: context,
      title: 'Filter & Sort',
      child: FilterBottomSheet(
        initialOptions: initialOptions,
        onApply: onApply,
      ),
    );
  }

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late RangeValues _priceRange;
  late double? _minRating;
  late bool _inStockOnly;
  late SortOption _sortBy;

  @override
  void initState() {
    super.initState();
    _priceRange = RangeValues(
      widget.initialOptions.minPrice ?? 0,
      widget.initialOptions.maxPrice ?? 2000,
    );
    _minRating = widget.initialOptions.minRating;
    _inStockOnly = widget.initialOptions.inStockOnly;
    _sortBy = widget.initialOptions.sortBy;
  }

  void _apply() {
    final updated = widget.initialOptions.copyWith(
      minPrice: _priceRange.start > 0 ? _priceRange.start : null,
      maxPrice: _priceRange.end < 2000 ? _priceRange.end : null,
      minRating: _minRating,
      inStockOnly: _inStockOnly,
      sortBy: _sortBy,
    );
    widget.onApply(updated);
    Navigator.of(context).pop();
  }

  void _reset() {
    setState(() {
      _priceRange = const RangeValues(0, 2000);
      _minRating = null;
      _inStockOnly = false;
      _sortBy = SortOption.relevance;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sort Options
          _buildSectionTitle('Sort By', isDark),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: SortOption.values.map((sort) {
              final selected = _sortBy == sort;
              return ChoiceChip(
                label: Text(sort.label),
                selected: selected,
                selectedColor: isDark ? AppColors.primaryContainerDark : AppColors.primaryContainerLight,
                labelStyle: TextStyle(
                  color: selected
                      ? (isDark ? AppColors.primaryLight : AppColors.primary)
                      : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 13,
                ),
                onSelected: (_) => setState(() => _sortBy = sort),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Price Range Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionTitle('Price Range', isDark),
              Text(
                '${Formatters.formatCurrency(_priceRange.start)} - ${Formatters.formatCurrency(_priceRange.end)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.primaryLight : AppColors.primary,
                ),
              ),
            ],
          ),
          RangeSlider(
            values: _priceRange,
            min: 0,
            max: 2000,
            divisions: 40,
            activeColor: isDark ? AppColors.primaryLight : AppColors.primary,
            inactiveColor: isDark ? Colors.white12 : Colors.black12,
            labels: RangeLabels(
              Formatters.formatCurrency(_priceRange.start),
              Formatters.formatCurrency(_priceRange.end),
            ),
            onChanged: (vals) => setState(() => _priceRange = vals),
          ),
          const SizedBox(height: 20),

          // Minimum Rating
          _buildSectionTitle('Customer Rating', isDark),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildRatingChip(null, 'All', isDark),
              const SizedBox(width: 8),
              _buildRatingChip(3.5, '3.5★ +', isDark),
              const SizedBox(width: 8),
              _buildRatingChip(4.0, '4.0★ +', isDark),
              const SizedBox(width: 8),
              _buildRatingChip(4.5, '4.5★ +', isDark),
            ],
          ),
          const SizedBox(height: 20),

          // In Stock Only Toggle
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'In Stock Only',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            subtitle: Text(
              'Exclude items temporarily sold out',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            value: _inStockOnly,
            activeColor: isDark ? AppColors.primaryLight : AppColors.primary,
            onChanged: (val) => setState(() => _inStockOnly = val),
          ),
          const SizedBox(height: 28),

          // Action Buttons: Reset & Apply
          Row(
            children: [
              Expanded(
                flex: 2,
                child: AppButton(
                  text: 'Reset',
                  isOutlined: true,
                  onPressed: _reset,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: AppButton(
                  text: 'Apply Filters',
                  onPressed: _apply,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      ),
    );
  }

  Widget _buildRatingChip(double? rating, String label, bool isDark) {
    final selected = _minRating == rating;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: isDark ? AppColors.primaryContainerDark : AppColors.primaryContainerLight,
      labelStyle: TextStyle(
        color: selected
            ? (isDark ? AppColors.primaryLight : AppColors.primary)
            : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        fontSize: 13,
      ),
      onSelected: (_) => setState(() => _minRating = rating),
    );
  }
}
