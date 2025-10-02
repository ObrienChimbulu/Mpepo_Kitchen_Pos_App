import 'package:flutter/material.dart';
import '../../controllers/cart_controller.dart';
import '../../models/cart_model.dart';

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
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green[100],
          child: Text(item.product.name[0]),
        ),
        title: Text(item.product.name),
        subtitle: Text('\$${item.product.price.toStringAsFixed(2)} each'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.remove, size: 20),
              onPressed: () {
                if (item.quantity > 1) {
                  cartController.updateQuantity(item.product.id, item.quantity - 1);
                } else {
                  cartController.removeFromCart(item.product.id);
                }
              },
            ),
            Text(item.quantity.toString(), style: TextStyle(fontSize: 16)),
            IconButton(
              icon: Icon(Icons.add, size: 20),
              onPressed: () {
                cartController.updateQuantity(item.product.id, item.quantity + 1);
              },
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                cartController.removeFromCart(item.product.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}