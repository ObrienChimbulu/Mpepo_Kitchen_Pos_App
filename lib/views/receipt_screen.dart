import 'package:flutter/material.dart';
import 'package:mpepo_kitchen_pos_app/utils/constants/currency.dart';
import '../models/receipt_model.dart';
import '../utils/constants/colors.dart';

class ReceiptScreen extends StatelessWidget {
  final Receipt receipt;

  const ReceiptScreen({Key? key, required this.receipt}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Receipt', style: TextStyle(color: Colors.white)),
        backgroundColor: TColors.primary,
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: Colors.white),
            onPressed: () {
              _shareReceipt(context);
            },
          ),
          IconButton(
            icon: Icon(Icons.print, color: Colors.white),
            onPressed: () {
              _printReceipt(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildReceiptHeader(),
            SizedBox(height: 20),
            _buildOrderItems(),
            SizedBox(height: 20),
            _buildPaymentSummary(),
            SizedBox(height: 30),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptHeader() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'MPEPO KITCHEN',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: TColors.primary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Order Receipt',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Text(
              'Receipt #: ${receipt.receiptNumber}',
              style: TextStyle(fontSize: 14),
            ),
            Text(
              'Date: ${_formatDate(receipt.printTime)}',
              style: TextStyle(fontSize: 14),
            ),
            Text(
              'Time: ${_formatTime(receipt.printTime)}',
              style: TextStyle(fontSize: 14),
            ),

            // Add offline indicator if order is local (starts with 'local_')
            if (receipt.order.id.startsWith('local_'))
              Container(
                margin: EdgeInsets.only(top: 8),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.wifi_off, size: 14, color: Colors.orange[800]),
                    SizedBox(width: 4),
                    Text(
                      'OFFLINE - Pending Sync',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

            if (receipt.taxAuthorityRef != null) ...[
              SizedBox(height: 8),
              Text(
                'Tax Reference: ${receipt.taxAuthorityRef}',
                style: TextStyle(
                  fontSize: 12,
                  color: TColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItems() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Items',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            ...receipt.order.items
                .map(
                  (item) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            '${item.product.name} x${item.quantity}',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            '${TCurrency.ZambiaCurrency} ${item.subtotal.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
            Divider(height: 20),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text('Subtotal:', style: TextStyle(fontSize: 14)),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '${TCurrency.ZambiaCurrency} ${receipt.order.subtotal.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSummary() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Payment Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            _buildSummaryRow('Subtotal:', receipt.order.subtotal),
            _buildSummaryRow('Tax (12%):', receipt.order.taxAmount),
            if (receipt.order.discountAmount > 0)
              _buildSummaryRow('Discount:', -receipt.order.discountAmount),
            Divider(height: 20),
            _buildSummaryRow('TOTAL:', receipt.order.total, isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isTotal ? 16 : 14,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            '${TCurrency.ZambiaCurrency} ${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? TColors.primary : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: TColors.primary,
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () {
              _showReceiptText(context);
            },
            child: Text(
              'VIEW RECEIPT TEXT',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
        SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: TColors.primary!),
            ),
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: Text(
              'NEW ORDER',
              style: TextStyle(fontSize: 16, color: TColors.primary),
            ),
          ),
        ),
        SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'BACK TO CART',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ),
        ),
      ],
    );
  }

  void _showReceiptText(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Receipt'),
        content: SingleChildScrollView(
          child: SelectableText(
            receipt.generateReceiptText(),
            style: TextStyle(fontFamily: 'Courier', fontSize: 12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CLOSE'),
          ),
        ],
      ),
    );
  }

  void _shareReceipt(BuildContext context) {
    // Simulate sharing functionality
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Receipt shared successfully!')));
  }

  void _printReceipt(BuildContext context) {
    // Simulate printing functionality
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Receipt sent to printer!')));
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
