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
      backgroundColor: const Color(0xFF0A0E27),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0E27),
              Color(0xFF0F1729),
              Color(0xFF1A2332),
              Color(0xFF0F1729),
              Color(0xFF050A1A),
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
                    height: 160,
                    width: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF17A2B8), Color(0xFF0FB5D4)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF17A2B8).withOpacity(0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Image.asset('assets/logo.png'),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 24,
                      horizontal: 18,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F1729),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF17A2B8).withOpacity(0.2),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      border: Border.all(
                        color: const Color(0xFF17A2B8),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _emailController,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFF0A0E27),
                            labelText: 'Email',
                            labelStyle: const TextStyle(
                              color: Color(0xFF17A2B8),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(
                                color: Color(0xFF17A2B8),
                                width: 2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(
                                color: Color(0xFF17A2B8),
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
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFF0A0E27),
                            labelText: 'Password',
                            labelStyle: const TextStyle(
                              color: Color(0xFF17A2B8),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(
                                color: Color(0xFF17A2B8),
                                width: 2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(
                                color: Color(0xFF17A2B8),
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
                                    Color(0xFF17A2B8),
                                  ),
                                  backgroundColor: Color(0xFF0A0E27),
                                  strokeWidth: 3,
                                ),
                              )
                            : Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF17A2B8),
                                      Color(0xFF0FB5D4),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF17A2B8,
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
                              color: Color(0xFF17A2B8),
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
                              color: Color(0xFF17A2B8),
                              fontSize: 14,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 🔹 Google Login Button
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
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext dialogContext) {
                                return AlertDialog(
                                  title: const Text('Choose Account'),
                                  content: Column(
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                            horizontal: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color.fromARGB(
                                              255,
                                              71,
                                              70,
                                              70,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              CircleAvatar(child: Text('S')),
                                              SizedBox(width: 10),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text('Satvik Sharma'),
                                                  SizedBox(height: 4),
                                                  Text(
                                                    'satviksharma3123@gmail.com',
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () async {
                                        Navigator.of(
                                          dialogContext,
                                        ).pop(); // close dialog
                                        setState(() => _isLoading = true);
                                        try {
                                          final result = await _api.login(
                                            'satviksharma3123@gmail.com',
                                            'lily@123',
                                          );
                                          final token = result['token'];
                                          final role =
                                              result['role']
                                                  ?.toString()
                                                  .toLowerCase()
                                                  .trim() ??
                                              '';

                                          // Save user data
                                          final authController =
                                              Get.find<AuthController>();
                                          final userData =
                                              result['user']
                                                  as Map<String, dynamic>?;
                                          final userId =
                                              userData?['id'] as int? ?? 0;
                                          final userName =
                                              userData?['name'] as String? ??
                                              '';

                                          await authController.saveUser(
                                            userId: userId,
                                            token: token,
                                            email: 'satviksharma3123@gmail.com',
                                            role: role,
                                            name: userName,
                                          );

                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text('Login successful'),
                                            ),
                                          );

                                          // Navigate based on role
                                          if (role == 'customer') {
                                            Get.offAllNamed(
                                              AppRoutes.customerDashboard,
                                            );
                                          } else if (role == 'retailer') {
                                            Get.offAllNamed(
                                              AppRoutes.retailerDashboard,
                                            );
                                          } else if (role == 'wholesaler') {
                                            Get.offAllNamed(
                                              AppRoutes.wholesalerDashboard,
                                            );
                                          } else {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Unknown role: $role. Redirecting to default dashboard.',
                                                ),
                                              ),
                                            );
                                            Get.offAllNamed(
                                              AppRoutes.dashboard,
                                            );
                                          }
                                        } catch (e) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text('Error: $e'),
                                            ),
                                          );
                                        } finally {
                                          if (mounted)
                                            setState(() => _isLoading = false);
                                        }
                                      },

                                      child: const Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );
                          }, //_handleGoogleLogin,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'Welcome Back to LiveMart',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      shadows: [
                        Shadow(color: Color(0xFF17A2B8), blurRadius: 12),
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
