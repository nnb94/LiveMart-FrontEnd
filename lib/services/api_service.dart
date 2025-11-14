import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:live_mart_app/models/order.dart';

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
  Future<String> verifyOtp({
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
      final data = jsonDecode(response.body);
      return 'Signup successful for ${data['user']['name']}';
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'OTP verification failed');
    }
  }

  Future<List<Order>> fetchRecentOrders(int customerId, String accessToken) async {
    final url = Uri.parse('$baseUrl/customers/orders/$customerId');
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
}
