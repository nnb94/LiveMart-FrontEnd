import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:live_mart_app/models/order.dart';
import 'package:live_mart_app/models/wholesaler_inventory.dart';
import 'package:live_mart_app/models/product.dart';
import 'package:live_mart_app/models/wholesaler_sale.dart';
import 'package:live_mart_app/models/retailer_inventory.dart';

class ApiService extends GetxService {
  static const String baseUrl = 'http://localhost:3000/auth';

  /// Sends OTP to the given email
  Future<String> sendOtp(String email) async {
    final url = Uri.parse('$baseUrl/signup/request-otp');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['message'] ?? 'OTP sent';
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Failed to send OTP');
    }
  }

  /// Verifies OTP and completes signup
  Future<Map<String, dynamic>> verifyOtp({
    required String name,
    required String email,
    required String password,
    required String role,
    required String otp,
  }) async {
    final url = Uri.parse('$baseUrl/signup/verify');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'role': role,
        'otp': otp,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      // Return full response including token and user data
      return {
        'message': 'Signup successful for ${data['user']?['name'] ?? name}',
        'token': data['token'] ?? '',
        'user': data['user'],
      };
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'OTP verification failed');
    }
  }

  Future<List<Order>> fetchRecentOrders(int customerId, String accessToken) async {
    final url = Uri.parse('$baseUrl/customer/orders/$customerId');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',  // Assuming JWT bearer token auth
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Order.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load orders: ${response.body}');
    }
  }
  /// Login (per backend auth.rest file)
  /// Endpoint: POST /auth/login
  /// Body: { "email": "user@example.com", "password": "password" }
  /// Response: { "token": "..." }
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login/email');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final token = data['accessToken']?.toString() ?? '';
      final role = data['user']?['role']?.toString() ?? '';
      if (token.isEmpty) {
        throw Exception('Login succeeded but token missing in response');
      }
      // Return full response including user data
      return {
        'token': token,
        'role': role,
        'user': data['user'],
      };
    } else {
      String message = 'Login failed';
      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        message = data['message']?.toString() ?? message;
      } catch (_) {}
      throw Exception(message);
    }
  }

   /// Step 1: Request OTP for forgot password
  Future<String> sendForgotPasswordOtp(String email) async {
    final url = Uri.parse('$baseUrl/forgot-password/request-otp');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data['message'] ?? 'OTP sent successfully';
    } else {
      throw Exception(data['message'] ?? 'Failed to send OTP');
    }
  }

  /// Step 2: Verify OTP and set new password
  Future<String> verifyForgotPasswordOtp({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final url = Uri.parse('$baseUrl/forgot-password/verify');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'otp': otp,
        'newPassword': newPassword,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data['message'] ?? 'Password reset successful';
    } else {
      throw Exception(data['message'] ?? 'Password reset failed');
    }
  }

  Future<Map<String, dynamic>> googleLogin(String idToken) async {
  final url = Uri.parse('$baseUrl/google-login');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'token': idToken}),
  );

  if (response.statusCode == 200) {
    // Parse the response body (expected to contain token + user)
    return jsonDecode(response.body);
  } else {
    throw Exception('Google login failed: ${response.body}');
  }
}

  // ================= WHOLESALER METHODS =================

  /// Get wholesaler's inventory
  Future<List<WholesalerInventoryItem>> getWholesalerInventory(String accessToken) async {
    final url = Uri.parse('http://localhost:3000/wholesalers/inventory');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List jsonList = jsonDecode(response.body);
      return jsonList.map((json) => WholesalerInventoryItem.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch inventory: ${response.body}');
    }
  }

  /// Update wholesaler inventory stock and settings
  Future<Map<String, dynamic>> updateWholesalerInventory({
    required int productId,
    int? quantityInStock,
    int? minimumOrderQuantity,
    required String accessToken,
  }) async {
    final url = Uri.parse('http://localhost:3000/wholesalers/inventory/update/$productId');
    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        if (quantityInStock != null) 'quantity_in_stock': quantityInStock,
        if (minimumOrderQuantity != null) 'minimum_order_quantity': minimumOrderQuantity,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update inventory: ${response.body}');
    }
  }

  /// Restock inventory (add stock)
  Future<Map<String, dynamic>> restockWholesalerInventory({
    required int productId,
    required int quantity,
    required String accessToken,
  }) async {
    final url = Uri.parse('http://localhost:3000/wholesalers/inventory/restock/$productId');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'quantity': quantity}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to restock inventory: ${response.body}');
    }
  }

  /// Get wholesaler's products (for management)
  Future<List<Product>> getWholesalerProducts(String accessToken) async {
    final url = Uri.parse('http://localhost:3000/products/myproducts');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch products: ${response.body}');
    }
  }

  /// Add new product (for wholesalers)
  Future<Map<String, dynamic>> addProduct({
    required String name,
    required String description,
    required double price,
    required String category,
    required int initialStock,
    int? minimumOrderQuantity,
    required String accessToken,
  }) async {
    final url = Uri.parse('http://localhost:3000/products/add');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'description': description,
        'price': price,
        'category': category,
        'initial_stock': initialStock,
        if (minimumOrderQuantity != null) 'minimum_order_quantity': minimumOrderQuantity,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to add product: ${response.body}');
    }
  }

  /// Update product
  Future<Map<String, dynamic>> updateProduct({
    required int productId,
    String? name,
    String? description,
    double? price,
    String? category,
    required String accessToken,
  }) async {
    final url = Uri.parse('http://localhost:3000/products/update/$productId');
    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (price != null) 'price': price,
        if (category != null) 'category': category,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update product: ${response.body}');
    }
  }

  /// Get wholesaler's sales orders
  Future<List<WholesalerSale>> getWholesalerSales(String accessToken) async {
    final url = Uri.parse('http://localhost:3000/wholesalers/orders/sales');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List jsonList = jsonDecode(response.body);
      return jsonList.map((json) => WholesalerSale.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch sales orders: ${response.body}');
    }
  }

  /// Update order status
  Future<Map<String, dynamic>> updateWholesalerOrderStatus({
    required int orderId,
    required String status,
    required String accessToken,
  }) async {
    final url = Uri.parse('http://localhost:3000/wholesalers/orders/$orderId/status');
    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'status': status}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update order status: ${response.body}');
    }
  }

  /// Get sales analytics
  Future<WholesalerAnalytics> getWholesalerAnalytics(String accessToken) async {
    final url = Uri.parse('http://localhost:3000/wholesalers/analytics/sales');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return WholesalerAnalytics.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch analytics: ${response.body}');
    }
  }

  // ================= RETAILER METHODS =================

  /// Get retailer's inventory
  Future<List<RetailerInventoryItem>> getRetailerInventory(String accessToken) async {
    final url = Uri.parse('http://localhost:3000/retailers/inventory');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List jsonList = jsonDecode(response.body);
      return jsonList.map((json) => RetailerInventoryItem.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch retailer inventory: ${response.body}');
    }
  }

  /// Update retailer inventory stock and settings
  Future<Map<String, dynamic>> updateRetailerInventory({
    required int productId,
    int? quantityInStock,
    int? reorderLevel,
    required String accessToken,
  }) async {
    final url = Uri.parse('http://localhost:3000/retailers/inventory/update/$productId');
    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        if (quantityInStock != null) 'quantity_in_stock': quantityInStock,
        if (reorderLevel != null) 'reorder_level': reorderLevel,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update retailer inventory: ${response.body}');
    }
  }

  /// Restock retailer inventory (add stock)
  Future<Map<String, dynamic>> restockRetailerInventory({
    required int productId,
    required int quantity,
    required String accessToken,
  }) async {
    final url = Uri.parse('http://localhost:3000/retailers/inventory/restock/$productId');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'quantity': quantity}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to restock retailer inventory: ${response.body}');
    }
  }

  /// Get retailer low stock alerts
  Future<Map<String, dynamic>> getRetailerLowStockAlerts(String accessToken) async {
    final url = Uri.parse('http://localhost:3000/retailers/inventory/low-stock');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch low stock alerts: ${response.body}');
    }
  }

  /// Get products available for purchase (from wholesalers)
  Future<List<Product>> getProducts({String? accessToken}) async {
    final url = Uri.parse('http://localhost:3000/products/all');
    final headers = {
      'Content-Type': 'application/json',
    };

    if (accessToken != null) {
      headers['Authorization'] = 'Bearer $accessToken';
    }

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final List jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch products: ${response.body}');
    }
  }

  /// Get retailer's purchase orders (from wholesalers)
  Future<List<RetailingPurchaseOrder>> getRetailerPurchaseOrders(String accessToken) async {
    final url = Uri.parse('http://localhost:3000/retailers/orders/purchases');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List jsonList = jsonDecode(response.body);
      return jsonList.map((json) => RetailingPurchaseOrder.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch purchase orders: ${response.body}');
    }
  }

  /// Place wholesale order (retailer buying from wholesalers)
  Future<Map<String, dynamic>> placeRetailerWholesaleOrder({
    required List<Map<String, dynamic>> products,
    required String accessToken,
  }) async {
    final url = Uri.parse('http://localhost:3000/retailers/order/wholesale');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'products': products}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to place wholesale order: ${response.body}');
    }
  }

  /// Get retailer's sales orders (to customers)
  Future<List<RetailingSaleOrder>> getRetailerSalesOrders(String accessToken) async {
    final url = Uri.parse('http://localhost:3000/retailers/orders/sales');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List jsonList = jsonDecode(response.body);
      return jsonList.map((json) => RetailingSaleOrder.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch sales orders: ${response.body}');
    }
  }
}
