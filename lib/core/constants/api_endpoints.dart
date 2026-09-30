/// Centralized API endpoint constants for NOVA.
/// Points to public HTTPS DummyJSON endpoints without hardcoding local IPs.
abstract class ApiEndpoints {
  static const String baseUrl = 'https://dummyjson.com';

  static const String products = '/products';
  static const String search = '/products/search';
  static const String categories = '/products/categories';

  static String category(String slug) => '/products/category/$slug';
  static String productDetail(int id) => '/products/$id';

  // Pagination defaults
  static const int defaultPageSize = 12;

  // Network timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
  static const Duration sendTimeout = Duration(seconds: 10);
}
