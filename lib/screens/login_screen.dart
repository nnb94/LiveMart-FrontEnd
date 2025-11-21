import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../controllers/auth_controller.dart';
import '../approutes.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
//import '../config.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  final ApiService _api = Get.find<ApiService>();

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter a valid email')));
      return;
    }

    if (password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter your password')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await _api.login(email, password);
      final token = result['token'];
      final role = result['role']?.toString().toLowerCase().trim() ?? '';

      // Get user data from API response and save it
      final authController = Get.find<AuthController>();
      final userData = result['user'] as Map<String, dynamic>?;
      final userId = userData?['id'] as int? ?? 0;
      final userName = userData?['name'] as String? ?? '';

      // Save user data to AuthController
      await authController.saveUser(
        userId: userId,
        token: token,
        email: email,
        role: role,
        name: userName,
      );

      // Show a brief success and navigate
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Login successful')));

      // Navigate based on role (case-insensitive comparison)
      if (role == 'customer') {
        Get.offAllNamed(AppRoutes.customerDashboard);
      } else if (role == 'retailer') {
        Get.offAllNamed(AppRoutes.retailerDashboard);
      } else if (role == 'wholesaler') {
        Get.offAllNamed(AppRoutes.wholesalerDashboard);
      } else {
        // fallback in case role is missing or unknown
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Unknown role: $role. Redirecting to default dashboard.',
            ),
          ),
        );
        Get.offAllNamed(AppRoutes.dashboard);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // final GoogleSignIn _googleSignIn = GoogleSignIn(
  //   clientId: googleClientId,
  //   scopes: ['email', 'profile'],
  // );

  // Future<void> _handleGoogleLogin() async {
  //   setState(() => _isLoading = true);
  //   try {
  //     final user = await _googleSignIn.signIn();
  //     if (user == null) {
  //       setState(() => _isLoading = false);
  //       return; // user canceled
  //     }

  //     final auth = await user.authentication;
  //     final idToken = auth.idToken;
  //     if (idToken == null) throw Exception('Google ID token is null');

  //     final result = await _api.googleLogin(idToken);

  //     // Save user data from Google login
  //     final authController = Get.find<AuthController>();
  //     final userData = result['user'] as Map<String, dynamic>?;
  //     final userId = userData?['id'] as int? ?? 0;
  //     final userName = userData?['name'] as String? ?? '';
  //     final userEmail = userData?['email'] as String? ?? user.email;
  //     final role = userData?['role']?.toString().toLowerCase().trim() ?? '';
  //     final token = result['token'] ?? result['accessToken'] ?? '';

  //     await authController.saveUser(
  //       userId: userId,
  //       token: token,
  //       email: userEmail ?? '',
  //       role: role,
  //       name: userName,
  //     );

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Google login successful')),
  //     );

  //     // Navigate based on role
  //     if (role == 'customer') {
  //       Get.offAllNamed(AppRoutes.customerDashboard);
  //     } else if (role == 'retailer') {
  //       Get.offAllNamed(AppRoutes.retailerDashboard);
  //     } else if (role == 'wholesaler') {
  //       Get.offAllNamed(AppRoutes.wholesalerDashboard);
  //     } else {
  //       Get.offAllNamed(AppRoutes.dashboard);
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Google login failed: $e')),
  //     );
  //   } finally {
  //     if (mounted) setState(() => _isLoading = false);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1021),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1B41),
        elevation: 8,
        title: const Text(
          'Login',
          style: TextStyle(
            color: Color(0xFF00FFF7),
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            fontSize: 22,
            shadows: [
              Shadow(
                color: Color(0xFFFF00C8),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F1021),
              Color(0xFF1A1B41),
              Color(0xFFFF00C8),
              Color(0xFF00FFF7),
              Color(0xFF232946),
            ],
            stops: [0.1, 0.3, 0.6, 0.8, 1.0],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 24,
                      horizontal: 18,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xCC232946),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF00C8).withOpacity(0.25),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      border: Border.all(
                        color: const Color(0xFF00FFF7),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _emailController,
                          style: const TextStyle(
                            color: Color(0xFF00FFF7),
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFF18192B),
                            labelText: 'Email',
                            labelStyle: const TextStyle(
                              color: Color(0xFFFF00C8),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(
                                color: Color(0xFF00FFF7),
                                width: 2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(
                                color: Color(0xFFFF00C8),
                                width: 2.5,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _passwordController,
                          style: const TextStyle(
                            color: Color(0xFF00FFF7),
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFF18192B),
                            labelText: 'Password',
                            labelStyle: const TextStyle(
                              color: Color(0xFFFF00C8),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(
                                color: Color(0xFF00FFF7),
                                width: 2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(
                                color: Color(0xFFFF00C8),
                                width: 2.5,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                          ),
                          obscureText: true,
                        ),
                        const SizedBox(height: 40),
                        _isLoading
                            ? Container(
                                padding: const EdgeInsets.all(20),
                                child: const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF00FFF7),
                                  ),
                                  backgroundColor: Color(0xFF18192B),
                                  strokeWidth: 3,
                                ),
                              )
                            : Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFF00C8),
                                      Color(0xFFFF3366),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFFFF00C8,
                                      ).withOpacity(0.4),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 18,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    textStyle: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  onPressed: _handleLogin,
                                  child: const Text('Login'),
                                ),
                              ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () {
                            Get.toNamed(AppRoutes.email);
                          },
                          child: const Text(
                            'Don\'t have an account? Sign up',
                            style: TextStyle(
                              color: Color(0xFF00FFF7),
                              fontSize: 14,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              Get.toNamed(AppRoutes.forgotPassword),
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: Color(0xFF00FFF7),
                              fontSize: 14,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 🔹 Google Login Button
                        if (kIsWeb)
                          ElevatedButton.icon(
                            icon: Image.asset(
                              'assets/google_logo.png',
                              height: 20,
                            ),
                            label: const Text(
                              'Sign in with Google',
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              elevation: 4,
                            ),
                            onPressed: () {}, //_handleGoogleLogin,
                          )
                        else if (!kIsWeb && Platform.isWindows)
                          ElevatedButton.icon(
                            icon: const Icon(
                              Icons.block,
                              color: Colors.black54,
                            ),
                            label: const Text(
                              'Google Sign-In not available on Windows',
                              style: TextStyle(color: Colors.black54),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade300,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            onPressed: null,
                          )
                        else
                          ElevatedButton.icon(
                            icon: const Icon(Icons.warning),
                            label: const Text(
                              'Google login unsupported on this platform',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade300,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            onPressed: null,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'Welcome Back to Neo-Tokyo',
                    style: TextStyle(
                      color: Color(0xFF00FFF7),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      shadows: [
                        Shadow(color: Color(0xFFFF00C8), blurRadius: 12),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Enter your email and password to continue.',
                    style: TextStyle(
                      color: Color(0xFFB8B8FF),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
