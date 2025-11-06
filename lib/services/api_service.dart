import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

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

  /// Login (per backend auth.rest file)
  /// Endpoint: POST /auth/login
  /// Body: { "email": "user@example.com", "password": "password" }
  /// Response: { "token": "..." }
  Future<String> login(String email, String password) async {
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
      if (token.isEmpty) {
        throw Exception('Login succeeded but token missing in response');
      }
      return token;
    } else {
      String message = 'Login failed';
      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        message = data['message']?.toString() ?? message;
      } catch (_) {}
      throw Exception(message);
    }
  }
}
