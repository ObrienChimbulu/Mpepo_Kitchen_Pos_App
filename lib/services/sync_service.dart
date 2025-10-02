import 'dart:async';
import '../services/api_service.dart';
import '../services/offline_storage_service.dart';
import '../services/connectivity_service.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';

// Define SyncResult here so sync_service can use it
class SyncResult {
  final bool isSyncing;
  final int syncedCount;
  final int? failedCount;
  final int? totalCount;
  final String? error;

  SyncResult({
    required this.isSyncing,
    this.syncedCount = 0,
    this.failedCount,
    this.totalCount,
    this.error,
  });

  bool get hasError => error != null;
  bool get isComplete => !isSyncing;
}

class SyncService {
  final ApiService _apiService = ApiService();
  final ConnectivityService _connectivityService = ConnectivityService();

  bool _isSyncing = false;
  final StreamController<int> _syncProgressController = StreamController<int>.broadcast();
  final StreamController<bool> _syncStatusController = StreamController<bool>.broadcast();

  Stream<int> get syncProgress => _syncProgressController.stream;
  Stream<bool> get syncStatus => _syncStatusController.stream;
  bool get isSyncing => _isSyncing;

  // Auto-sync when coming online
  void initializeAutoSync() {
    _connectivityService.onConnectivityChanged.listen((isConnected) {
      if (isConnected && !_isSyncing) {
        print('🌐 Connection restored - starting auto-sync');
        syncPendingOrders();
      }
    });
  }

  // Manual sync trigger
  Future<SyncResult> syncPendingOrders() async {
    if (_isSyncing) {
      print('🔄 Sync already in progress');
      return SyncResult(isSyncing: true, syncedCount: 0);
    }

    _isSyncing = true;
    _syncStatusController.add(true);

    try {
      final isConnected = await _connectivityService.isConnected();
      if (!isConnected) {
        print('❌ No internet connection for sync');
        return SyncResult(
            isSyncing: false,
            syncedCount: 0,
            error: 'No internet connection'
        );
      }

      final pendingOrders = await OfflineStorageService.getPendingOrders();
      if (pendingOrders.isEmpty) {
        print('✅ No pending orders to sync');
        return SyncResult(isSyncing: false, syncedCount: 0);
      }

      print('🔄 Syncing ${pendingOrders.length} pending orders...');

      int syncedCount = 0;
      int failedCount = 0;

      for (int i = 0; i < pendingOrders.length; i++) {
        final orderData = pendingOrders[i];
        final localId = orderData['_local_id'];
        final syncAttempts = orderData['_sync_attempts'] ?? 0;

        // Update progress
        final progress = ((i + 1) / pendingOrders.length * 100).round();
        _syncProgressController.add(progress);

        try {
          // Remove metadata before sending to API
          final cleanOrderData = Map<String, dynamic>.from(orderData);
          cleanOrderData.removeWhere((key, value) => key.startsWith('_'));

          // Convert back to Order object
          final order = Order.fromJson(cleanOrderData);

          // Submit to API
          final createdOrder = await _apiService.createOrder(order);

          // Remove from pending orders on success
          await OfflineStorageService.removePendingOrder(localId);
          syncedCount++;

          print('✅ Synced order: $localId → ${createdOrder.id}');

        } catch (e) {
          failedCount++;

          // Update sync attempts
          await OfflineStorageService.updateSyncAttempts(localId, syncAttempts + 1);

          print('❌ Failed to sync order $localId: $e');

          // If too many failures, might want to alert user
          if (syncAttempts + 1 >= 3) {
            print('🚨 Order $localId has failed 3+ times, needs manual attention');
          }
        }

        // Small delay to avoid overwhelming the server
        await Future.delayed(Duration(milliseconds: 100));
      }

      print('✅ Sync completed: $syncedCount successful, $failedCount failed');

      return SyncResult(
        isSyncing: false,
        syncedCount: syncedCount,
        failedCount: failedCount,
        totalCount: pendingOrders.length,
      );

    } catch (e) {
      print('❌ Sync service error: $e');
      return SyncResult(
        isSyncing: false,
        syncedCount: 0,
        error: e.toString(),
      );
    } finally {
      _isSyncing = false;
      _syncStatusController.add(false);
      _syncProgressController.add(0);
    }
  }

  // Cache products for offline use
  Future<void> cacheProductsForOffline() async {
    try {
      final products = await _apiService.fetchProducts();
      await OfflineStorageService.cacheProducts(products);
      print('✅ Products cached for offline use');
    } catch (e) {
      print('❌ Failed to cache products: $e');
    }
  }

  // Get sync status
  Future<Map<String, dynamic>> getSyncStatus() async {
    final stats = await OfflineStorageService.getSyncStats();
    final isConnected = await _connectivityService.isConnected();

    return {
      ...stats,
      'is_online': isConnected,
      'is_syncing': _isSyncing,
    };
  }

  void dispose() {
    _syncProgressController.close();
    _syncStatusController.close();
  }
}