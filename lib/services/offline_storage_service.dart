import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/order_model.dart';
import '../models/product_model.dart';

class OfflineStorageService {
  static const String _pendingOrdersKey = 'pending_orders';
  static const String _cachedProductsKey = 'cached_products';
  static const String _lastSyncKey = 'last_sync';
  static const String _syncAttemptsKey = 'sync_attempts';

  // Save pending order when offline
  static Future<void> savePendingOrder(Order order) async {
    final prefs = await SharedPreferences.getInstance();
    final pendingOrders = await getPendingOrders();

    // Add sync metadata
    final orderWithMetadata = {
      ...order.toJson(),
      '_local_id': 'local_${DateTime.now().millisecondsSinceEpoch}',
      '_created_at': DateTime.now().toIso8601String(),
      '_synced': false,
      '_sync_attempts': 0,
    };

    pendingOrders.add(orderWithMetadata);

    await prefs.setStringList(
      _pendingOrdersKey,
      pendingOrders.map((order) => json.encode(order)).toList(),
    );

    print('📱 Order saved offline: ${order.id}');
  }

  // Get all pending orders
  static Future<List<Map<String, dynamic>>> getPendingOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final ordersJson = prefs.getStringList(_pendingOrdersKey) ?? [];

    return ordersJson.map((jsonString) {
      return Map<String, dynamic>.from(json.decode(jsonString));
    }).toList();
  }

  // Remove order after successful sync
  static Future<void> removePendingOrder(String localId) async {
    final prefs = await SharedPreferences.getInstance();
    final pendingOrders = await getPendingOrders();

    final updatedOrders = pendingOrders.where((order) => order['_local_id'] != localId).toList();

    await prefs.setStringList(
      _pendingOrdersKey,
      updatedOrders.map((order) => json.encode(order)).toList(),
    );

    print('✅ Removed synced order: $localId');
  }

  // Update sync attempts
  static Future<void> updateSyncAttempts(String localId, int attempts) async {
    final prefs = await SharedPreferences.getInstance();
    final pendingOrders = await getPendingOrders();

    final updatedOrders = pendingOrders.map((order) {
      if (order['_local_id'] == localId) {
        return {
          ...order,
          '_sync_attempts': attempts,
        };
      }
      return order;
    }).toList();

    await prefs.setStringList(
      _pendingOrdersKey,
      updatedOrders.map((order) => json.encode(order)).toList(),
    );
  }

  // Cache products for offline browsing
  static Future<void> cacheProducts(List<Product> products) async {
    final prefs = await SharedPreferences.getInstance();
    final productsJson = products.map((product) => json.encode(product.toJson())).toList();

    await prefs.setStringList(_cachedProductsKey, productsJson);
    await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());

    print('📱 Cached ${products.length} products for offline use');
  }

  // Get cached products
  static Future<List<Product>> getCachedProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final productsJson = prefs.getStringList(_cachedProductsKey) ?? [];

    return productsJson.map((jsonString) {
      return Product.fromJson(Map<String, dynamic>.from(json.decode(jsonString)));
    }).toList();
  }

  // Check if we have cached data
  static Future<bool> hasCachedProducts() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_cachedProductsKey)?.isNotEmpty ?? false;
  }

  // Get last sync time
  static Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSync = prefs.getString(_lastSyncKey);
    return lastSync != null ? DateTime.parse(lastSync) : null;
  }

  // Clear all offline data (for testing)
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingOrdersKey);
    await prefs.remove(_cachedProductsKey);
    await prefs.remove(_lastSyncKey);
    print('🧹 Cleared all offline data');
  }

  // Get sync statistics
  static Future<Map<String, dynamic>> getSyncStats() async {
    final pendingOrders = await getPendingOrders();
    final lastSync = await getLastSyncTime();

    return {
      'pending_orders_count': pendingOrders.length,
      'last_sync': lastSync?.toIso8601String(),
      'pending_orders': pendingOrders.map((order) => order['_local_id']).toList(),
    };
  }
}