/// Application-wide constants for NOVA.
abstract class AppConstants {
  static const String appName = 'NOVA';
  static const String appTagline = 'Discover what fits your life.';
  static const String developerName = 'Lokeshwar Menati';
  static const String copyright = '© 2024 All Rights Reserved by Lokeshwar Menati';

  // Promotional promo code
  static const String promoCode = 'NOVA10';
  static const double promoDiscountRate = 0.10; // 10% discount

  // Pricing & Currency
  static const String currencySymbol = '₹';
  static const double usdToInrRate = 83.0; // 1 USD = 83 INR
  static const double freeShippingThreshold = 50.0; // Base units, formats to ₹4,150
  static const double standardShippingFee = 199.0 / usdToInrRate; // Formats to ₹199
  static const double taxRate = 0.08; // 8% estimated GST/tax

  // Responsive Breakpoints
  static const double breakpointMobile = 600.0;
  static const double breakpointTablet = 900.0;
  static const double breakpointDesktop = 1200.0;

  // Search
  static const int searchDebounceMs = 400;

  // Local Storage Keys
  static const String keyUserSession = 'nova_user_session';
  static const String keyThemeMode = 'nova_theme_mode';
  static const String keyWishlist = 'nova_wishlist_ids';
  static const String keyCart = 'nova_cart_items';
  static const String keyRecentSearches = 'nova_recent_searches';
  static const String keyRecentlyViewed = 'nova_recently_viewed_ids';
  static const String keyOrders = 'nova_orders_history';

  // Fallback asset path
  static const String mockProductsAssetPath = 'assets/mock/products.json';
}
