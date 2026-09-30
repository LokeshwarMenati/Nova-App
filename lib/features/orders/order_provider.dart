import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../data/local/local_storage_service.dart';
import '../../data/models/cart_item.dart';
import '../../data/models/order_model.dart';

/// State management for Customer Orders, tracking, and order history persistence.
class OrderProvider extends ChangeNotifier {
  final LocalStorageService _localStorage;
  List<OrderModel> _orders = [];

  List<OrderModel> get orders => List.unmodifiable(_orders);
  int get orderCount => _orders.length;
  bool get hasOrders => _orders.isNotEmpty;

  OrderProvider(this._localStorage) {
    _loadOrders();
  }

  void _loadOrders() {
    _orders = _localStorage.getOrders();
    notifyListeners();
  }

  /// Places a new order from current cart checkout items.
  Future<OrderModel> createOrderFromCart({
    required List<CartItem> cartItems,
    required double subtotal,
    required double discount,
    required double shippingFee,
    required double tax,
    required double total,
    String? deliveryAddress,
    String? paymentMethod,
  }) async {
    final randomId = 10000 + Random().nextInt(89999);
    final orderId = '#NOVA-$randomId';
    final trkId = 'TRK-IN-$randomId${Random().nextInt(99)}';

    final orderItems = cartItems.map((ci) => OrderProductItem.fromCartItem(ci)).toList();

    final newOrder = OrderModel(
      id: orderId,
      date: DateTime.now(),
      status: 'PROCESSING',
      items: orderItems,
      subtotal: subtotal,
      discount: discount,
      shippingFee: shippingFee,
      tax: tax,
      total: total,
      deliveryAddress: deliveryAddress ?? 'Flat 4B, Palm Grove Heights, Kochi, Kerala - 682001',
      paymentMethod: paymentMethod ?? 'UPI / Instant Pay',
      trackingNumber: trkId,
      estimatedDelivery: 'Arriving in 2-3 Business Days',
    );

    _orders.insert(0, newOrder);
    await _localStorage.saveOrders(_orders);
    notifyListeners();
    return newOrder;
  }

  /// Retrieves an order by its ID.
  OrderModel? getOrderById(String orderId) {
    try {
      return _orders.firstWhere((o) => o.id.toLowerCase() == orderId.toLowerCase());
    } catch (_) {
      return null;
    }
  }
}
