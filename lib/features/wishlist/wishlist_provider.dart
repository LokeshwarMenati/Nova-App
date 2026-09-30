import 'package:flutter/foundation.dart';
import '../../data/local/local_storage_service.dart';
import '../../data/models/product.dart';
import '../../data/repositories/product_repository.dart';
import '../cart/cart_provider.dart';

/// Wishlist state management with persistent IDs and product entity resolution.
class WishlistProvider extends ChangeNotifier {
  final LocalStorageService _localStorage;
  final ProductRepository _productRepository;

  Set<int> _wishlistIds = {};
  final List<Product> _wishlistProducts = [];
  bool _isLoading = false;

  Set<int> get wishlistIds => _wishlistIds;
  List<Product> get items => List.unmodifiable(_wishlistProducts);
  int get count => _wishlistIds.length;
  bool get isEmpty => _wishlistIds.isEmpty;
  bool get isLoading => _isLoading;

  WishlistProvider({
    required LocalStorageService localStorage,
    required ProductRepository productRepository,
  })  : _localStorage = localStorage,
        _productRepository = productRepository {
    _loadWishlist();
  }

  void _loadWishlist() {
    _wishlistIds = _localStorage.getWishlistIds();
    _resolveProducts();
  }

  Future<void> _resolveProducts() async {
    if (_wishlistIds.isEmpty) {
      _wishlistProducts.clear();
      notifyListeners();
      return;
    }
    _isLoading = true;
    notifyListeners();

    _wishlistProducts.clear();
    for (final id in _wishlistIds) {
      try {
        final product = await _productRepository.getProductById(id);
        _wishlistProducts.add(product);
      } catch (_) {
        // Continue loading available products
      }
    }
    _isLoading = false;
    notifyListeners();
  }

  bool isInWishlist(int productId) => _wishlistIds.contains(productId);

  /// Toggles wishlist state for a product. Returns new state (true if added, false if removed).
  Future<bool> toggleWishlist(Product product) async {
    final isPresent = _wishlistIds.contains(product.id);
    if (isPresent) {
      _wishlistIds.remove(product.id);
      _wishlistProducts.removeWhere((p) => p.id == product.id);
    } else {
      _wishlistIds.add(product.id);
      if (!_wishlistProducts.any((p) => p.id == product.id)) {
        _wishlistProducts.insert(0, product);
      }
    }
    await _localStorage.saveWishlistIds(_wishlistIds);
    notifyListeners();
    return !isPresent;
  }

  /// Removes an item directly from wishlist.
  Future<void> removeFromWishlist(int productId) async {
    if (_wishlistIds.contains(productId)) {
      _wishlistIds.remove(productId);
      _wishlistProducts.removeWhere((p) => p.id == productId);
      await _localStorage.saveWishlistIds(_wishlistIds);
      notifyListeners();
    }
  }

  /// Moves an item from wishlist to cart.
  Future<void> moveToCart(Product product, CartProvider cartProvider) async {
    cartProvider.addToCart(product);
    await removeFromWishlist(product.id);
  }
}
