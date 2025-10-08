class TaxCalculator {
  static const double taxRate = 0.12; // 12% VAT

  /// Applies discount and returns the discounted amount
  double applyDiscount(double amount, double discountPercentage) {
    if (discountPercentage < 0 || discountPercentage > 100) {
      throw ArgumentError('Discount percentage must be between 0 and 100');
    }
    return amount * (1 - discountPercentage / 100);
  }

  /// Calculates the tax on a given amount
  double calculateTax(double amount) {
    return amount * taxRate;
  }

  /// Calculates the total including tax
  double calculateTotalWithTax(double amount) {
    return amount + calculateTax(amount);
  }

  /// Returns a breakdown of subtotal, discount, tax, and total
  Map<String, double> calculateBreakdown(
    double subtotal, {
    double discountPercentage = 0,
  }) {
    final discountedAmount = applyDiscount(subtotal, discountPercentage);
    final taxAmount = calculateTax(discountedAmount);
    final totalAmount = discountedAmount + taxAmount;

    return {
      'subtotal': subtotal,
      'discountAmount': subtotal - discountedAmount,
      'taxAmount': taxAmount,
      'total': totalAmount,
    };
  }
}
