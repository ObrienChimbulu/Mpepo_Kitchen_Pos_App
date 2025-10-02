import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';

class ProductController with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await _apiService.fetchProducts();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _products = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // FIXED: Changed from addProduct to createProduct
  Future<void> addProduct(Product product) async {
    try {
      final newProduct = await _apiService.createProduct(product);
      _products.add(newProduct);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to add product: $e');
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      final updatedProduct = await _apiService.updateProduct(product);
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = updatedProduct;
        notifyListeners();
      }
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _apiService.deleteProduct(productId);
      _products.removeWhere((product) => product.id == productId);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}