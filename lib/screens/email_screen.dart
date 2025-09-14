import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/utils.dart';
import '../services/api_service.dart';
import 'otp_screen.dart';

class EmailScreen extends StatefulWidget {
  const EmailScreen({super.key});

  @override
  State<EmailScreen> createState() => _EmailScreenState();
}

class _EmailScreenState extends State<EmailScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  final ApiService _apiService = Get.find<ApiService>();

  void _requestOtp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter a valid email')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final message = await _apiService.sendOtp(email);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      // On success, navigate to OTP screen and pass email
      Get.to(() => OtpScreen(email: email));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1021),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1B41),
        elevation: 8,
        title: const Text(
          'Signup - Enter Email',
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
                                  onPressed: _requestOtp,
                                  child: const Text('Send OTP'),
                                ),
                              ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'Welcome to Neo-Tokyo',
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
                    'Enter your email to begin your journey.',
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
