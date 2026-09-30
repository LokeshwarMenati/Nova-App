import 'package:flutter_test/flutter_test.dart';
import 'package:nova/core/constants/app_constants.dart';
import 'package:nova/data/models/cart_item.dart';
import 'package:nova/data/models/product.dart';

void main() {
  group('Shopping Cart Calculations & Business Rules', () {
    final sampleProduct1 = Product(
      id: 1,
      title: 'Silk Minimalist Shirt',
      price: 45.0,
      stock: 20,
    );

    final sampleProduct2 = Product(
      id: 2,
      title: 'Leather Urban Backpack',
      price: 80.0,
      stock: 15,
    );

    test('Calculates item subtotal accurately based on quantity', () {
      final item1 = CartItem(product: sampleProduct1, quantity: 2);
      expect(item1.itemTotal, 90.0);

      final item2 = CartItem(product: sampleProduct2, quantity: 1);
      expect(item2.itemTotal, 80.0);
    });

    test('Free shipping threshold applies when subtotal >= $50', () {
      final itemBelowThreshold = CartItem(product: sampleProduct1, quantity: 1); // $45
      final subtotalBelow = itemBelowThreshold.itemTotal;
      final shippingBelow = subtotalBelow >= AppConstants.freeShippingThreshold
          ? 0.0
          : AppConstants.standardShippingFee;

      expect(subtotalBelow < AppConstants.freeShippingThreshold, isTrue);
      expect(shippingBelow, 4.99);

      final itemAboveThreshold = CartItem(product: sampleProduct2, quantity: 1); // $80
      final subtotalAbove = itemAboveThreshold.itemTotal;
      final shippingAbove = subtotalAbove >= AppConstants.freeShippingThreshold
          ? 0.0
          : AppConstants.standardShippingFee;

      expect(subtotalAbove >= AppConstants.freeShippingThreshold, isTrue);
      expect(shippingAbove, 0.0);
    });

    test('Promo NOVA10 deducts 10% discount and computes tax correctly', () {
      const subtotal = 100.0;
      const promoDiscount = subtotal * AppConstants.promoDiscountRate; // $10.0
      const netSubtotal = subtotal - promoDiscount; // $90.0
      const tax = netSubtotal * AppConstants.taxRate; // 8% of $90 = $7.20
      const shipping = 0.0; // subtotal >= 50
      const total = netSubtotal + tax + shipping; // $97.20

      expect(promoDiscount, 10.0);
      expect(tax, 7.20);
      expect(total, 97.20);
    });
  });
}
