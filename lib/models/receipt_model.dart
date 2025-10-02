import 'order_model.dart';
import 'product_model.dart';

class Receipt {
  final Order order;
  final String receiptNumber;
  final DateTime printTime;
  final String? taxAuthorityRef;

  Receipt({
    required this.order,
    required this.receiptNumber,
    required this.printTime,
    this.taxAuthorityRef,
  });

  String generateReceiptText() {
    final itemsText = order.items.map((item) {
      return '${item.product.name} x${item.quantity} \$${(item.subtotal).toStringAsFixed(2)}';
    }).join('\n');

    return '''
MPEPO KITCHEN RECEIPT
Receipt #: $receiptNumber
Date: ${printTime.day}/${printTime.month}/${printTime.year}
Time: ${printTime.hour.toString().padLeft(2, '0')}:${printTime.minute.toString().padLeft(2, '0')}
${'-' * 40}
$itemsText
${'-' * 40}
Subtotal: \$${order.subtotal.toStringAsFixed(2)}
Tax (16%): \$${order.taxAmount.toStringAsFixed(2)}
${order.discountAmount > 0 ? 'Discount: \$${order.discountAmount.toStringAsFixed(2)}' : ''}
TOTAL: \$${order.total.toStringAsFixed(2)}
${'-' * 40}
Thank you for dining with us!
${taxAuthorityRef != null ? 'Tax Ref: $taxAuthorityRef' : ''}
''';
  }
}