import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';
import '../models/order_model.dart';
import 'auth_service.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000';
  static const int timeoutSeconds = 30;

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final http.Client client = http.Client();
  final AuthService _authService = AuthService();

  Map<String, String> get headers {
    final authHeaders = _authService.authHeaders;
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...authHeaders,
    };
  }

  void _handleError(http.Response response) {
    print('API Error: ${response.statusCode} - ${response.body}');

    if (response.statusCode == 401) {
      throw Exception('Authentication failed. Please login again.');
    } else if (response.statusCode == 404) {
      throw Exception('Resource not found.');
    } else if (response.statusCode >= 500) {
      throw Exception('Server error. Please try again later.');
    } else if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('API Error: ${response.statusCode} - ${response.body}');
    }
  }

  Future<http.Response> _makeRequest(Future<http.Response> Function() request) async {
    try {
      // Check internet connection
      try {
        await InternetAddress.lookup('google.com');
      } on SocketException catch (_) {
        throw Exception('No internet connection');
      }

      // Make the request with timeout
      final response = await request().timeout(
        Duration(seconds: timeoutSeconds),
        onTimeout: () {
          throw Exception('Request timeout. Please check your connection.');
        },
      );

      _handleError(response);
      return response;
    } on http.ClientException catch (e) {
      throw Exception('Network error: $e');
    } on FormatException catch (e) {
      throw Exception('Data format error: $e');
    } catch (e) {
      rethrow;
    }
  }

  // Product API Calls
  Future<List<Product>> fetchProducts() async {
    print('🔄 Fetching products from $baseUrl/products');

    final response = await _makeRequest(() => client.get(
      Uri.parse('$baseUrl/products'),
      headers: headers,
    ));

    final List<dynamic> data = json.decode(response.body);
    print('✅ Fetched ${data.length} products');
    return data.map((json) => Product.fromJson(json)).toList();
  }

  Future<Product> getProduct(String productId) async {
    print('🔄 Fetching product $productId');

    final response = await _makeRequest(() => client.get(
      Uri.parse('$baseUrl/products/$productId'),
      headers: headers,
    ));

    final dynamic data = json.decode(response.body);
    return Product.fromJson(data);
  }

  // FIXED: Changed from addProduct to createProduct to match the method name
  Future<Product> createProduct(Product product) async {
    print('🔄 Creating product: ${product.name}');

    final response = await _makeRequest(() => client.post(
      Uri.parse('$baseUrl/products'),
      headers: headers,
      body: json.encode(product.toJson()),
    ));

    final dynamic data = json.decode(response.body);
    print('✅ Product created successfully: ${data['id']}');
    return Product.fromJson(data);
  }

  Future<Product> updateProduct(Product product) async {
    print('🔄 Updating product: ${product.id}');

    final response = await _makeRequest(() => client.put(
      Uri.parse('$baseUrl/products/${product.id}'),
      headers: headers,
      body: json.encode(product.toJson()),
    ));

    final dynamic data = json.decode(response.body);
    print('✅ Product updated successfully');
    return Product.fromJson(data);
  }

  Future<void> deleteProduct(String productId) async {
    print('🔄 Deleting product: $productId');

    await _makeRequest(() => client.delete(
      Uri.parse('$baseUrl/products/$productId'),
      headers: headers,
    ));

    print('✅ Product deleted successfully');
  }

  // Order API Calls
  Future<Order> createOrder(Order order) async {
    print('🔄 Creating order...');

    final orderData = {
      'items': order.items.map((item) => item.toJson()).toList(),
      'subtotal': order.subtotal,
      'tax_amount': order.taxAmount,
      'discount_amount': order.discountAmount,
      'total': order.total,
    };

    print('📦 Order data to send:');
    print('   Items: ${order.items.length}');
    print('   Subtotal: \$${order.subtotal}');
    print('   Tax: \$${order.taxAmount}');
    print('   Discount: \$${order.discountAmount}');
    print('   Total: \$${order.total}');
    print('   Raw JSON: ${jsonEncode(orderData)}');

    final response = await _makeRequest(() => client.post(
      Uri.parse('$baseUrl/orders'),
      headers: headers,
      body: json.encode(orderData),
    ));

    print('📡 Response status: ${response.statusCode}');
    print('📡 Response body: ${response.body}');

    final dynamic data = json.decode(response.body);
    final createdOrder = Order.fromJson(data);

    print('✅ Order created successfully: ${createdOrder.id}');
    return createdOrder;
  }

  Future<List<Order>> fetchOrders({int skip = 0, int limit = 100}) async {
    print('🔄 Fetching orders (skip: $skip, limit: $limit)');

    final response = await _makeRequest(() => client.get(
      Uri.parse('$baseUrl/orders?skip=$skip&limit=$limit'),
      headers: headers,
    ));

    final List<dynamic> data = json.decode(response.body);
    print('✅ Fetched ${data.length} orders');
    return data.map((json) => Order.fromJson(json)).toList();
  }

  Future<Order> getOrder(String orderId) async {
    print('🔄 Fetching order: $orderId');

    final response = await _makeRequest(() => client.get(
      Uri.parse('$baseUrl/orders/$orderId'),
      headers: headers,
    ));

    final dynamic data = json.decode(response.body);
    return Order.fromJson(data);
  }

  // Authentication API Calls
  Future<Map<String, dynamic>> login(String username, String password) async {
    print('🔄 Logging in user: $username');

    final response = await _makeRequest(() => client.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: 'username=$username&password=$password',
    ));

    final data = json.decode(response.body);
    print('✅ Login successful for user: $username');
    return data;
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    print('🔄 Registering user: ${userData['username']}');

    final response = await _makeRequest(() => client.post(
      Uri.parse('$baseUrl/register'),
      headers: headers,
      body: json.encode(userData),
    ));

    final data = json.decode(response.body);
    print('✅ Registration successful');
    return data;
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    print('🔄 Fetching current user');

    final response = await _makeRequest(() => client.get(
      Uri.parse('$baseUrl/users/me'),
      headers: headers,
    ));

    final data = json.decode(response.body);
    return data;
  }

  // Reporting API Calls
  Future<Map<String, dynamic>> getDailySalesReport({String? date}) async {
    print('🔄 Fetching daily sales report for date: $date');

    final url = date != null
        ? Uri.parse('$baseUrl/reports/daily-sales?date=$date')
        : Uri.parse('$baseUrl/reports/daily-sales');

    final response = await _makeRequest(() => client.get(url, headers: headers));
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> getSalesSummary({int days = 30}) async {
    print('🔄 Fetching sales summary for last $days days');

    final response = await _makeRequest(() => client.get(
      Uri.parse('$baseUrl/reports/sales-summary?days=$days'),
      headers: headers,
    ));

    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> getTaxReport(String startDate, String endDate) async {
    print('🔄 Fetching tax report from $startDate to $endDate');

    final response = await _makeRequest(() => client.get(
      Uri.parse('$baseUrl/reports/tax-report?start_date=$startDate&end_date=$endDate'),
      headers: headers,
    ));

    return json.decode(response.body);
  }

  // Tax Authority API Call
  Future<Map<String, dynamic>> submitToTaxAuthority(Map<String, dynamic> invoiceData) async {
    print('🔄 Submitting to tax authority');

    final response = await _makeRequest(() => client.post(
      Uri.parse('$baseUrl/tax-authority/submit'),
      headers: headers,
      body: json.encode(invoiceData),
    ));

    final data = json.decode(response.body);
    print('✅ Tax authority submission: ${data['success'] ? 'SUCCESS' : 'FAILED'}');
    return data;
  }

  // Health check with detailed diagnostics
  Future<Map<String, dynamic>> checkServerHealth() async {
    print('🔄 Checking server health...');

    try {
      final stopwatch = Stopwatch()..start();

      final response = await client.get(
        Uri.parse('$baseUrl/health'),
        headers: headers,
      ).timeout(Duration(seconds: 10));

      stopwatch.stop();

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Server is healthy (${stopwatch.elapsedMilliseconds}ms)');
        return {
          'healthy': true,
          'database': data['database'] ?? 'unknown',
          'response_time_ms': stopwatch.elapsedMilliseconds,
        };
      } else {
        print('❌ Server health check failed: ${response.statusCode}');
        return {
          'healthy': false,
          'error': 'HTTP ${response.statusCode}',
          'response_time_ms': stopwatch.elapsedMilliseconds,
        };
      }
    } on SocketException {
      print('❌ Server is unreachable');
      return {
        'healthy': false,
        'error': 'Cannot reach server',
      };
    } catch (e) {
      print('❌ Server health check error: $e');
      return {
        'healthy': false,
        'error': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> getTaxSubmissionReport() async {
    print('🔄 Fetching tax submission report');

    final response = await _makeRequest(() => client.get(
      Uri.parse('$baseUrl/reports/tax-submissions'),
      headers: headers,
    ));

    return json.decode(response.body);
  }


  Future<bool> testConnection() async {
    try {
      final health = await checkServerHealth();
      return health['healthy'] == true;
    } catch (e) {
      return false;
    }
  }

  // Clear cache or reset (useful for debugging)
  void clearCache() {
    print('🧹 Clearing API service cache');
    client.close();
  }

  @override
  void dispose() {
    client.close();
  }
}