import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/cart_controller.dart';
import '../controllers/sync_provider.dart';
import '../models/receipt_model.dart';
import '../services/api_service.dart';
import '../models/order_model.dart';
import './receipt_screen.dart';

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final ApiService _apiService = ApiService();
  List<Order> _onlineOrders = [];
  List<Map<String, dynamic>> _pendingOrders = [];
  bool _isLoading = true;
  String? _error;
  int _selectedTab = 0; // 0: All, 1: Online, 2: Offline

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load online orders from API
      _onlineOrders = await _apiService.fetchOrders();

      // Load pending offline orders
      final cartController = Provider.of<CartController>(context, listen: false);
      _pendingOrders = cartController.pendingOrders;

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _refreshOrders() {
    _loadOrders();
  }

  void _viewOrderDetails(Order order) {
    final receipt = Receipt(
      order: order,
      receiptNumber: order.id.startsWith('local_')
          ? 'OFFLINE-${order.id}'
          : 'RC-${order.id}',
      printTime: order.createdAt,
      taxAuthorityRef: order.taxAuthorityRef,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReceiptScreen(receipt: receipt),
      ),
    );
  }

  void _viewPendingOrderDetails(Map<String, dynamic> orderData) {
    // Convert pending order data to Order object
    final order = Order.fromJson(orderData);

    final receipt = Receipt(
      order: order,
      receiptNumber: 'OFFLINE-${orderData['_local_id']}',
      printTime: DateTime.parse(orderData['_created_at']),
      taxAuthorityRef: null, // Offline orders don't have tax ref yet
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReceiptScreen(receipt: receipt),
      ),
    );
  }

  String _formatOrderDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildOrderItem(Order order) {
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
          child: Icon(
            Icons.receipt,
            color: Colors.green[700],
            size: 30,
          ),
        ),
        title: Text(
          'Order #${order.id.substring(0, 8)}...',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_formatOrderDate(order.createdAt)),
            Text(
              '${order.items.length} items • \$${order.total.toStringAsFixed(2)}',
              style: TextStyle(
                color: Colors.green[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            if (order.taxAuthorityRef != null)
              Text(
                'Tax Ref: ${order.taxAuthorityRef}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
          ],
        ),
        trailing: Icon(Icons.chevron_right),
        onTap: () => _viewOrderDetails(order),
      ),
    );
  }

  Widget _buildPendingOrderItem(Map<String, dynamic> orderData) {
    final order = Order.fromJson(orderData);
    final syncAttempts = orderData['_sync_attempts'] ?? 0;

    return Card(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.orange[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.wifi_off,
            color: Colors.orange[700],
            size: 30,
          ),
        ),
        title: Text(
          'Pending Order',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_formatOrderDate(order.createdAt)),
            Text(
              '${order.items.length} items • \$${order.total.toStringAsFixed(2)}',
              style: TextStyle(
                color: Colors.orange[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                Icon(Icons.sync, size: 12, color: Colors.orange),
                SizedBox(width: 4),
                Text(
                  'Sync attempts: $syncAttempts',
                  style: TextStyle(fontSize: 12, color: Colors.orange[700]),
                ),
              ],
            ),
          ],
        ),
        trailing: Icon(Icons.chevron_right),
        onTap: () => _viewPendingOrderDetails(orderData),
      ),
    );
  }

  Widget _buildTabContent() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text('Error: $_error'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshOrders,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    final allOrders = [
      ..._onlineOrders,
      ..._pendingOrders.map((data) => Order.fromJson(data)),
    ];

    final filteredOrders = _selectedTab == 0
        ? allOrders
        : _selectedTab == 1
        ? _onlineOrders
        : _pendingOrders;

    if (filteredOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _selectedTab == 1 ? Icons.receipt : Icons.wifi_off,
              size: 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              _selectedTab == 0
                  ? 'No Orders Yet'
                  : _selectedTab == 1
                  ? 'No Online Orders'
                  : 'No Pending Orders',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            Text(
              _selectedTab == 0
                  ? 'Orders will appear here after completion'
                  : _selectedTab == 1
                  ? 'Online orders will appear here'
                  : 'Offline orders will sync when online',
              style: TextStyle(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(8),
      itemCount: _selectedTab == 2
          ? _pendingOrders.length
          : _selectedTab == 1
          ? _onlineOrders.length
          : allOrders.length,
      itemBuilder: (context, index) {
        if (_selectedTab == 0) {
          if (index < _onlineOrders.length) {
            return _buildOrderItem(allOrders[index]);
          } else {
            final pendingIndex = index - _onlineOrders.length;
            return _buildPendingOrderItem(_pendingOrders[pendingIndex]);
          }
        } else if (_selectedTab == 1) {
          return _buildOrderItem(_onlineOrders[index]);
        } else {
          return _buildPendingOrderItem(_pendingOrders[index]);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartController = Provider.of<CartController>(context);
    final syncProvider = Provider.of<SyncProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Order History'),
        backgroundColor: Colors.green[700],
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshOrders,
          ),
          if (syncProvider.pendingOrdersCount > 0)
            IconButton(
              icon: Icon(Icons.sync),
              onPressed: () {
                syncProvider.syncNow();
              },
              tooltip: 'Sync Pending Orders',
            ),
        ],
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              children: [
                _buildTabButton('All', 0),
                _buildTabButton('Online', 1),
                _buildTabButton('Offline', 2, badgeCount: syncProvider.pendingOrdersCount),
              ],
            ),
          ),
          // Orders List
          Expanded(
            child: _buildTabContent(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshOrders,
        child: Icon(Icons.refresh),
        backgroundColor: Colors.green[700],
      ),
    );
  }

  Widget _buildTabButton(String label, int tabIndex, {int badgeCount = 0}) {
    return Expanded(
      child: Stack(
        children: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedTab = tabIndex;
              });
            },
            style: TextButton.styleFrom(
              foregroundColor: _selectedTab == tabIndex ? Colors.green[700] : Colors.grey[600],
              backgroundColor: _selectedTab == tabIndex ? Colors.green[50] : Colors.transparent,
              shape: RoundedRectangleBorder(),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: _selectedTab == tabIndex ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          if (badgeCount > 0)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                constraints: BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  badgeCount.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}