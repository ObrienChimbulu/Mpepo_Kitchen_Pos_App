import 'dart:convert'; // Add this import
import 'cart_model.dart';
import 'product_model.dart';

class Order {
  final String id;
  final List<CartItem> items;
  final DateTime createdAt;
  final double subtotal;
  final double taxAmount;
  final double discountAmount;
  final double total;
  final String status;
  final String? taxAuthorityRef;

  Order({
    required this.id,
    required this.items,
    required this.createdAt,
    required this.subtotal,
    required this.taxAmount,
    required this.discountAmount,
    required this.total,
    this.status = 'completed',
    this.taxAuthorityRef,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    print('Parsing order JSON: $json'); // Debug line

    // Parse items - handle both string and list formats
    List<CartItem> items = [];
    if (json['items'] != null) {
      if (json['items'] is List) {
        items = (json['items'] as List).map((item) {
          return CartItem(
            product: Product.fromJson(item['product']),
            quantity: item['quantity'] ?? 1,
          );
        }).toList();
      } else if (json['items'] is String) {
        // Handle case where items might be stored as JSON string
        try {
          final itemsList = jsonDecode(json['items']) as List;
          items = itemsList.map((item) {
            return CartItem(
              product: Product.fromJson(item['product']),
              quantity: item['quantity'] ?? 1,
            );
          }).toList();
        } catch (e) {
          print('Error parsing items string: $e');
        }
      }
    }

    // Parse dates safely
    DateTime createdAt;
    try {
      createdAt = DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String());
    } catch (e) {
      createdAt = DateTime.now();
    }

    // Parse numbers safely
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is int) return value.toDouble();
      if (value is double) return value;
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return Order(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      items: items,
      createdAt: createdAt,
      subtotal: parseDouble(json['subtotal']),
      taxAmount: parseDouble(json['tax_amount']),
      discountAmount: parseDouble(json['discount_amount']),
      total: parseDouble(json['total']),
      status: json['status']?.toString() ?? 'completed',
      taxAuthorityRef: json['tax_authority_ref']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'tax_amount': taxAmount,
      'discount_amount': discountAmount,
      'total': total,
    };
  }

  factory Order.fromCart(Cart cart, {double taxRate = 0.16, double discount = 0.0}) {
    final subtotal = cart.subtotal;
    final taxAmount = subtotal * taxRate;
    final discountAmount = subtotal * discount;
    final total = subtotal + taxAmount - discountAmount;

    return Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      items: List.from(cart.items),
      createdAt: DateTime.now(),
      subtotal: subtotal,
      taxAmount: taxAmount,
      discountAmount: discountAmount,
      total: total,
    );
  }
}