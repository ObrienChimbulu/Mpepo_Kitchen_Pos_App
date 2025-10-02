class TaxCalculator {
  static const double taxRate = 0.16; // 16% VAT

  double calculateTax(double amount) {
    return amount * taxRate;
  }

  double calculateTotalWithTax(double amount) {
    return amount + calculateTax(amount);
  }

  double applyDiscount(double amount, double discountPercentage) {
    if (discountPercentage < 0 || discountPercentage > 100) {
      throw ArgumentError('Discount percentage must be between 0 and 100');
    }
    return amount * (1 - discountPercentage / 100);
  }

  Map<String, double> calculateBreakdown(double subtotal, {double discountPercentage = 0}) {
    final discountedAmount = applyDiscount(subtotal, discountPercentage);
    final tax = calculateTax(discountedAmount);
    final total = discountedAmount + tax;

    return {
      'subtotal': subtotal,
      'discountAmount': subtotal - discountedAmount,
      'taxAmount': tax,
      'total': total,
    };
  }
}