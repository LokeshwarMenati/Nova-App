import 'package:flutter/foundation.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/debounce.dart';
import '../../data/local/local_storage_service.dart';
import '../../data/models/filter_options.dart';
import '../../data/models/product.dart';
import '../../data/repositories/product_repository.dart';

/// State representation for Search screen.
enum SearchStatus { idle, loading, success, loadingMore, error }

/// Search state management with 400ms debounce, history, trending, and pagination.
class SearchProvider extends ChangeNotifier {
  final ProductRepository _productRepository;
  final LocalStorageService _localStorage;
  final Debouncer _debouncer = Debouncer(
    delay: const Duration(milliseconds: AppConstants.searchDebounceMs),
  );

  String _query = '';
  List<Product> _results = [];
  int _totalResults = 0;
  SearchStatus _status = SearchStatus.idle;
  String? _errorMessage;

  List<String> _recentSearches = [];
  final List<String> _trendingSearches = const [
    'Sneakers',
    'Smart Watch',
    'Perfume',
    'Desk Setup',
    'Leather Bag',
    'Skin Glow',
    'Sunglasses',
    'Headphones',
  ];

  FilterOptions _filterOptions = const FilterOptions();
  int _searchToken = 0;
  static const int _pageSize = 12;

  // Getters
  String get query => _query;
  List<Product> get results => List.unmodifiable(_results);
  int get totalResults => _totalResults;
  SearchStatus get status => _status;
  bool get isLoading => _status == SearchStatus.loading;
  bool get isLoadingMore => _status == SearchStatus.loadingMore;
  bool get hasMore => _results.length < _totalResults;
  String? get errorMessage => _errorMessage;

  List<String> get recentSearches => List.unmodifiable(_recentSearches);
  List<String> get trendingSearches => _trendingSearches;
  FilterOptions get filterOptions => _filterOptions;

  SearchProvider({
    required ProductRepository productRepository,
    required LocalStorageService localStorage,
  })  : _productRepository = productRepository,
        _localStorage = localStorage {
    _loadHistory();
  }

  void _loadHistory() {
    _recentSearches = _localStorage.getRecentSearches();
    notifyListeners();
  }

  /// Called on search text change. Triggers 400ms debouncer.
  void onQueryChanged(String newQuery) {
    _query = newQuery;
    if (newQuery.trim().isEmpty) {
      _results.clear();
      _status = SearchStatus.idle;
      notifyListeners();
      return;
    }
    _debouncer.run(() => executeSearch(newQuery));
  }

  /// Immediate search execution (e.g. on keyboard submit or chip tap).
  Future<void> executeSearch(String rawQuery) async {
    final cleanQuery = rawQuery.trim();
    if (cleanQuery.isEmpty) return;

    _query = cleanQuery;
    final token = ++_searchToken;
    _status = SearchStatus.loading;
    _errorMessage = null;
    notifyListeners();

    // Persist to search history
    await _localStorage.addRecentSearch(cleanQuery);
    _loadHistory();

    try {
      final result = await _productRepository.searchProducts(
        cleanQuery,
        skip: 0,
        limit: _pageSize,
      );

      if (token != _searchToken) return;

      final filtered = _applyFilters(result.products);
      _results = _deduplicate(filtered);
      _totalResults = result.total;
      _status = SearchStatus.success;
      notifyListeners();
    } catch (e) {
      if (token != _searchToken) return;
      _status = SearchStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Infinite scrolling pagination for search results.
  Future<void> loadMoreSearchResults() async {
    if (_status == SearchStatus.loadingMore ||
        _status == SearchStatus.loading ||
        !hasMore ||
        _results.isEmpty) {
      return;
    }

    final token = _searchToken;
    _status = SearchStatus.loadingMore;
    notifyListeners();

    try {
      final currentSkip = _results.length;
      final result = await _productRepository.searchProducts(
        _query,
        skip: currentSkip,
        limit: _pageSize,
      );

      if (token != _searchToken) return;

      final filtered = _applyFilters(result.products);
      final merged = [..._results, ...filtered];
      _results = _deduplicate(merged);
      _totalResults = result.total;
      _status = SearchStatus.success;
      notifyListeners();
    } catch (e) {
      if (token != _searchToken) return;
      _status = SearchStatus.success; // preserve loaded results
      notifyListeners();
    }
  }

  void clearSearch() {
    _query = '';
    _results.clear();
    _status = SearchStatus.idle;
    notifyListeners();
  }

  Future<void> clearHistory() async {
    await _localStorage.clearRecentSearches();
    _recentSearches.clear();
    notifyListeners();
  }

  void applyFilters(FilterOptions options) {
    _filterOptions = options;
    if (_query.isNotEmpty) {
      executeSearch(_query);
    }
  }

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

  List<Product> _applyFilters(List<Product> list) {
    var filtered = List<Product>.from(list);
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
    return filtered;
  }

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }
}
