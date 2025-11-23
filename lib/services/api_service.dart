import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:live_mart_app/models/order.dart';
import 'package:live_mart_app/models/wholesaler_inventory.dart';
import 'package:live_mart_app/models/product.dart';
import 'package:live_mart_app/models/wholesaler_sale.dart';
import 'package:live_mart_app/models/retailer_inventory.dart';
import 'package:live_mart_app/models/review.dart';

class ApiService extends GetxService {
  static const String baseUrl = 'http://localhost:3000';

  /// Sends OTP to the given email
  Future<String> sendOtp(String email) async {
    final url = Uri.parse('$baseUrl/auth/signup/request-otp');

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
    String? address,
  }) async {
    final url = Uri.parse('$baseUrl/auth/signup/verify');
    final requestBody = {
      'name': name,
      'email': email,
      'password': password,
      'role': role,
      'otp': otp,
    };

    // Include address only if it's not empty
    if (address != null && address.trim().isNotEmpty) {
      requestBody['address'] = address.trim();
    }

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
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

  /// Fetch recent orders (no /auth prefix)
  Future<List<Order>> fetchRecentOrders(
    int customerId,
    String accessToken,
  ) async {
    final orderUrl = '$baseUrl/orders'; // no /auth for this one
    final url = Uri.parse('$baseUrl/customers/orders/$customerId');

    final response = await http.get(
      url,
      headers: {
        'Authorization':
            'Bearer $accessToken', // Assuming JWT bearer token auth
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Order.fromJson(json)).toList();
    } else {
      print("Order API error: ${response.body}");
      throw Exception('Failed to load orders: ${response.body}');
    }
  }

  /// Login method
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login/email');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final token = data['accessToken']?.toString() ?? '';
      final role = data['user']?['role']?.toString() ?? '';
      if (token.isEmpty) {
        throw Exception('Login succeeded but token missing in response');
      }
      // Return full response including user data
      return {'token': token, 'role': role, 'user': data['user']};
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
    final url = Uri.parse('$baseUrl/auth/forgot-password/request-otp');
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
    final url = Uri.parse('$baseUrl/auth/forgot-password/verify');
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

  Future<List<Product>> fetchWishlist(String accessToken) async {
    final url = Uri.parse('$baseUrl/wishlists/list');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load wishlist: ${response.body}');
    }
  }

  Future<bool> removeFromWishlist(String accessToken, int productId) async {
    final url = Uri.parse('$baseUrl/wishlists/remove');

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({'productId': productId}),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  // ================= WHOLESALER METHODS =================

  /// Get wholesaler's inventory
  Future<List<WholesalerInventoryItem>> getWholesalerInventory(
    String accessToken,
  ) async {
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
      return jsonList
          .map((json) => WholesalerInventoryItem.fromJson(json))
          .toList();
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
    final url = Uri.parse(
      'http://localhost:3000/wholesalers/inventory/update/$productId',
    );
    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        if (quantityInStock != null) 'quantity_in_stock': quantityInStock,
        if (minimumOrderQuantity != null)
          'minimum_order_quantity': minimumOrderQuantity,
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
    final url = Uri.parse(
      'http://localhost:3000/wholesalers/inventory/restock/$productId',
    );
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

  /// Add new product (for wholesalers) - NO IMAGE VERSION
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
        if (minimumOrderQuantity != null)
          'minimum_order_quantity': minimumOrderQuantity,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to add product: ${response.body}');
    }
  }

  /// Add new product with image (for wholesalers) - MULTIPART VERSION
  Future<Map<String, dynamic>> addProductWithImage({
    required String name,
    required String description,
    required double price,
    required String category,
    required int initialStock,
    int? minimumOrderQuantity,
    required Map<String, dynamic> imageData,
    required String accessToken,
  }) async {
    final url = Uri.parse('http://localhost:3000/products/add');

    try {
      final imageFile = imageData['file'] as File?;
      final imageBytes = imageData['bytes'] as Uint8List?;
      final imagePath = imageData['path'] as String?;
      final imageName = imageData['name'] as String;

      var request = http.MultipartRequest('POST', url)
        ..headers['Authorization'] = 'Bearer $accessToken'
        ..fields['name'] = name
        ..fields['description'] = description
        ..fields['price'] = price.toString()
        ..fields['category'] = category
        ..fields['initial_stock'] = initialStock.toString();

      if (minimumOrderQuantity != null) {
        request.fields['minimum_order_quantity'] = minimumOrderQuantity
            .toString();
      }

      // Use bytes if available (preferred for web), otherwise try file path
      if (imageBytes != null) {
        // Use bytes approach (works for both web and mobile)
        final mimeType = lookupMimeType(imagePath ?? imageName) ?? 'image/png';
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            imageBytes,
            filename: imageName.isNotEmpty ? imageName : 'image.png',
            contentType: MediaType.parse(mimeType),
          ),
        );
      } else if (imageFile != null && imageFile.path.isNotEmpty) {
        // Fallback to file path approach (mobile/desktop)
        final mimeType = lookupMimeType(imageFile.path);
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            imageFile.path,
            contentType: mimeType != null ? MediaType.parse(mimeType) : null,
          ),
        );
      } else {
        throw Exception('No valid image data provided');
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        print('DEBUG: Add product with image response: $responseData');
        return responseData;
      } else {
        throw Exception('Failed to add product with image: ${response.body}');
      }
    } catch (e) {
      // Fallback - try to handle gracefully
      print('Warning: Multipart upload failed, attempting fallback: $e');

      // Try regular POST without image for now
      return await addProduct(
        name: name,
        description: description,
        price: price,
        category: category,
        initialStock: initialStock,
        minimumOrderQuantity: minimumOrderQuantity,
        accessToken: accessToken,
      );
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

  /// Delete product
  Future<Map<String, dynamic>> deleteProduct({
    required int productId,
    required String accessToken,
  }) async {
    final url = Uri.parse('http://localhost:3000/products/delete/$productId');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to delete product: ${response.body}');
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
    final url = Uri.parse(
      'http://localhost:3000/wholesalers/orders/$orderId/status',
    );
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
  Future<List<RetailerInventoryItem>> getRetailerInventory(
    String accessToken,
  ) async {
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
      return jsonList
          .map((json) => RetailerInventoryItem.fromJson(json))
          .toList();
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
    final url = Uri.parse(
      'http://localhost:3000/retailers/inventory/update/$productId',
    );
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
    final url = Uri.parse(
      'http://localhost:3000/retailers/inventory/restock/$productId',
    );
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
  Future<Map<String, dynamic>> getRetailerLowStockAlerts(
    String accessToken,
  ) async {
    final url = Uri.parse(
      'http://localhost:3000/retailers/inventory/low-stock',
    );
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

  /// Delete retailer inventory item (remove product from retailer's stock)
  Future<Map<String, dynamic>> deleteRetailerInventory({
    required int productId,
    required String accessToken,
  }) async {
    final url = Uri.parse(
      'http://localhost:3000/retailers/inventory/delete/$productId',
    );
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to delete inventory item: ${response.body}');
    }
  }

  /// Get products available for purchase (from wholesalers)
  Future<List<Product>> getProducts({String? accessToken}) async {
    final url = Uri.parse('http://localhost:3000/products/all');
    final headers = {'Content-Type': 'application/json'};

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
  Future<List<RetailingPurchaseOrder>> getRetailerPurchaseOrders(
    String accessToken,
  ) async {
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
      return jsonList
          .map((json) => RetailingPurchaseOrder.fromJson(json))
          .toList();
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
  Future<List<RetailingSaleOrder>> getRetailerSalesOrders(
    String accessToken,
  ) async {
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

  Future<Map<String, dynamic>> updateRetailerSaleStatus({
    required int orderId,
    required String status,
    required String accessToken,
  }) async {
    final url = Uri.parse(
      'http://localhost:3000/retailers/orders/$orderId/status',
    );
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
      throw Exception('Failed to update sale status: ${response.body}');
    }
  }

  // ================= REVIEW METHODS =================

  /// Get reviews for a specific product (public access)
  Future<List<Review>> getProductReviews(String productId) async {
    final url = Uri.parse('http://localhost:3000/reviews/product/$productId');
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List jsonList = jsonDecode(response.body);
      final productIdInt = int.parse(productId);
      return jsonList
          .map((json) => Review.fromJson(json, productId: productIdInt))
          .toList();
    } else {
      throw Exception('Failed to fetch product reviews: ${response.body}');
    }
  }

  /// Get current user's reviews (customer only)
  Future<List<Map<String, dynamic>>> getMyReviews(String accessToken) async {
    final url = Uri.parse('http://localhost:3000/reviews/myreviews');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch my reviews: ${response.body}');
    }
  }

  Future<bool> addToWishlist(String accessToken, int productId) async {
    final url = Uri.parse('http://localhost:3000/wishlists/add');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({'productId': productId}),
    );

    return response.statusCode == 201;
  }

  Future<bool> addToRetailerWishlist({
    required String accessToken,
    required int productId,
    required int wholesalerId,
    int? quantity,
    String? notes,
  }) async {
    final url = Uri.parse('http://localhost:3000/retailer-wishlists/add');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'productId': productId,
        'wholesalerId': wholesalerId,
        if (quantity != null) 'quantity': quantity,
        if (notes != null) 'notes': notes,
      }),
    );

    return response.statusCode == 201 || response.statusCode == 200;
  }

  // ==================== PAYMENT METHODS ====================

  /// Get Braintree client token for initializing payment UI
  Future<Map<String, dynamic>> getPaymentClientToken(String accessToken) async {
    final url = Uri.parse('$baseUrl/api/payments/client-token');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Failed to get client token');
    }
  }

  /// Process payment with Braintree
  Future<Map<String, dynamic>> processPayment({
    required String accessToken,
    required String paymentMethodNonce,
    required String amount,
    required String orderId,
  }) async {
    final url = Uri.parse('$baseUrl/api/payments/checkout');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'paymentMethodNonce': paymentMethodNonce,
        'amount': amount,
        'orderId': orderId,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Payment processing failed');
    }
  }

  /// Get transaction details
  Future<Map<String, dynamic>> getTransaction({
    required String accessToken,
    required String transactionId,
  }) async {
    final url = Uri.parse('$baseUrl/api/payments/transaction/$transactionId');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Failed to get transaction');
    }
  }

  /// Refund a transaction (full or partial)
  Future<Map<String, dynamic>> refundTransaction({
    required String accessToken,
    required String transactionId,
    String? amount, // Optional: for partial refund
  }) async {
    final url = Uri.parse(
      '$baseUrl/api/payments/transaction/$transactionId/refund',
    );

    final body = amount != null ? {'amount': amount} : {};

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Refund failed');
    }
  }

  /// Search transactions with filters
  Future<List<dynamic>> searchTransactions({
    required String accessToken,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    double? minAmount,
    double? maxAmount,
  }) async {
    final url = Uri.parse('$baseUrl/api/payments/transactions/search');

    final body = <String, dynamic>{};
    if (status != null) body['status'] = status;
    if (startDate != null) body['startDate'] = startDate.toIso8601String();
    if (endDate != null) body['endDate'] = endDate.toIso8601String();
    if (minAmount != null) body['minAmount'] = minAmount.toString();
    if (maxAmount != null) body['maxAmount'] = maxAmount.toString();

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Failed to search transactions');
    }
  }
}

class ProductService extends GetxService {
  final RxList<Product> products = <Product>[].obs;

  Future<void> fetchProducts(String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/products/all'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        print('DEBUG: Fetched products: ${response.body}');
        final List<dynamic> data = jsonDecode(response.body);
        print('DEBUG: Parsed product data length: ${data.length}');

        // Parse each product individually with error handling
        final List<Product> parsedProducts = [];
        for (var i = 0; i < data.length; i++) {
          try {
            print('DEBUG: Parsing product $i: ${data[i]}');
            final product = Product.fromJson(data[i]);
            parsedProducts.add(product);
            print('DEBUG: Successfully parsed product: ${product.name}');
          } catch (e, stackTrace) {
            print('ERROR parsing product $i: $e');
            print('Product data: ${data[i]}');
            print('Stack trace: $stackTrace');
          }
        }

        products.value = parsedProducts;
        print('DEBUG: Total products loaded: ${products.length}');
      } else {
        throw Exception('Failed to load products: ${response.body}');
      }
    } catch (e) {
      print('Error fetching products: $e');
    }
  }
}
