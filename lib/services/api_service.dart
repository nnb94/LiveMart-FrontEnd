import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:live_mart_app/models/order.dart';
import '../models/product.dart';

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
  }) async {
    final url = Uri.parse('$baseUrl/auth/signup/verify');
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

  /// Fetch recent orders (no /auth prefix)
  Future<List<Order>> fetchRecentOrders(int customerId, String accessToken) async {
    final orderUrl = '$baseUrl/orders'; // no /auth for this one
    final url = Uri.parse('$baseUrl/customers/orders/$customerId');


    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken', // Assuming JWT bearer token auth
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

  /// Google Login
  Future<Map<String, dynamic>> googleLogin(String idToken) async {
    final url = Uri.parse('$baseUrl/auth/google-login');

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
}

class ProductService extends GetxService {
  final RxList<Product> products = <Product>[].obs;

  Future<void> fetchProducts() async {
    try {
      // Replace with your backend URL
      final response = await http.get(Uri.parse('http://localhost:3000'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        products.value = data.map((e) => Product.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      print('Error fetching products: $e');
    }
  }
}