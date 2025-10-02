import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/invoice_model.dart';
import '../models/order_model.dart';
import 'api_service.dart';

class TaxService {
  final ApiService _apiService = ApiService();
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 5);

  // Submit invoice to tax authority with retry logic
  Future<TaxSubmissionResult> submitInvoice(TaxInvoice invoice) async {
    int attempt = 0;

    while (attempt < _maxRetries) {
      try {
        print('🔄 Tax submission attempt ${attempt + 1}/$_maxRetries for invoice: ${invoice.invoiceNumber}');

        final response = await _submitToTaxAuthority(invoice);

        if (response.success) {
          print('✅ Tax submission successful: ${response.authorityReference}');
          return response;
        } else {
          print('❌ Tax submission failed: ${response.errorMessage}');

          // If it's not a retryable error, return immediately
          if (!_isRetryableError(response.errorMessage)) {
            return response;
          }
        }
      } catch (e) {
        print('❌ Tax submission error (attempt ${attempt + 1}): $e');

        // Network errors are retryable
        if (e is http.ClientException || e.toString().contains('Network')) {
          // Continue to retry
        } else {
          // Non-retryable error
          return TaxSubmissionResult(
            success: false,
            errorMessage: e.toString(),
            timestamp: DateTime.now(),
          );
        }
      }

      attempt++;
      if (attempt < _maxRetries) {
        print('⏳ Retrying in ${_retryDelay.inSeconds} seconds...');
        await Future.delayed(_retryDelay);
      }
    }

    return TaxSubmissionResult(
      success: false,
      errorMessage: 'Max retry attempts exceeded',
      timestamp: DateTime.now(),
    );
  }

  // Actual submission to tax authority
  Future<TaxSubmissionResult> _submitToTaxAuthority(TaxInvoice invoice) async {
    try {
      final response = await _apiService.submitToTaxAuthority(invoice.toJson());

      return TaxSubmissionResult.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Check if error is retryable
  bool _isRetryableError(String? errorMessage) {
    if (errorMessage == null) return false;

    // These errors are retryable (temporary issues)
    final retryableErrors = [
      'service temporarily unavailable',
      'timeout',
      'network error',
      'connection failed',
      'server busy',
    ];

    return retryableErrors.any((error) => errorMessage.toLowerCase().contains(error));
  }

  // Submit order directly (convenience method)
  Future<TaxSubmissionResult> submitOrder(Order order, {String buyerName = 'Retail Customer', String buyerTin = '000000000'}) async {
    final invoice = TaxInvoice.fromOrder(order, buyerName: buyerName, buyerTin: buyerTin);
    return await submitInvoice(invoice);
  }

  // Validate invoice before submission
  List<String> validateInvoice(TaxInvoice invoice) {
    final errors = <String>[];

    if (invoice.invoiceNumber.isEmpty) {
      errors.add('Invoice number is required');
    }

    if (invoice.sellerTin.isEmpty) {
      errors.add('Seller TIN is required');
    }

    if (invoice.items.isEmpty) {
      errors.add('Invoice must have at least one item');
    }

    if (invoice.total <= 0) {
      errors.add('Total amount must be greater than 0');
    }

    // Validate tax calculation
    final expectedTax = invoice.subtotal * 0.16;
    if ((invoice.taxAmount - expectedTax).abs() > 0.01) {
      errors.add('Tax amount calculation is incorrect');
    }

    return errors;
  }

  // Generate QR code data for invoice (mock implementation)
  String generateQRCodeData(TaxInvoice invoice) {
    final qrData = {
      'seller': invoice.sellerName,
      'tin': invoice.sellerTin,
      'invoice': invoice.invoiceNumber,
      'date': invoice.issueDate.toIso8601String(),
      'total': invoice.total,
      'tax': invoice.taxAmount,
    };

    return base64.encode(utf8.encode(json.encode(qrData)));
  }
}