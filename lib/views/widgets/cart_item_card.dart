import 'package:flutter/material.dart';
import 'package:mpepo_kitchen_pos_app/utils/constants/currency.dart';
import '../../controllers/cart_controller.dart';
import '../../models/cart_model.dart';
import '../../utils/constants/colors.dart';

class CartItemCard extends StatelessWidget {
  final CartItem item;
  final CartController cartController;

  const CartItemCard({
    Key? key,
    required this.item,
    required this.cartController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            // Product Avatar
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: TColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  item.product.name[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: TColors.primary,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${TCurrency.ZambiaCurrency}${item.product.price.toStringAsFixed(2)} each',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Total: ${TCurrency.ZambiaCurrency}${(item.product.price * item.quantity).toStringAsFixed(2)}',
                    style: TextStyle(
                      color: TColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Quantity Controls
            Column(
              children: [
                // Quantity Selector
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove, size: 18),
                        padding: EdgeInsets.all(4),
                        constraints: BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        onPressed: () {
                          if (item.quantity > 1) {
                            cartController.updateQuantity(
                              item.product.id,
                              item.quantity - 1,
                            );
                          } else {
                            cartController.removeFromCart(item.product.id);
                          }
                        },
                      ),
                      Container(
                        width: 30,
                        child: Center(
                          child: Text(
                            item.quantity.toString(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add, size: 18),
                        padding: EdgeInsets.all(4),
                        constraints: BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        onPressed: () {
                          cartController.updateQuantity(
                            item.product.id,
                            item.quantity + 1,
                          );
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8),

                // Delete Button
                IconButton(
                  icon: Icon(Icons.delete_outline, size: 20, color: Colors.red),
                  padding: EdgeInsets.all(4),
                  constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: () {
                    cartController.removeFromCart(item.product.id);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
