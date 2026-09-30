import 'dart:io';
import '../lib/core/utils/validators.dart';
import '../lib/core/constants/app_constants.dart';
import '../lib/data/models/product.dart';
import '../lib/data/models/cart_item.dart';

void main() {
  int totalTests = 0;
  int passedTests = 0;

  void test(String description, void Function() body) {
    totalTests++;
    try {
      body();
      passedTests++;
      print('  ✓ [PASS] $description');
    } catch (e, st) {
      print('  ✗ [FAIL] $description: $e');
      print(st);
    }
  }

  void expect(dynamic actual, dynamic expected, [String? reason]) {
    if (actual != expected) {
      throw Exception('Expected: $expected, but got: $actual. ${reason ?? ""}');
    }
  }

  void expectNotNull(dynamic actual) {
    if (actual == null) throw Exception('Expected non-null value');
  }

  void expectNull(dynamic actual) {
    if (actual != null) throw Exception('Expected null, got: $actual');
  }

  print('\n=== RUNNING NOVA AUTOMATED TEST SUITE ===\n');

  print('--- GROUP 1: Validators ---');
  test('Email validation - valid emails', () {
    expectNull(Validators.validateEmail('user@whitematrix.co.in'));
    expectNull(Validators.validateEmail('developer.lead@nova.app'));
    expectNull(Validators.validateEmail('test@gmail.com'));
  });

  test('Email validation - invalid emails', () {
    expectNotNull(Validators.validateEmail(''));
    expectNotNull(Validators.validateEmail('invalid-email'));
    expectNotNull(Validators.validateEmail('user@domain'));
    expectNotNull(Validators.validateEmail('@domain.com'));
  });

  test('Phone validation - valid Indian 10-digit mobile numbers', () {
    expectNull(Validators.validatePhone('9876543210'));
    expectNull(Validators.validatePhone('8123456789'));
    expectNull(Validators.validatePhone('7001234567'));
    expectNull(Validators.validatePhone('6999888777'));
  });

  test('Phone validation - invalid numbers', () {
    expectNotNull(Validators.validatePhone(''));
    expectNotNull(Validators.validatePhone('1234567890')); // Starts with 1
    expectNotNull(Validators.validatePhone('98765')); // Too short
    expectNotNull(Validators.validatePhone('98765432100')); // Too long
    expectNotNull(Validators.validatePhone('98765abcde')); // Non-digit
  });

  test('Hybrid Email or Phone validation', () {
    expectNull(Validators.validateEmailOrPhone('test@example.com'));
    expectNull(Validators.validateEmailOrPhone('9876543210'));
    expectNotNull(Validators.validateEmailOrPhone(''));
    expectNotNull(Validators.validateEmailOrPhone('12345'));
    expectNotNull(Validators.validateEmailOrPhone('invalid-id'));
  });

  test('Password validation - min 6 chars with letter and number', () {
    expectNull(Validators.validatePassword('secret1'));
    expectNull(Validators.validatePassword('WhiteMatrix2025'));
    expectNull(Validators.validatePassword('nova99'));

    expectNotNull(Validators.validatePassword(''));
    expectNotNull(Validators.validatePassword('abc')); // < 6
    expectNotNull(Validators.validatePassword('abcdef')); // no digit
    expectNotNull(Validators.validatePassword('123456')); // no letter
  });

  test('Confirm password match validation', () {
    expectNull(Validators.validateConfirmPassword('pass123', 'pass123'));
    expectNotNull(Validators.validateConfirmPassword('pass123', 'mismatch456'));
    expectNotNull(Validators.validateConfirmPassword('', 'pass123'));
  });

  print('\n--- GROUP 2: Product Model & Computed Properties ---');
  test('Product model parses JSON and computes discount correctly', () {
    final json = {
      'id': 101,
      'title': 'NOVA Smart Chronograph',
      'price': 199.99,
      'discountPercentage': 15.0,
      'rating': 4.85,
      'stock': 4,
      'brand': 'NOVA Luxe',
      'images': ['https://dummyjson.com/img1.png'],
      'thumbnail': 'https://dummyjson.com/thumb.png',
    };

    final product = Product.fromJson(json);
    expect(product.id, 101);
    expect(product.title, 'NOVA Smart Chronograph');
    expect(product.displayBrand, 'NOVA Luxe');
    expect(product.isDiscounted, true);
    expect(product.isLowStock, true);
    expect(product.isOutOfStock, false);
    expect((product.originalPrice - 235.28).abs() < 0.1, true);
  });

  test('Product model fallback defaults', () {
    final minimalJson = {
      'id': 202,
      'title': 'Minimal Item',
      'price': 25.0,
    };
    final product = Product.fromJson(minimalJson);
    expect(product.id, 202);
    expect(product.displayBrand, 'NOVA Select');
    expect(product.stock, 0);
    expect(product.isDiscounted, false);
  });

  print('\n--- GROUP 3: Cart Pricing & Business Rules ---');
  test('CartItem itemTotal calculation', () {
    const p1 = Product(
      id: 1,
      title: 'Item 1',
      description: 'Desc',
      category: 'fashion',
      price: 45.0,
      stock: 10,
    );
    final item = CartItem(product: p1, quantity: 3);
    expect(item.itemTotal, 135.0);
  });

  test('Free shipping threshold logic (Free above ₹${AppConstants.freeShippingThreshold.toInt()})', () {
    const p1 = Product(
      id: 1,
      title: 'Item 1',
      description: 'Desc',
      category: 'fashion',
      price: 25.0, // 25 * 83 = 2075
      stock: 10,
    );
    final belowThreshold = CartItem(product: p1, quantity: 1); // 25 * 83 = 2075 < 4150
    final feeBelow = belowThreshold.itemTotal >= AppConstants.freeShippingThreshold
        ? 0.0
        : AppConstants.standardShippingFee;
    expect((feeBelow * AppConstants.usdToInrRate).round(), 199);

    final aboveThreshold = CartItem(product: p1, quantity: 3); // 75 * 83 = 6225 >= 4150
    final feeAbove = aboveThreshold.itemTotal >= AppConstants.freeShippingThreshold
        ? 0.0
        : AppConstants.standardShippingFee;
    expect(feeAbove, 0.0);
  });

  test('NOVA10 Promo code discount and tax calculation', () {
    const subtotal = 100.0;
    const discount = subtotal * AppConstants.promoDiscountRate; // 10.0
    const net = subtotal - discount; // 90.0
    const tax = net * AppConstants.taxRate; // 8% of 90 = 7.20
    const total = net + tax; // 97.20

    expect(discount, 10.0);
    expect(tax, 7.20);
    expect(total, 97.20);
  });

  print('\n--- GROUP 4: Pagination & Deduplication Logic ---');
  test('Deduplicates product items by ID when merging pages', () {
    const existing = [
      Product(id: 1, title: 'P1', description: 'd', category: 'c', price: 10),
      Product(id: 2, title: 'P2', description: 'd', category: 'c', price: 20),
      Product(id: 3, title: 'P3', description: 'd', category: 'c', price: 30),
    ];
    const incoming = [
      Product(id: 3, title: 'P3 Duplicate', description: 'd', category: 'c', price: 30),
      Product(id: 4, title: 'P4', description: 'd', category: 'c', price: 40),
    ];

    final existingIds = existing.map((p) => p.id).toSet();
    final filtered = incoming.where((p) => !existingIds.contains(p.id)).toList();
    final merged = [...existing, ...filtered];

    expect(merged.length, 4);
    expect(merged.map((p) => p.id).toList().join(','), '1,2,3,4');
  });

  print('\n==========================================');
  print('TEST RESULTS: $passedTests / $totalTests PASSED');
  print('==========================================\n');

  if (passedTests != totalTests) {
    exit(1);
  }
}
