import 'package:flutter/material.dart';
import '../../data/local/local_storage_service.dart';
import '../../data/models/product.dart';
import '../../data/repositories/product_repository.dart';

/// Profile & settings provider managing Dark Mode preferences and Recently Viewed products.
class ProfileProvider extends ChangeNotifier {
  final LocalStorageService _localStorage;
  final ProductRepository _productRepository;

  ThemeMode _themeMode = ThemeMode.system;
  final List<Product> _recentlyViewed = [];
  bool _isLoadingRecent = false;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  List<Product> get recentlyViewed => List.unmodifiable(_recentlyViewed);
  bool get isLoadingRecent => _isLoadingRecent;

  ProfileProvider({
    required LocalStorageService localStorage,
    required ProductRepository productRepository,
  })  : _localStorage = localStorage,
        _productRepository = productRepository {
    _loadTheme();
    loadRecentlyViewed();
  }

  void _loadTheme() {
    final modeStr = _localStorage.getThemeMode();
    if (modeStr == 'light') {
      _themeMode = ThemeMode.light;
    } else if (modeStr == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final modeStr = mode == ThemeMode.light
        ? 'light'
        : mode == ThemeMode.dark
            ? 'dark'
            : 'system';
    await _localStorage.saveThemeMode(modeStr);
    notifyListeners();
  }

  Future<void> toggleDarkMode(bool isDark) async {
    await setThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> toggleTheme() async {
    await toggleDarkMode(!isDarkMode);
  }

  Future<void> clearRecentlyViewed() async {
    _recentlyViewed.clear();
    await _localStorage.clearRecentlyViewed();
    notifyListeners();
  }

  Future<void> loadRecentlyViewed() async {
    final ids = _localStorage.getRecentlyViewedIds();
    if (ids.isEmpty) {
      _recentlyViewed.clear();
      notifyListeners();
      return;
    }
    _isLoadingRecent = true;
    notifyListeners();

    _recentlyViewed.clear();
    for (final id in ids.take(10)) {
      try {
        final product = await _productRepository.getProductById(id);
        _recentlyViewed.add(product);
      } catch (_) {}
    }
    _isLoadingRecent = false;
    notifyListeners();
  }

  Future<void> recordProductView(int productId) async {
    await _localStorage.addRecentlyViewed(productId);
    // Reload asynchronously without blocking
    loadRecentlyViewed();
  }
}
