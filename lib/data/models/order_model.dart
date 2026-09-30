import 'cart_item.dart';

/// Single item within a placed customer order.
class OrderProductItem {
  final int productId;
  final String title;
  final String imageUrl;
  final double price;
  final int quantity;
  final String brand;

  const OrderProductItem({
    required this.productId,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.quantity,
    this.brand = 'NOVA Select',
  });

  double get itemTotal => price * quantity;

  factory OrderProductItem.fromCartItem(CartItem cartItem) {
    return OrderProductItem(
      productId: cartItem.product.id,
      title: cartItem.product.title,
      imageUrl: cartItem.product.primaryImage,
      price: cartItem.product.price,
      quantity: cartItem.quantity,
      brand: cartItem.product.displayBrand,
    );
  }

  factory OrderProductItem.fromJson(Map<String, dynamic> json) {
    return OrderProductItem(
      productId: (json['productId'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? 'Product',
      imageUrl: json['imageUrl'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      brand: json['brand'] as String? ?? 'NOVA Select',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'title': title,
      'imageUrl': imageUrl,
      'price': price,
      'quantity': quantity,
      'brand': brand,
    };
  }
}

/// Comprehensive customer order model with items, status, dates, and financial breakdown.
class OrderModel {
  final String id;
  final DateTime date;
  final String status; // 'DELIVERED', 'DISPATCHED', 'PROCESSING'
  final List<OrderProductItem> items;
  final double subtotal;
  final double discount;
  final double shippingFee;
  final double tax;
  final double total;
  final String deliveryAddress;
  final String paymentMethod;
  final String trackingNumber;
  final String estimatedDelivery;

  const OrderModel({
    required this.id,
    required this.date,
    required this.status,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.shippingFee,
    required this.tax,
    required this.total,
    required this.deliveryAddress,
    required this.paymentMethod,
    required this.trackingNumber,
    required this.estimatedDelivery,
  });

  bool get isDelivered => status.toUpperCase() == 'DELIVERED';
  bool get isDispatched => status.toUpperCase() == 'DISPATCHED';

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return OrderModel(
      id: json['id'] as String? ?? '#NOVA-00000',
      date: json['date'] != null ? DateTime.tryParse(json['date'].toString()) ?? DateTime.now() : DateTime.now(),
      status: json['status'] as String? ?? 'PROCESSING',
      items: rawItems.map((e) => OrderProductItem.fromJson(e as Map<String, dynamic>)).toList(),
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      shippingFee: (json['shippingFee'] as num?)?.toDouble() ?? 0.0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      deliveryAddress: json['deliveryAddress'] as String? ?? 'Kochi, Kerala, India',
      paymentMethod: json['paymentMethod'] as String? ?? 'UPI / Card Payment',
      trackingNumber: json['trackingNumber'] as String? ?? 'TRK-NOVA-84920',
      estimatedDelivery: json['estimatedDelivery'] as String? ?? 'Standard Delivery (2-3 Days)',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'status': status,
      'items': items.map((e) => e.toJson()).toList(),
      'subtotal': subtotal,
      'discount': discount,
      'shippingFee': shippingFee,
      'tax': tax,
      'total': total,
      'deliveryAddress': deliveryAddress,
      'paymentMethod': paymentMethod,
      'trackingNumber': trackingNumber,
      'estimatedDelivery': estimatedDelivery,
    };
  }
}
