import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class OfflineService {
  static const String _pendingOrdersKey = 'pending_orders';

  static Future<void> savePendingOrder(Map<String, dynamic> orderData) async {
    final prefs = await SharedPreferences.getInstance();
    final pendingOrders = await getPendingOrders();

    pendingOrders.add(orderData);

    await prefs.setStringList(
      _pendingOrdersKey,
      pendingOrders.map((order) => json.encode(order)).toList(),
    );
  }

  static Future<List<Map<String, dynamic>>> getPendingOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final ordersJson = prefs.getStringList(_pendingOrdersKey) ?? [];

    return ordersJson.map((jsonString) {
      return Map<String, dynamic>.from(json.decode(jsonString));
    }).toList();
  }

  static Future<void> removePendingOrder(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final pendingOrders = await getPendingOrders();

    if (index >= 0 && index < pendingOrders.length) {
      pendingOrders.removeAt(index);

      await prefs.setStringList(
        _pendingOrdersKey,
        pendingOrders.map((order) => json.encode(order)).toList(),
      );
    }
  }

  static Future<void> clearPendingOrders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingOrdersKey);
  }

  // Additional offline storage methods
  static Future<void> saveProducts(List<Map<String, dynamic>> products) async {
    final prefs = await SharedPreferences.getInstance();
    final productsJson = products.map((product) => json.encode(product)).toList();
    await prefs.setStringList('cached_products', productsJson);
  }

  static Future<List<Map<String, dynamic>>> getCachedProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final productsJson = prefs.getStringList('cached_products') ?? [];
    return productsJson.map((jsonString) {
      return Map<String, dynamic>.from(json.decode(jsonString));
    }).toList();
  }

  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cached_products');
    await prefs.remove(_pendingOrdersKey);
  }
}