import 'package:flutter/foundation.dart';
import '../../data/models/category.dart';
import '../../data/models/filter_options.dart';
import '../../data/models/product.dart';
import '../../data/repositories/product_repository.dart';

/// State representation for product feed status.
enum FeedStatus { initial, loading, success, loadingMore, error }

/// Promotional campaign banner item.
class PromoCampaign {
  final String id;
  final String tag;
  final String title;
  final String subtitle;
  final String ctaText;
  final String categorySlug;
  final String imageUrl;

  const PromoCampaign({
    required this.id,
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.ctaText,
    required this.categorySlug,
    required this.imageUrl,
  });
}

/// Home state provider implementing robust Infinite Scrolling, stale-request protection,
/// deduplication, category selection, and filter/sorting logic.
class HomeProvider extends ChangeNotifier {
  final ProductRepository _productRepository;

  // Products state
  List<Product> _products = [];
  int _totalProducts = 0;
  FeedStatus _status = FeedStatus.initial;
  String? _errorMessage;

  // Categories
  List<ProductCategory> _categories = [];
  String _selectedCategorySlug = 'all';

  // Personalized "For You"
  List<Product> _forYouProducts = [];

  // Filter & Sort
  FilterOptions _filterOptions = const FilterOptions();

  // Infinite Scrolling & Request Token (Stale response protection)
  int _currentRequestToken = 0;
  static const int _pageSize = 12;

  // Promotional campaigns for PageView Hero
  final List<PromoCampaign> _campaigns = const [
    PromoCampaign(
      id: 'summer_edit',
      tag: 'NEW COLLECTION',
      title: 'Summer Lifestyle Edit',
      subtitle: 'Effortless styles tailored for modern living.',
      ctaText: 'Explore Collection',
      categorySlug: 'womens-dresses',
      imageUrl: 'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=1000',
    ),
    PromoCampaign(
      id: 'smart_living',
      tag: 'TECH & AUDIO',
      title: 'Minimal Tech Essentials',
      subtitle: 'High precision audio and smart desk accessories.',
      ctaText: 'Shop Smart',
      categorySlug: 'smartphones',
      imageUrl: 'https://images.unsplash.com/photo-1519389950473-47ba0277781c?w=1000',
    ),
    PromoCampaign(
      id: 'beauty_radiance',
      tag: 'SELF CARE',
      title: 'Botanical Beauty Essentials',
      subtitle: 'Pure, restorative nourishment for daily rejuvenation.',
      ctaText: 'Discover Glow',
      categorySlug: 'beauty',
      imageUrl: 'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?w=1000',
    ),
    PromoCampaign(
      id: 'weekend_deals',
      tag: 'LIMITED OFFER',
      title: 'Exclusive Weekend Deals',
      subtitle: 'Up to 40% off curated premium lifestyle items.',
      ctaText: 'Claim Deals',
      categorySlug: 'all',
      imageUrl: 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=1000',
    ),
  ];

  // Getters
  List<Product> get products => List.unmodifiable(_products);
  int get totalProducts => _totalProducts;
  FeedStatus get status => _status;
  bool get isInitialLoading => _status == FeedStatus.initial || _status == FeedStatus.loading;
  bool get isLoadingMore => _status == FeedStatus.loadingMore;
  bool get hasMore => _products.length < _totalProducts;
  String? get errorMessage => _errorMessage;

  List<ProductCategory> get categories => List.unmodifiable(_categories);
  String get selectedCategorySlug => _selectedCategorySlug;

  List<Product> get forYouProducts => List.unmodifiable(_forYouProducts);
  List<PromoCampaign> get campaigns => _campaigns;
  FilterOptions get filterOptions => _filterOptions;
  bool get isOfflineFallbackActive => _productRepository.isOfflineFallbackActive;

  HomeProvider({required ProductRepository productRepository})
      : _productRepository = productRepository {
    initialize();
  }

  /// Initial load of categories, feed, and recommendations.
  Future<void> initialize() async {
    await Future.wait([
      loadCategories(),
      refreshFeed(),
    ]);
  }

  /// Loads available categories.
  Future<void> loadCategories() async {
    try {
      final list = await _productRepository.getCategories();
      _categories = [
        const ProductCategory(slug: 'all', name: 'All Products'),
        ...list,
      ];
      notifyListeners();
    } catch (_) {}
  }

  /// Refreshes feed from beginning (skip = 0).
  Future<void> refreshFeed() async {
    final token = ++_currentRequestToken;
    _status = FeedStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = _selectedCategorySlug == 'all'
          ? await _productRepository.getProducts(skip: 0, limit: _pageSize)
          : await _productRepository.getProductsByCategory(
              _selectedCategorySlug,
              skip: 0,
              limit: _pageSize,
            );

      // Discard stale responses if a newer request was dispatched
      if (token != _currentRequestToken) return;

      var items = _applyClientFiltering(result.products);
      _products = _deduplicate(items);
      _totalProducts = result.total;
      _status = FeedStatus.success;

      // Also trigger personalized recommendations
      _loadForYou();
      notifyListeners();
    } catch (e) {
      if (token != _currentRequestToken) return;
      _status = FeedStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Loads the next page of products when user scrolls within 300px of bottom.
  Future<void> loadMoreProducts() async {
    // Guards: do nothing if already loading, at end of list, or in error state
    if (_status == FeedStatus.loadingMore ||
        _status == FeedStatus.loading ||
        !hasMore ||
        _products.isEmpty) {
      return;
    }

    final token = _currentRequestToken;
    _status = FeedStatus.loadingMore;
    notifyListeners();

    try {
      final currentSkip = _products.length;
      final result = _selectedCategorySlug == 'all'
          ? await _productRepository.getProducts(skip: currentSkip, limit: _pageSize)
          : await _productRepository.getProductsByCategory(
              _selectedCategorySlug,
              skip: currentSkip,
              limit: _pageSize,
            );

      // Stale check
      if (token != _currentRequestToken) return;

      final filteredNew = _applyClientFiltering(result.products);
      final merged = [..._products, ...filteredNew];
      _products = _deduplicate(merged);
      _totalProducts = result.total;
      _status = FeedStatus.success;
      notifyListeners();
    } catch (e) {
      if (token != _currentRequestToken) return;
      // Critical: Do NOT clear existing products on pagination error!
      _status = FeedStatus.success; // preserve items, show snack/subtle indicator
      notifyListeners();
    }
  }

  /// Selects a category chip.
  void selectCategory(String slug) {
    if (_selectedCategorySlug == slug) return;
    _selectedCategorySlug = slug;
    refreshFeed();
  }

  /// Applies active filters & sort.
  void applyFilters(FilterOptions options) {
    _filterOptions = options;
    if (options.selectedCategory != null && options.selectedCategory!.isNotEmpty) {
      _selectedCategorySlug = options.selectedCategory!;
    }
    refreshFeed();
  }

  void clearFilters() {
    _filterOptions = const FilterOptions();
    refreshFeed();
  }

  Future<void> _loadForYou() async {
    try {
      final items = await _productRepository.getPersonalizedForYou([], {});
      _forYouProducts = items;
      notifyListeners();
    } catch (_) {}
  }

  /// Deduplicates products to guarantee stable IDs and no key collision in SliverGrid.
  List<Product> _deduplicate(List<Product> list) {
    final seen = <int>{};
    final unique = <Product>[];
    for (final item in list) {
      if (seen.add(item.id)) {
        unique.add(item);
      }
    }
    return unique;
  }

  /// Client-side filtering and sorting for active filter tokens.
  List<Product> _applyClientFiltering(List<Product> raw) {
    var filtered = List<Product>.from(raw);

    if (_filterOptions.minPrice != null) {
      filtered = filtered.where((p) => p.price >= _filterOptions.minPrice!).toList();
    }
    if (_filterOptions.maxPrice != null) {
      filtered = filtered.where((p) => p.price <= _filterOptions.maxPrice!).toList();
    }
    if (_filterOptions.minRating != null) {
      filtered = filtered.where((p) => p.rating >= _filterOptions.minRating!).toList();
    }
    if (_filterOptions.inStockOnly) {
      filtered = filtered.where((p) => p.stock > 0).toList();
    }

    switch (_filterOptions.sortBy) {
      case SortOption.priceLowToHigh:
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceHighToLow:
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOption.rating:
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case SortOption.discount:
        filtered.sort((a, b) => b.discountPercentage.compareTo(a.discountPercentage));
        break;
      case SortOption.relevance:
        break;
    }

    return filtered;
  }
}
