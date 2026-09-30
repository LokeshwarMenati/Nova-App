/// Sorting options available for product feeds.
enum SortOption {
  relevance('Relevance'),
  priceLowToHigh('Price: Low to High'),
  priceHighToLow('Price: High to Low'),
  rating('Highest Rated'),
  discount('Biggest Discount');

  final String label;
  const SortOption(this.label);
}

/// Filter options model for modal sheet and product filtering.
class FilterOptions {
  final double? minPrice;
  final double? maxPrice;
  final double? minRating;
  final String? selectedCategory;
  final bool inStockOnly;
  final SortOption sortBy;

  const FilterOptions({
    this.minPrice,
    this.maxPrice,
    this.minRating,
    this.selectedCategory,
    this.inStockOnly = false,
    this.sortBy = SortOption.relevance,
  });

  /// Count of user-applied non-default filters.
  int get activeFilterCount {
    int count = 0;
    if (minPrice != null && minPrice! > 0) count++;
    if (maxPrice != null && maxPrice! < 2000) count++;
    if (minRating != null && minRating! > 0) count++;
    if (selectedCategory != null && selectedCategory != 'all' && selectedCategory!.isNotEmpty) count++;
    if (inStockOnly) count++;
    if (sortBy != SortOption.relevance) count++;
    return count;
  }

  bool get isDefault => activeFilterCount == 0;

  FilterOptions copyWith({
    double? minPrice,
    double? maxPrice,
    double? minRating,
    String? selectedCategory,
    bool? inStockOnly,
    SortOption? sortBy,
  }) {
    return FilterOptions(
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minRating: minRating ?? this.minRating,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      inStockOnly: inStockOnly ?? this.inStockOnly,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  FilterOptions reset() => const FilterOptions();
}
