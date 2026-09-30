import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../models/cart_item.dart';
import '../models/order_model.dart';
import '../models/product.dart';
import '../models/user_profile.dart';

/// Central local storage service using SharedPreferences & offline bundled assets.
class LocalStorageService {
  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  static Future<LocalStorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorageService(prefs);
  }

  // --- Auth Session ---
  Future<void> saveUserSession(UserProfile user) async {
    await _prefs.setString(AppConstants.keyUserSession, jsonEncode(user.toJson()));
  }

  UserProfile? getUserSession() {
    final jsonStr = _prefs.getString(AppConstants.keyUserSession);
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return UserProfile.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearUserSession() async {
    await _prefs.remove(AppConstants.keyUserSession);
  }

  // --- Theme Mode ---
  Future<void> saveThemeMode(String mode) async {
    await _prefs.setString(AppConstants.keyThemeMode, mode);
  }

  String getThemeMode() {
    return _prefs.getString(AppConstants.keyThemeMode) ?? 'system';
  }

  // --- Wishlist ---
  Set<int> getWishlistIds() {
    final list = _prefs.getStringList(AppConstants.keyWishlist) ?? [];
    return list.map((id) => int.tryParse(id) ?? 0).where((id) => id > 0).toSet();
  }

  Future<void> saveWishlistIds(Set<int> ids) async {
    await _prefs.setStringList(
      AppConstants.keyWishlist,
      ids.map((id) => id.toString()).toList(),
    );
  }

  // --- Cart ---
  List<CartItem> getCartItems() {
    final jsonStr = _prefs.getString(AppConstants.keyCart);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      return list.map((item) => CartItem.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveCartItems(List<CartItem> items) async {
    final jsonStr = jsonEncode(items.map((i) => i.toJson()).toList());
    await _prefs.setString(AppConstants.keyCart, jsonStr);
  }

  // --- Orders ---
  List<OrderModel> getOrders() {
    final jsonList = _prefs.getStringList(AppConstants.keyOrders);
    if (jsonList == null || jsonList.isEmpty) {
      return _generateDefaultMockOrders();
    }
    try {
      return jsonList
          .map((str) => OrderModel.fromJson(jsonDecode(str) as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return _generateDefaultMockOrders();
    }
  }

  Future<void> saveOrders(List<OrderModel> orders) async {
    final list = orders.map((o) => jsonEncode(o.toJson())).toList();
    await _prefs.setStringList(AppConstants.keyOrders, list);
  }

  List<OrderModel> _generateDefaultMockOrders() {
    return [
      OrderModel(
        id: '#NOVA-92841',
        date: DateTime.now().subtract(const Duration(days: 1)),
        status: 'DISPATCHED',
        items: const [
          OrderProductItem(
            productId: 1,
            title: 'NOVA Smart Chronograph',
            imageUrl: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400',
            price: 199.99,
            quantity: 1,
            brand: 'NOVA Chrono',
          ),
          OrderProductItem(
            productId: 2,
            title: 'Leather Minimalist Cardholder',
            imageUrl: 'https://images.unsplash.com/photo-1627123424574-724758594e93?w=400',
            price: 29.99,
            quantity: 1,
            brand: 'NOVA Atelier',
          ),
        ],
        subtotal: 229.98,
        discount: 22.99,
        shippingFee: 0.0,
        tax: 16.55,
        total: 223.54,
        deliveryAddress: 'Flat 4B, Palm Grove Heights, Kochi, Kerala - 682001',
        paymentMethod: 'UPI • Google Pay',
        trackingNumber: 'TRK-IN-9284109',
        estimatedDelivery: 'Arriving Tomorrow by 6:00 PM',
      ),
      OrderModel(
        id: '#NOVA-81042',
        date: DateTime.now().subtract(const Duration(days: 5)),
        status: 'DELIVERED',
        items: const [
          OrderProductItem(
            productId: 3,
            title: 'Silk Minimalist Shirt',
            imageUrl: 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=400',
            price: 45.00,
            quantity: 2,
            brand: 'NOVA Apparel',
          ),
          OrderProductItem(
            productId: 4,
            title: 'Essence Mascara Lash Princess',
            imageUrl: 'https://cdn.dummyjson.com/product-images/beauty/essence-mascara-lash-princess/thumbnail.webp',
            price: 9.99,
            quantity: 1,
            brand: 'Essence',
          ),
        ],
        subtotal: 99.99,
        discount: 10.00,
        shippingFee: 0.0,
        tax: 7.20,
        total: 97.19,
        deliveryAddress: 'Flat 4B, Palm Grove Heights, Kochi, Kerala - 682001',
        paymentMethod: 'Credit Card • Visa ending in 4022',
        trackingNumber: 'TRK-IN-8104288',
        estimatedDelivery: 'Delivered on 25 Sep 2026',
      ),
    ];
  }

  // --- Recent Searches ---
  List<String> getRecentSearches() {
    return _prefs.getStringList(AppConstants.keyRecentSearches) ??
        ['Sneakers', 'Perfume', 'Leather Bag', 'Smart Watch', 'Headphones'];
  }

  Future<void> addRecentSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    final current = getRecentSearches();
    current.removeWhere((item) => item.toLowerCase() == trimmed.toLowerCase());
    current.insert(0, trimmed);
    if (current.length > 10) current.removeLast();
    await _prefs.setStringList(AppConstants.keyRecentSearches, current);
  }

  Future<void> clearRecentSearches() async {
    await _prefs.remove(AppConstants.keyRecentSearches);
  }

  // --- Recently Viewed ---
  List<int> getRecentlyViewedIds() {
    final list = _prefs.getStringList(AppConstants.keyRecentlyViewed) ?? [];
    return list.map((id) => int.tryParse(id) ?? 0).where((id) => id > 0).toList();
  }

  Future<void> addRecentlyViewed(int productId) async {
    final current = getRecentlyViewedIds();
    current.remove(productId);
    current.insert(0, productId);
    if (current.length > 20) current.removeLast();
    await _prefs.setStringList(
      AppConstants.keyRecentlyViewed,
      current.map((id) => id.toString()).toList(),
    );
  }

  Future<void> clearRecentlyViewed() async {
    await _prefs.remove(AppConstants.keyRecentlyViewed);
  }

  // --- Offline Fallback Asset Loading ---
  Future<List<Product>> loadFallbackProducts() async {
    try {
      final jsonStr = await rootBundle.loadString(AppConstants.mockProductsAssetPath);
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      final list = data['products'] as List<dynamic>? ?? [];
      return list.map((p) => Product.fromJson(p as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }
}
