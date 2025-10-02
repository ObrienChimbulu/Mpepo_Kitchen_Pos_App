import 'package:flutter/material.dart';
import '../models/cart_model.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../services/api_service.dart';
import '../services/offline_storage_service.dart';
import '../services/connectivity_service.dart';
import '../services/tax_service.dart';
import 'tax_calculator.dart';

class CartController with ChangeNotifier {
  Cart _cart = Cart();
  final TaxCalculator _taxCalculator = TaxCalculator();
  final ApiService _apiService = ApiService();
  final ConnectivityService _connectivityService = ConnectivityService();
  final TaxService _taxService = TaxService();

  double _discountPercentage = 0.0;
  bool _isSubmitting = false;
  bool _disposed = false;

  // Add offline-related properties
  bool _isOnline = true;
  List<Map<String, dynamic>> _pendingOrders = [];

  Cart get cart => _cart;
  double get discountPercentage => _discountPercentage;
  bool get isSubmitting => _isSubmitting;
  bool get isOnline => _isOnline;
  List<Map<String, dynamic>> get pendingOrders => _pendingOrders;
  int get pendingOrdersCount => _pendingOrders.length;

  double get subtotal => _cart.subtotal;
  double get taxAmount => _taxCalculator.calculateTax(_cart.subtotal);
  double get discountAmount => _cart.subtotal * (_discountPercentage / 100);
  double get total => subtotal + taxAmount - discountAmount;
  int get itemCount => _cart.totalItems;

  // Initialize connectivity monitoring
  void initialize() {
    _checkConnectivity();
    _connectivityService.onConnectivityChanged.listen((connected) {
      _isOnline = connected;
      notifyListeners();
      print(_isOnline ? '🌐 Online' : '📱 Offline');
    });

    _loadPendingOrders();
  }

  Future<void> _checkConnectivity() async {
    _isOnline = await _connectivityService.isConnected();
    notifyListeners();
  }

  Future<void> _loadPendingOrders() async {
    _pendingOrders = await OfflineStorageService.getPendingOrders();
    notifyListeners();
  }

  Future<Order> completeOrder() async {
    _isSubmitting = true;
    _safeNotifyListeners();

    try {
      final order = Order.fromCart(
        _cart,
        taxRate: 0.16,
        discount: _discountPercentage / 100,
      );

      if (_isOnline) {
        // Online: Submit directly to API (which will auto-submit to tax authority)
        print('🔄 Submitting order online...');
        final createdOrder = await _apiService.createOrder(order);

        // The backend now automatically submits to tax authority
        // We can check if tax submission was successful
        if (createdOrder.taxAuthorityRef != null) {
          print('✅ Order created with tax reference: ${createdOrder.taxAuthorityRef}');
        } else {
          print('⚠️ Order created but tax submission may have failed');
        }

        _clearCart();
        return createdOrder;
      } else {
        // Offline: Save locally (tax submission will happen during sync)
        print('📱 Saving order offline...');
        await OfflineStorageService.savePendingOrder(order);
        await _loadPendingOrders(); // Refresh pending orders list
        _clearCart();
        return order; // Return the local order
      }

    } catch (e) {
      // If online submission fails, fallback to offline
      if (_isOnline) {
        print('❌ Online submission failed, falling back to offline: $e');
        final order = Order.fromCart(
          _cart,
          taxRate: 0.16,
          discount: _discountPercentage / 100,
        );
        await OfflineStorageService.savePendingOrder(order);
        await _loadPendingOrders();
        _clearCart();
        return order;
      } else {
        rethrow;
      }
    } finally {
      _isSubmitting = false;
      _safeNotifyListeners();
    }
  }

  void addToCart(Product product, [int quantity = 1]) {
    _cart.addItem(product, quantity);
    _safeNotifyListeners();
  }

  void removeFromCart(String productId) {
    _cart.removeItem(productId);
    _safeNotifyListeners();
  }

  void updateQuantity(String productId, int newQuantity) {
    _cart.updateQuantity(productId, newQuantity);
    _safeNotifyListeners();
  }

  void setDiscount(double percentage) {
    if (percentage >= 0 && percentage <= 100) {
      _discountPercentage = percentage;
      _safeNotifyListeners();
    }
  }

  void clearCart() {
    _cart.clear();
    _discountPercentage = 0.0;
    _safeNotifyListeners();
  }

  bool isProductInCart(String productId) {
    return _cart.items.any((item) => item.product.id == productId);
  }

  int getProductQuantity(String productId) {
    try {
      final item = _cart.items.firstWhere((item) => item.product.id == productId);
      return item.quantity;
    } catch (e) {
      return 0;
    }
  }

  Map<String, double> getPaymentBreakdown() {
    return {
      'subtotal': subtotal,
      'taxAmount': taxAmount,
      'discountAmount': discountAmount,
      'total': total,
    };
  }

  void _clearCart() {
    _cart.clear();
    _discountPercentage = 0.0;
  }

  // Safe notification method that checks if disposed
  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}