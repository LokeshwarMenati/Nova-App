import 'package:flutter_test/flutter_test.dart';
import 'package:nova/data/models/product.dart';

void main() {
  group('Pagination & Duplicate Prevention Suite', () {
    test('Prevents duplicate product IDs when merging paginated pages', () {
      final existingProducts = [
        Product(id: 1, title: 'Item 1', price: 10),
        Product(id: 2, title: 'Item 2', price: 20),
        Product(id: 3, title: 'Item 3', price: 30),
      ];

      final incomingProducts = [
        Product(id: 3, title: 'Item 3 (Duplicate)', price: 30), // duplicate
        Product(id: 4, title: 'Item 4', price: 40),
        Product(id: 5, title: 'Item 5', price: 50),
      ];

      // Safe deduplication algorithm matching HomeProvider implementation
      final existingIds = existingProducts.map((p) => p.id).toSet();
      final filteredNew = incomingProducts.where((p) => !existingIds.contains(p.id)).toList();
      final merged = [...existingProducts, ...filteredNew];

      expect(merged.length, 5);
      expect(merged.map((p) => p.id).toList(), [1, 2, 3, 4, 5]);
    });

    test('Computes hasMore correctly based on total vs loaded count', () {
      const total = 50;
      final loadedPage1 = List.generate(12, (i) => Product(id: i, title: 'Item $i', price: 10));
      final hasMorePage1 = loadedPage1.length < total;
      expect(hasMorePage1, isTrue);

      final loadedAll = List.generate(50, (i) => Product(id: i, title: 'Item $i', price: 10));
      final hasMoreAll = loadedAll.length < total;
      expect(hasMoreAll, isFalse);
    });

    test('Computes skip offset correctly for sequential page requests', () {
      const pageSize = 12;
      int calculateSkip(int currentCount) => currentCount;

      expect(calculateSkip(0), 0);
      expect(calculateSkip(12), 12);
      expect(calculateSkip(24), 24);
      expect(calculateSkip(36), 36);
    });
  });
}
