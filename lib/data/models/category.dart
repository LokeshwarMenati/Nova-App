import 'package:flutter/material.dart';

/// Category model supporting both DummyJSON string and object formats,
/// with icons and styling tokens for visual cards.
class ProductCategory {
  final String slug;
  final String name;
  final String? url;
  final IconData icon;

  const ProductCategory({
    required this.slug,
    required this.name,
    this.url,
    this.icon = Icons.category_outlined,
  });

  factory ProductCategory.fromDynamic(dynamic json) {
    if (json is String) {
      return ProductCategory(
        slug: json,
        name: _beautifyName(json),
        icon: _getCategoryIcon(json),
      );
    } else if (json is Map<String, dynamic>) {
      final slug = json['slug'] as String? ?? '';
      final name = json['name'] as String? ?? _beautifyName(slug);
      return ProductCategory(
        slug: slug,
        name: name,
        url: json['url'] as String?,
        icon: _getCategoryIcon(slug),
      );
    }
    return const ProductCategory(slug: 'all', name: 'All Products');
  }

  static String _beautifyName(String slug) {
    if (slug.isEmpty) return 'All';
    return slug
        .split('-')
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() + w.substring(1) : '')
        .join(' ');
  }

  static IconData _getCategoryIcon(String slug) {
    final lower = slug.toLowerCase();
    if (lower.contains('beauty') || lower.contains('skin')) return Icons.face_retouching_natural;
    if (lower.contains('fragrance')) return Icons.spa_outlined;
    if (lower.contains('furniture')) return Icons.chair_outlined;
    if (lower.contains('grocer')) return Icons.local_grocery_store_outlined;
    if (lower.contains('home')) return Icons.home_outlined;
    if (lower.contains('kitchen')) return Icons.kitchen_outlined;
    if (lower.contains('laptop') || lower.contains('tablet')) return Icons.laptop_mac_outlined;
    if (lower.contains('phone')) return Icons.smartphone_outlined;
    if (lower.contains('shirt') || lower.contains('dress') || lower.contains('top')) {
      return Icons.checkroom_outlined;
    }
    if (lower.contains('shoe')) return Icons.snowshoeing_outlined;
    if (lower.contains('watch')) return Icons.watch_outlined;
    if (lower.contains('jewel')) return Icons.diamond_outlined;
    if (lower.contains('bag')) return Icons.shopping_bag_outlined;
    if (lower.contains('sunglass')) return Icons.wb_sunny_outlined;
    if (lower.contains('sport')) return Icons.sports_tennis_outlined;
    if (lower.contains('vehicle')) return Icons.directions_car_outlined;
    return Icons.grid_view_rounded;
  }
}
