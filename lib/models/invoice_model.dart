import 'cart_model.dart';
import 'order_model.dart';

class TaxInvoice {
  final String invoiceNumber;
  final DateTime issueDate;
  final String sellerName;
  final String sellerTin; // Tax Identification Number
  final String buyerName;
  final String buyerTin;
  final List<InvoiceItem> items;
  final double subtotal;
  final double taxAmount;
  final double total;
  final String currency;
  final String? qrCodeData;

  TaxInvoice({
    required this.invoiceNumber,
    required this.issueDate,
    required this.sellerName,
    required this.sellerTin,
    required this.buyerName,
    required this.buyerTin,
    required this.items,
    required this.subtotal,
    required this.taxAmount,
    required this.total,
    this.currency = 'KES',
    this.qrCodeData,
  });

  // Convert to JSON for API submission
  Map<String, dynamic> toJson() {
    return {
      'invoice_number': invoiceNumber,
      'issue_date': issueDate.toIso8601String(),
      'seller_info': {
        'name': sellerName,
        'tin': sellerTin,
        'address': 'Mpepo Kitchen, Nairobi, Kenya'
      },
      'buyer_info': {
        'name': buyerName,
        'tin': buyerTin,
        'address': 'Retail Customer'
      },
      'items': items.map((item) => item.toJson()).toList(),
      'summary': {
        'subtotal': subtotal,
        'tax_amount': taxAmount,
        'total': total,
        'currency': currency,
      },
      'tax_breakdown': {
        'vat_rate': 0.16,
        'vat_amount': taxAmount,
      },
      'qr_code': qrCodeData,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  // Create from Order
  factory TaxInvoice.fromOrder(Order order, {String buyerName = 'Retail Customer', String buyerTin = '000000000'}) {
    return TaxInvoice(
      invoiceNumber: 'INV-${order.id}',
      issueDate: order.createdAt,
      sellerName: 'Mpepo Kitchen',
      sellerTin: 'P051234567L',
      buyerName: buyerName,
      buyerTin: buyerTin,
      items: order.items.map((item) => InvoiceItem.fromCartItem(item)).toList(),
      subtotal: order.subtotal,
      taxAmount: order.taxAmount,
      total: order.total,
    );
  }
}

class InvoiceItem {
  final String description;
  final int quantity;
  final double unitPrice;
  final double total;
  final double taxAmount;
  final String taxCode;

  InvoiceItem({
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.total,
    required this.taxAmount,
    this.taxCode = 'A',
  });

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_amount': total,
      'tax_amount': taxAmount,
      'tax_code': taxCode,
    };
  }

  factory InvoiceItem.fromCartItem(CartItem cartItem) {
    return InvoiceItem(
      description: cartItem.product.name,
      quantity: cartItem.quantity,
      unitPrice: cartItem.product.price,
      total: cartItem.subtotal,
      taxAmount: cartItem.subtotal * 0.16, // 16% VAT
    );
  }
}

class TaxSubmissionResult {
  final bool success;
  final String? invoiceNumber;
  final String? authorityReference;
  final String? errorMessage;
  final DateTime timestamp;

  TaxSubmissionResult({
    required this.success,
    this.invoiceNumber,
    this.authorityReference,
    this.errorMessage,
    required this.timestamp,
  });

  factory TaxSubmissionResult.fromJson(Map<String, dynamic> json) {
    return TaxSubmissionResult(
      success: json['success'] ?? false,
      invoiceNumber: json['invoice_number'],
      authorityReference: json['authority_reference'],
      errorMessage: json['error_message'],
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }
}