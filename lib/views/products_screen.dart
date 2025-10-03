import 'package:flutter/material.dart';
import 'package:mpepo_kitchen_pos_app/utils/constants/colors.dart';
import 'package:provider/provider.dart';
import '../controllers/cart_controller.dart';
import '../controllers/product_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/sync_provider.dart';
import '../models/product_model.dart';
import './widgets/product_card.dart';
import './cart_screen.dart';
import './login_screen.dart';
import './report_screen.dart';
import './manage_products_screen.dart';
import './orders_screen.dart';

class ProductsScreen extends StatefulWidget {
  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final ProductController _productController = ProductController();
  final CartController _cartController = CartController();
  List<Product> _products = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProducts();

    // Listen to cart changes
    _cartController.addListener(() {
      setState(() {}); // Refresh UI when cart changes
    });

    // Initialize cart controller and sync
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cartController = Provider.of<CartController>(context, listen: false);
      final syncProvider = Provider.of<SyncProvider>(context, listen: false);

      cartController.initialize();
      syncProvider.initialize();
    });
  }

  @override
  void dispose() {
    _cartController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    try {
      await _productController.loadProducts();
      setState(() {
        _products = _productController.products;
        _error = _productController.error;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _refreshProducts() {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    _loadProducts();
  }

  void _logout(BuildContext context) async {
    final authController = Provider.of<AuthController>(context, listen: false);
    await authController.logout();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  void _showSyncDialog(BuildContext context) {
    final syncProvider = Provider.of<SyncProvider>(context, listen: false);
    final cartController = Provider.of<CartController>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sync Status'),
        content: Consumer<SyncProvider>(
          builder: (context, syncProvider, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (syncProvider.isSyncing) ...[
                  Text('Syncing orders...'),
                  SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: syncProvider.syncProgress / 100,
                  ),
                  SizedBox(height: 8),
                  Text('${syncProvider.syncProgress}% complete'),
                ] else ...[
                  Icon(
                    cartController.isOnline ? Icons.wifi : Icons.wifi_off,
                    size: 40,
                    color: cartController.isOnline ? Colors.green : Colors.orange,
                  ),
                  SizedBox(height: 16),
                  Text(
                    cartController.isOnline ? 'Online' : 'Offline',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: cartController.isOnline ? Colors.green : Colors.orange,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('Pending orders: ${syncProvider.pendingOrdersCount}'),
                ],
              ],
            );
          },
        ),
        actions: [
          if (!Provider.of<SyncProvider>(context).isSyncing)
            TextButton(
              onPressed: () {
                syncProvider.syncNow();
                Navigator.pop(context);
              },
              child: Text('SYNC NOW'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CLOSE'),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineIndicator() {
    return Consumer<CartController>(
      builder: (context, cartController, child) {
        if (!cartController.isOnline) {
          return Container(
            padding: EdgeInsets.all(8),
            color: Colors.orange,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wifi_off, size: 16, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'OFFLINE MODE',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                SizedBox(width: 8),
                if (cartController.pendingOrdersCount > 0)
                  Text(
                    '(${cartController.pendingOrdersCount} pending)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          );
        }
        return SizedBox.shrink();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Mpepo Kitchen POS',style: TextStyle(
          color: Colors.white
        ),),
        actions: [
          // Cart with badge
          Consumer<CartController>(
            builder: (context, cartController, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: Icon(Icons.shopping_cart, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CartScreen(cartController: _cartController),
                        ),
                      );
                    },
                  ),
                  if (cartController.itemCount > 0)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          cartController.itemCount.toString(),
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
              );
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              switch (value) {
                case 'logout':
                  _logout(context);
                  break;
                case 'refresh':
                  _refreshProducts();
                  break;
                case 'reports':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ReportsScreen()),
                  );
                  break;
                case 'manage_products':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ManageProductsScreen()),
                  );
                  break;
                case 'sync_status':
                  _showSyncDialog(context);
                  break;
                case 'order_history':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => OrdersScreen()),
                  );
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'refresh', child: Row(children: [Icon(Icons.refresh, color: TColors.primary), SizedBox(width: 8), Text('Refresh Products')])),
              PopupMenuItem(value: 'manage_products', child: Row(children: [Icon(Icons.inventory, color: Colors.orange), SizedBox(width: 8), Text('Manage Products')])),
              PopupMenuItem(value: 'order_history', child: Row(children: [Icon(Icons.history, color: Colors.blue), SizedBox(width: 8), Text('Order History')])),
              PopupMenuItem(value: 'reports', child: Row(children: [Icon(Icons.analytics, color: Colors.purple), SizedBox(width: 8), Text('Sales Reports')])),
              PopupMenuItem(value: 'sync_status', child: Row(children: [Icon(Icons.sync, color: Colors.teal), SizedBox(width: 8), Text('Sync Status')])),
              PopupMenuItem(value: 'logout', child: Row(children: [Icon(Icons.logout, color: Colors.red), SizedBox(width: 8), Text('Logout')])),
            ],
          ),

        ],
        backgroundColor: TColors.primary,
        shadowColor: Colors.lightBlue,
      ),
      body: Column(
        children: [
          _buildOfflineIndicator(),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text('Error: $_error'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshProducts,
                    child: Text('Retry'),
                  ),
                ],
              ),
            )
                : GridView.builder(
              padding: EdgeInsets.all(8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.8,
              ),
              itemCount: _products.length,
              itemBuilder: (context, index) {
                return ProductCard(
                  product: _products[index],
                  cartController: _cartController,
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: TColors.primary,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Orders
              IconButton(
                icon: Icon(Icons.history, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => OrdersScreen()),
                  );
                },
                tooltip: 'Order History',
              ),

              // Manage Products
              IconButton(
                icon: Icon(Icons.inventory, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ManageProductsScreen()),
                  );
                },
                tooltip: 'Manage Products',
              ),

              // Reports
              IconButton(
                icon: Icon(Icons.analytics, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ReportsScreen()),
                  );
                },
                tooltip: 'View Sales Reports',
              ),

              // Sync with badge
              Consumer<SyncProvider>(
                builder: (context, syncProvider, child) {
                  return Stack(
                    children: [
                      IconButton(
                        icon: Icon(Icons.sync, color: Colors.white),
                        onPressed: () => _showSyncDialog(context),
                        tooltip: 'Sync Status',
                      ),
                      if (syncProvider.pendingOrdersCount > 0)
                        Positioned(
                          right: 4,
                          top: 4,
                          child: Container(
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: BoxConstraints(minWidth: 16, minHeight: 16),
                            child: Text(
                              syncProvider.pendingOrdersCount.toString(),
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
                  );
                },
              ),



            ],
          ),

        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshProducts,
        child: Icon(Icons.refresh),
        backgroundColor: TColors.primary,
      ),
    );
  }
}