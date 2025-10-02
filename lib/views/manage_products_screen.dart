import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/product_controller.dart';
import '../models/product_model.dart';
import './add_product_screen.dart';

class ManageProductsScreen extends StatefulWidget {
  @override
  _ManageProductsScreenState createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends State<ManageProductsScreen> {
  @override
  void initState() {
    super.initState();
    // Load products when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productController = Provider.of<ProductController>(context, listen: false);
      productController.loadProducts();
    });
  }

  void _editProduct(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddProductScreen(product: product),
      ),
    ).then((refresh) {
      if (refresh == true) {
        // Refresh the product list
        final productController = Provider.of<ProductController>(context, listen: false);
        productController.loadProducts();
      }
    });
  }

  Future<void> _deleteProduct(Product product) async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final productController = Provider.of<ProductController>(context, listen: false);
        await productController.deleteProduct(product.id);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Product deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting product: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productController = Provider.of<ProductController>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Products'),
        backgroundColor: Colors.green[700],
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => productController.loadProducts(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddProductScreen()),
          ).then((refresh) {
            if (refresh == true) {
              productController.loadProducts();
            }
          });
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.green[700],
      ),
      body: productController.isLoading
          ? Center(child: CircularProgressIndicator())
          : productController.error != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text('Error: ${productController.error}'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => productController.loadProducts(),
              child: Text('Retry'),
            ),
          ],
        ),
      )
          : productController.products.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fastfood, size: 80, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'No Products Found',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            Text(
              'Tap the + button to add your first product',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: EdgeInsets.all(8),
        itemCount: productController.products.length,
        itemBuilder: (context, index) {
          final product = productController.products[index];
          return _buildProductItem(product);
        },
      ),
    );
  }

  Widget _buildProductItem(Product product) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.green[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: product.imageUrl != null
              ? ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              product.imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.fastfood, color: Colors.green[700]);
              },
            ),
          )
              : Icon(Icons.fastfood, color: Colors.green[700]),
        ),
        title: Text(
          product.name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product.category),
            Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: TextStyle(
                color: Colors.green[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            if (product.description != null && product.description!.isNotEmpty)
              Text(
                product.description!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _editProduct(product),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteProduct(product),
            ),
          ],
        ),
      ),
    );
  }
}