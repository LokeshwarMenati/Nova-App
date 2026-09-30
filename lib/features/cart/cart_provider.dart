import 'package:flutter/foundation.dart';
import '../../core/constants/app_constants.dart';
import '../../data/local/local_storage_service.dart';
import '../../data/models/cart_item.dart';
import '../../data/models/product.dart';

/// Shopping Cart state management handling additions, quantity updates, promo codes, and pricing.
class CartProvider extends ChangeNotifier {
  final LocalStorageService _localStorage;

  List<CartItem> _items = [];
  String? _appliedPromoCode;
  double _promoDiscount = 0.0;

  List<CartItem> get items => List.unmodifiable(_items);
  String? get appliedPromoCode => _appliedPromoCode;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  bool get isEmpty => _items.isEmpty;
  bool get hasItems => _items.isNotEmpty;

  CartProvider(this._localStorage) {
    _loadCart();
  }

  void _loadCart() {
    _items = _localStorage.getCartItems();
    notifyListeners();
  }

  /// Calculates gross subtotal of all items.
  double get subtotal {
    return _items.fold(0.0, (sum, item) => sum + item.itemTotal);
  }

  /// Calculated promo discount amount.
  double get promoDiscountAmount => _promoDiscount;

  /// Free delivery if subtotal exceeds $50.
  double get shippingFee {
    if (subtotal == 0 || subtotal >= AppConstants.freeShippingThreshold) {
      return 0.0;
    }
    return AppConstants.standardShippingFee;
  }

  /// Estimated sales tax.
  double get estimatedTax {
    return (subtotal - _promoDiscount) * AppConstants.taxRate;
  }

  /// Final checkout total.
  double get finalTotal {
    final net = (subtotal - _promoDiscount) + shippingFee + estimatedTax;
    return net < 0 ? 0.0 : net;
  }

  /// Adds a product to cart or increments quantity if already present.
  void addToCart(
    Product product, {
    int quantity = 1,
    String? selectedColor,
    String? selectedSize,
  }) {
    final existingIndex = _items.indexWhere(
      (item) =>
          item.product.id == product.id &&
          item.selectedColor == selectedColor &&
          item.selectedSize == selectedSize,
    );

    if (existingIndex >= 0) {
      final existing = _items[existingIndex];
      _items[existingIndex] = existing.copyWith(
        quantity: existing.quantity + quantity,
      );
    } else {
      _items.add(
        CartItem(
          product: product,
          quantity: quantity,
          selectedColor: selectedColor,
          selectedSize: selectedSize,
        ),
      );
    }

    _recalculatePromo();
    _saveCart();
    notifyListeners();
  }

  /// Updates quantity for a specific product index.
  void updateQuantity(int index, int newQuantity) {
    if (index < 0 || index >= _items.length) return;
    if (newQuantity <= 0) {
      removeFromCart(index);
      return;
    }
    _items[index] = _items[index].copyWith(quantity: newQuantity);
    _recalculatePromo();
    _saveCart();
    notifyListeners();
  }

  /// Removes an item at a specific index with undo support.
  CartItem removeFromCart(int index) {
    if (index < 0 || index >= _items.length) {
      throw RangeError('Invalid cart item index');
    }
    final removed = _items.removeAt(index);
    _recalculatePromo();
    _saveCart();
    notifyListeners();
    return removed;
  }

  /// Inserts back an item (used for undo swipe-to-delete).
  void restoreItem(int index, CartItem item) {
    final insertIndex = index.clamp(0, _items.length);
    _items.insert(insertIndex, item);
    _recalculatePromo();
    _saveCart();
    notifyListeners();
  }

  /// Applies promo code (e.g. NOVA10 -> 10% off).
  bool applyPromoCode(String code) {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode == AppConstants.promoCode) {
      _appliedPromoCode = cleanCode;
      _recalculatePromo();
      notifyListeners();
      return true;
    }
    return false;
  }

  void removePromoCode() {
    _appliedPromoCode = null;
    _promoDiscount = 0.0;
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _appliedPromoCode = null;
    _promoDiscount = 0.0;
    _saveCart();
    notifyListeners();
  }

  void _recalculatePromo() {
    if (_appliedPromoCode == AppConstants.promoCode) {
      _promoDiscount = subtotal * AppConstants.promoDiscountRate;
    } else {
      _promoDiscount = 0.0;
    }
  }

  Future<void> _saveCart() async {
    await _localStorage.saveCartItems(_items);
  }
}
