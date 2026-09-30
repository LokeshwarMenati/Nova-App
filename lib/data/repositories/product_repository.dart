import '../local/local_storage_service.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../services/product_api_service.dart';

/// Repository abstracting data sources (API & local offline fallback).
/// Ensures the UI layer NEVER communicates directly with the network layer.
class ProductRepository {
  final ProductApiService _apiService;
  final LocalStorageService _localStorage;

  // In-memory cache to reduce redundant network transfers
  final Map<int, Product> _productMemoryCache = {};
  List<ProductCategory> _cachedCategories = [];
  bool _isOfflineFallbackActive = false;

  bool get isOfflineFallbackActive => _isOfflineFallbackActive;

  ProductRepository({
    required ProductApiService apiService,
    required LocalStorageService localStorage,
  })  : _apiService = apiService,
        _localStorage = localStorage;

  /// Fetches paginated products with offline fallback.
  Future<PaginatedProductsResult> getProducts({
    int skip = 0,
    int limit = 12,
  }) async {
    try {
      final result = await _apiService.getProducts(limit: limit, skip: skip);
      _isOfflineFallbackActive = false;
      for (final p in result.products) {
        _productMemoryCache[p.id] = p;
      }
      return result;
    } catch (_) {
      // Fallback to bundled mock data
      return _loadFallbackSlice(skip: skip, limit: limit);
    }
  }

  /// Searches products with pagination and fallback filtering.
  Future<PaginatedProductsResult> searchProducts(
    String query, {
    int skip = 0,
    int limit = 12,
  }) async {
    try {
      final result = await _apiService.searchProducts(query, limit: limit, skip: skip);
      for (final p in result.products) {
        _productMemoryCache[p.id] = p;
      }
      return result;
    } catch (_) {
      final allFallback = await _localStorage.loadFallbackProducts();
      final q = query.toLowerCase().trim();
      final filtered = allFallback.where((p) {
        return p.title.toLowerCase().contains(q) ||
            p.description.toLowerCase().contains(q) ||
            p.category.toLowerCase().contains(q) ||
            p.brand.toLowerCase().contains(q);
      }).toList();

      final slice = filtered.skip(skip).take(limit).toList();
      return PaginatedProductsResult(
        products: slice,
        total: filtered.length,
        skip: skip,
        limit: limit,
      );
    }
  }

  /// Fetches categories.
  Future<List<ProductCategory>> getCategories() async {
    if (_cachedCategories.isNotEmpty) return _cachedCategories;
    try {
      final categories = await _apiService.getCategories();
      _cachedCategories = categories;
      return categories;
    } catch (_) {
      // Generate categories from local fallback
      final allFallback = await _localStorage.loadFallbackProducts();
      final slugs = allFallback.map((p) => p.category).toSet();
      _cachedCategories = slugs.map((s) => ProductCategory.fromDynamic(s)).toList();
      return _cachedCategories;
    }
  }

  /// Fetches products belonging to a specific category.
  Future<PaginatedProductsResult> getProductsByCategory(
    String categorySlug, {
    int skip = 0,
    int limit = 12,
  }) async {
    try {
      final result = await _apiService.getProductsByCategory(
        categorySlug,
        limit: limit,
        skip: skip,
      );
      for (final p in result.products) {
        _productMemoryCache[p.id] = p;
      }
      return result;
    } catch (_) {
      final allFallback = await _localStorage.loadFallbackProducts();
      final filtered = allFallback
          .where((p) => p.category.toLowerCase() == categorySlug.toLowerCase())
          .toList();
      final slice = filtered.skip(skip).take(limit).toList();
      return PaginatedProductsResult(
        products: slice,
        total: filtered.length,
        skip: skip,
        limit: limit,
      );
    }
  }

  /// Fetches a single product by ID (checks memory cache first).
  Future<Product> getProductById(int id) async {
    if (_productMemoryCache.containsKey(id)) {
      return _productMemoryCache[id]!;
    }
    try {
      final product = await _apiService.getProductById(id);
      _productMemoryCache[id] = product;
      return product;
    } catch (_) {
      final allFallback = await _localStorage.loadFallbackProducts();
      final match = allFallback.firstWhere(
        (p) => p.id == id,
        orElse: () => allFallback.isNotEmpty
            ? allFallback.first
            : Product(id: id, title: 'Item #$id', description: '', category: 'General', price: 99.0),
      );
      _productMemoryCache[id] = match;
      return match;
    }
  }

  /// Generates personalized "For You" products based on recently viewed & wishlist data.
  Future<List<Product>> getPersonalizedForYou(
    List<int> recentlyViewedIds,
    Set<int> wishlistIds,
  ) async {
    final seedIds = {...recentlyViewedIds, ...wishlistIds};
    final relevantProducts = <Product>[];

    // Gather seed products
    for (final id in seedIds.take(5)) {
      if (_productMemoryCache.containsKey(id)) {
        relevantProducts.add(_productMemoryCache[id]!);
      }
    }

    final targetCategories = relevantProducts.map((p) => p.category.toLowerCase()).toSet();

    // Pull high rated items from those categories
    final pool = _productMemoryCache.values.toList();
    if (pool.isEmpty) {
      final fallback = await _localStorage.loadFallbackProducts();
      pool.addAll(fallback);
    }

    final personalized = pool.where((p) {
      if (seedIds.contains(p.id)) return false;
      if (targetCategories.contains(p.category.toLowerCase())) return true;
      return p.rating >= 4.5;
    }).toList();

    personalized.sort((a, b) => b.rating.compareTo(a.rating));
    return personalized.take(8).toList();
  }

  Future<PaginatedProductsResult> _loadFallbackSlice({required int skip, required int limit}) async {
    _isOfflineFallbackActive = true;
    final all = await _localStorage.loadFallbackProducts();
    final slice = all.skip(skip).take(limit).toList();
    for (final p in slice) {
      _productMemoryCache[p.id] = p;
    }
    return PaginatedProductsResult(
      products: slice,
      total: all.length,
      skip: skip,
      limit: limit,
    );
  }
}
