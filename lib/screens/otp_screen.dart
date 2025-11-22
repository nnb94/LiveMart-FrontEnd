import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:pinput/pinput.dart';
import '../services/api_service.dart';
import '../controllers/auth_controller.dart';
import '../approutes.dart';

class OtpScreen extends StatefulWidget {
  final String email; // Email passed from EmailScreen

  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  String? _selectedRole;
  final ApiService _apiService = Get.find<ApiService>();
  final List<String> _roles = ['Customer', 'Wholesaler', 'Retailer'];

  bool _isLoading = false;

  void _verifyOtp() async {
    final name = _nameController.text.trim();
    final password = _passwordController.text.trim();
    final address = _addressController.text.trim();
    final role = (_selectedRole ?? '').toLowerCase();
    final otp = _otpController.text.trim();
    final email = widget.email.trim();

    if (name.isEmpty ||
        password.isEmpty ||
        role.isEmpty ||
        otp.isEmpty ||
        email.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('All fields are required')));
      return;
    }
    if (password.length <= 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be more than 6 characters'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _apiService.verifyOtp(
        name: name,
        email: email,
        password: password,
        role: role,
        otp: otp,
        address: address.isNotEmpty ? address : null,
      );

      final authController = Get.find<AuthController>();
      final userData = result['user'] as Map<String, dynamic>?;
      final userId = userData?['id'] as int? ?? 0;
      final token = result['token'] ?? '';
      final roleLower = role.toLowerCase();

      await authController.saveUser(
        userId: userId,
        token: token,
        email: email,
        role: roleLower,
        name: name,
      );

      await Future.delayed(const Duration(milliseconds: 100));

      final message = result['message'] as String? ?? 'Signup successful';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));

      if (roleLower == 'customer') {
        Get.offAllNamed(AppRoutes.customerDashboard);
      } else if (roleLower == 'retailer') {
        Get.offAllNamed(AppRoutes.retailerDashboard);
      } else if (roleLower == 'wholesaler') {
        Get.offAllNamed(AppRoutes.wholesalerDashboard);
      } else {
        Navigator.pushNamed(context, '/dashboard');
      }
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
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 20,
        color: Color(0xFF0A0E27),
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF17A2B8), width: 2),
        color: Colors.white,
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: const Color(0xFF17A2B8), width: 2.5),
      borderRadius: BorderRadius.circular(12),
      color: Colors.white,
    );

    final submittedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: const Color(0xFF17A2B8), width: 2),
      borderRadius: BorderRadius.circular(12),
      color: Colors.white,
    );

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
                          controller: _nameController,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFF0A0E27),
                            labelText: 'Name',
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
                        const SizedBox(height: 20),
                        TextField(
                          controller: _addressController,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFF0A0E27),
                            labelText: 'Address (Optional)',
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
                          maxLines: 2,
                          keyboardType: TextInputType.multiline,
                        ),
                        const SizedBox(height: 20),
                        DropdownButtonFormField<String>(
                          value: _selectedRole,
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedRole = newValue;
                            });
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFF0A0E27),
                            labelText: 'Role',
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
                          dropdownColor: const Color(0xFF0F1729),
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Color(0xFF17A2B8),
                          ),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          items: _roles.map<DropdownMenuItem<String>>((
                            String value,
                          ) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 30),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0A0E27),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF17A2B8),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF17A2B8).withOpacity(0.2),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'Enter OTP',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Pinput(
                                controller: _otpController,
                                length: 6,
                                defaultPinTheme: defaultPinTheme,
                                focusedPinTheme: focusedPinTheme,
                                submittedPinTheme: submittedPinTheme,
                                pinputAutovalidateMode:
                                    PinputAutovalidateMode.onSubmit,
                                showCursor: true,
                                onCompleted: (pin) {
                                  print('OTP Completed: $pin');
                                },
                              ),
                            ],
                          ),
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
                                  onPressed: _verifyOtp,
                                  child: const Text('Verify & Signup'),
                                ),
                              ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'Complete Your Registration',
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
                    'Enter your details and OTP to continue.',
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
