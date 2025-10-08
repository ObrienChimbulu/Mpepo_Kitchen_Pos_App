import 'package:flutter/material.dart';
import 'package:mpepo_kitchen_pos_app/utils/constants/colors.dart';
import 'package:mpepo_kitchen_pos_app/utils/constants/currency.dart';
import '../controllers/cart_controller.dart';
import '../models/order_model.dart';
import '../models/receipt_model.dart';
import './widgets/cart_item_card.dart';
import './receipt_screen.dart';

class CartScreen extends StatefulWidget {
  final CartController cartController;

  const CartScreen({Key? key, required this.cartController}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Add listener but handle disposal properly
    widget.cartController.addListener(_onCartChanged);
  }

  void _onCartChanged() {
    // Only call setState if the widget is still mounted
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    // Remove listener when screen is disposed
    widget.cartController.removeListener(_onCartChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shopping Cart', style: TextStyle(color: TColors.white)),
        backgroundColor: TColors.primary,
      ),
      body: Column(
        children: [
          Expanded(
            child: widget.cartController.cart.items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Your cart is empty',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: ListView.builder(
                      itemCount: widget.cartController.cart.items.length,
                      itemBuilder: (context, index) {
                        final item = widget.cartController.cart.items[index];
                        return CartItemCard(
                          item: item,
                          cartController: widget.cartController,
                        );
                      },
                    ),
                  ),
          ),
          if (widget.cartController.cart.items.isNotEmpty)
            _buildTotalSection(context),
        ],
      ),
    );
  }

  Widget _buildTotalSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal:', style: TextStyle(fontSize: 16)),
              Text(
                '${TCurrency.ZambiaCurrency} ${widget.cartController.subtotal.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tax (12%):', style: TextStyle(fontSize: 16)),
              Text(
                '${TCurrency.ZambiaCurrency} ${widget.cartController.taxAmount.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          SizedBox(height: 8),
          Divider(),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '${TCurrency.ZambiaCurrency} ${widget.cartController.total.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: TColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.primary,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _isLoading ? null : () => _completeOrder(context),
              child: _isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.purple,
                        ),
                      ),
                    )
                  : Text(
                      'COMPLETE ORDER',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _completeOrder(BuildContext context) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Complete order through controller (this should save to database)
      final order = await widget.cartController.completeOrder();

      // Create receipt
      final receipt = Receipt(
        order: order,
        receiptNumber: 'RC${DateTime.now().millisecondsSinceEpoch}',
        printTime: DateTime.now(),
      );

      // Navigate to receipt screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReceiptScreen(receipt: receipt),
          ),
        );
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to complete order: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
