import 'dart:io';
import 'package:dio/dio.dart';
import '../../core/constants/api_endpoints.dart';
import '../models/category.dart';
import '../models/product.dart';

/// Custom API Exception for standardized error handling across the app.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final bool isNetworkError;

  ApiException({
    required this.message,
    this.statusCode,
    this.isNetworkError = false,
  });

  @override
  String toString() => message;
}

/// Paginated result wrapper for product listings.
class PaginatedProductsResult {
  final List<Product> products;
  final int total;
  final int skip;
  final int limit;

  const PaginatedProductsResult({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });

  bool get hasMore => (skip + products.length) < total;
}

/// Product API Service communicating with public HTTPS DummyJSON endpoints.
/// Uses Dio with configurable timeouts and robust error parsing.
class ProductApiService {
  final Dio _dio;

  ProductApiService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: ApiEndpoints.baseUrl,
                connectTimeout: ApiEndpoints.connectTimeout,
                receiveTimeout: ApiEndpoints.receiveTimeout,
                sendTimeout: ApiEndpoints.sendTimeout,
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ),
            );

  /// Fetches paginated products list.
  Future<PaginatedProductsResult> getProducts({
    int limit = ApiEndpoints.defaultPageSize,
    int skip = 0,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.products,
        queryParameters: {'limit': limit, 'skip': skip},
      );
      return _parsePaginatedResult(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException(message: 'Unexpected error loading products: $e');
    }
  }

  /// Searches products by text query with pagination.
  Future<PaginatedProductsResult> searchProducts(
    String query, {
    int limit = ApiEndpoints.defaultPageSize,
    int skip = 0,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.search,
        queryParameters: {'q': query, 'limit': limit, 'skip': skip},
      );
      return _parsePaginatedResult(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException(message: 'Unexpected error searching products: $e');
    }
  }

  /// Fetches all product categories.
  Future<List<ProductCategory>> getCategories() async {
    try {
      final response = await _dio.get(ApiEndpoints.categories);
      final data = response.data;
      if (data is List) {
        return data.map((item) => ProductCategory.fromDynamic(item)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException(message: 'Failed to load categories: $e');
    }
  }

  /// Fetches paginated products for a specific category slug.
  Future<PaginatedProductsResult> getProductsByCategory(
    String categorySlug, {
    int limit = ApiEndpoints.defaultPageSize,
    int skip = 0,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.category(categorySlug),
        queryParameters: {'limit': limit, 'skip': skip},
      );
      return _parsePaginatedResult(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException(message: 'Failed to load category products: $e');
    }
  }

  /// Fetches individual product by ID.
  Future<Product> getProductById(int id) async {
    try {
      final response = await _dio.get(ApiEndpoints.productDetail(id));
      return Product.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException(message: 'Failed to load product #$id: $e');
    }
  }

  PaginatedProductsResult _parsePaginatedResult(dynamic data) {
    if (data is! Map<String, dynamic>) {
      throw ApiException(message: 'Malformed response structure');
    }
    final rawList = data['products'] as List<dynamic>? ?? [];
    final products = rawList
        .map((p) => Product.fromJson(p as Map<String, dynamic>))
        .toList();
    final total = data['total'] as int? ?? products.length;
    final skip = data['skip'] as int? ?? 0;
    final limit = data['limit'] as int? ?? products.length;

    return PaginatedProductsResult(
      products: products,
      total: total,
      skip: skip,
      limit: limit,
    );
  }

  ApiException _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Connection timed out. Please check your internet connection.',
          isNetworkError: true,
        );
      case DioExceptionType.connectionError:
        return ApiException(
          message: 'Unable to reach NOVA servers. You may be offline.',
          isNetworkError: true,
        );
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode;
        return ApiException(
          message: 'Server error ($code). Please try again shortly.',
          statusCode: code,
        );
      case DioExceptionType.cancel:
        return ApiException(message: 'Request was cancelled.');
      default:
        if (e.error is SocketException) {
          return ApiException(
            message: 'No internet connection available.',
            isNetworkError: true,
          );
        }
        return ApiException(message: 'An unexpected network error occurred.');
    }
  }
}
