import 'product_model.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get subtotal => product.price * quantity;

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
    };
  }
}

class Cart {
  final List<CartItem> items;

  Cart({List<CartItem>? items}) : items = items ?? [];

  void addItem(Product product, [int quantity = 1]) {
    final existingIndex = items.indexWhere((item) => item.product.id == product.id);

    if (existingIndex != -1) {
      items[existingIndex].quantity += quantity;
    } else {
      items.add(CartItem(product: product, quantity: quantity));
    }
  }

  void removeItem(String productId) {
    items.removeWhere((item) => item.product.id == productId);
  }

  void updateQuantity(String productId, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(productId);
      return;
    }

    final existingIndex = items.indexWhere((item) => item.product.id == productId);
    if (existingIndex != -1) {
      items[existingIndex].quantity = newQuantity;
    }
  }

  void clear() {
    items.clear();
  }

  double get subtotal => items.fold(0, (sum, item) => sum + item.subtotal);

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  bool get isEmpty => items.isEmpty;
}