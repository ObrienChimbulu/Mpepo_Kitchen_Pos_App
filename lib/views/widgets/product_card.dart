import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/cart_controller.dart';
import '../../models/product_model.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final CartController? cartController;

  const ProductCard({
    Key? key,
    required this.product,
    this.cartController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // If cartController is not provided, get it from Provider
    final cartCtrl = cartController ?? Provider.of<CartController>(context, listen: false);

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          cartCtrl.addToCart(product);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${product.name} added to cart'),
              duration: Duration(seconds: 1),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                color: Colors.grey[200],
                child: Icon(Icons.fastfood, size: 50, color: Colors.grey[600]),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      product.category,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    Spacer(),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}