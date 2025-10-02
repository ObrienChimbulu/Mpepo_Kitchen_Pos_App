import 'package:flutter/material.dart';
import '../services/sync_service.dart';

class SyncProvider with ChangeNotifier {
  final SyncService _syncService = SyncService();
  bool _isSyncing = false;
  int _syncProgress = 0;
  int _pendingOrdersCount = 0;

  bool get isSyncing => _isSyncing;
  int get syncProgress => _syncProgress;
  int get pendingOrdersCount => _pendingOrdersCount;

  Future<void> initialize() async {
    // Start auto-sync when app starts
    _syncService.initializeAutoSync();

    // Listen to sync progress
    _syncService.syncProgress.listen((progress) {
      _syncProgress = progress;
      notifyListeners();
    });

    // Listen to sync status
    _syncService.syncStatus.listen((syncing) {
      _isSyncing = syncing;
      notifyListeners();
    });

    // Cache products for offline use
    await _syncService.cacheProductsForOffline();

    // Load initial pending orders count
    await _updatePendingCount();
  }

  Future<SyncResult> syncNow() async {
    final result = await _syncService.syncPendingOrders();
    await _updatePendingCount();
    return result;
  }

  Future<void> _updatePendingCount() async {
    final status = await _syncService.getSyncStatus();
    _pendingOrdersCount = status['pending_orders_count'] ?? 0;
    notifyListeners();
  }

  Future<Map<String, dynamic>> getSyncStatus() async {
    return await _syncService.getSyncStatus();
  }

  void dispose() {
    _syncService.dispose();
  }
}