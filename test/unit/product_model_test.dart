import 'package:flutter_test/flutter_test.dart';
import 'package:nova/data/models/product.dart';

void main() {
  group('Product Model Serialization & Computed Properties', () {
    final mockProductJson = {
      'id': 101,
      'title': 'NOVA Smart Chronograph',
      'description': 'High precision lifestyle smart watch with sapphire display.',
      'category': 'accessories',
      'price': 199.99,
      'discountPercentage': 15.0,
      'rating': 4.85,
      'stock': 8,
      'tags': ['watch', 'smart', 'lifestyle'],
      'brand': 'NOVA Luxe',
      'sku': 'NOVA-W101',
      'weight': 65,
      'dimensions': {'width': 4.2, 'height': 4.2, 'depth': 1.1},
      'warrantyInformation': '2 Year International Warranty',
      'shippingInformation': 'Ships in 1-2 business days',
      'availabilityStatus': 'Low Stock',
      'reviews': [
        {
          'rating': 5,
          'comment': 'Stunning design and long battery life.',
          'date': '2025-01-15T08:30:00.000Z',
          'reviewerName': 'Alex Morgan',
          'reviewerEmail': 'alex@example.com'
        }
      ],
      'returnPolicy': '30-day money-back guarantee',
      'minimumOrderQuantity': 1,
      'meta': {
        'createdAt': '2024-11-01T12:00:00.000Z',
        'updatedAt': '2025-01-10T12:00:00.000Z',
        'barcode': '9876543210987',
        'qrCode': 'https://dummyjson.com/public/qr.png'
      },
      'images': [
        'https://dummyjson.com/image/1.png',
        'https://dummyjson.com/image/2.png'
      ],
      'thumbnail': 'https://dummyjson.com/image/1.png'
    };

    test('Parses complete DummyJSON payload accurately', () {
      final product = Product.fromJson(mockProductJson);

      expect(product.id, 101);
      expect(product.title, 'NOVA Smart Chronograph');
      expect(product.price, 199.99);
      expect(product.discountPercentage, 15.0);
      expect(product.rating, 4.85);
      expect(product.stock, 8);
      expect(product.displayBrand, 'NOVA Luxe');
      expect(product.images.length, 2);
      expect(product.reviews.length, 1);
      expect(product.reviews.first.reviewerName, 'Alex Morgan');
    });

    test('Computed getters calculate correct original price and stock flags', () {
      final product = Product.fromJson(mockProductJson);

      expect(product.isDiscounted, isTrue);
      // Original price = 199.99 / (1 - 0.15) = 235.28
      expect(product.originalPrice, closeTo(235.28, 0.05));
      expect(product.isLowStock, isTrue); // stock <= 10
      expect(product.isOutOfStock, isFalse);
    });

    test('Gracefully handles missing optional brand and images', () {
      final minimalJson = {
        'id': 202,
        'title': 'Minimal Product',
        'price': 25.0,
      };

      final product = Product.fromJson(minimalJson);
      expect(product.id, 202);
      expect(product.displayBrand, 'NOVA');
      expect(product.stock, 0);
      expect(product.rating, 0.0);
      expect(product.primaryImage, isEmpty);
    });
  });
}
