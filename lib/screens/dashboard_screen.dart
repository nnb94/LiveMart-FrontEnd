import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../approutes.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get token from arguments if passed
    final arguments = Get.arguments;
    final token = arguments != null ? arguments['token'] : null;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1021),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1B41),
        elevation: 8,
        title: const Text(
          'Dashboard',
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
                        const Icon(
                          Icons.check_circle,
                          size: 80,
                          color: Color(0xFF00FFF7),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Login Successful!',
                          style: TextStyle(
                            color: Color(0xFF00FFF7),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          'Neo-Tokyo Dashboard',
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
                        const SizedBox(height: 10),
                        const Text(
                          'You are successfully logged in.',
                          style: TextStyle(
                            color: Color(0xFFB8B8FF),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 1.1,
                          ),
                        ),
                        if (token != null) ...[
                          const SizedBox(height: 20),
                          const Text(
                            'Token received',
                            style: TextStyle(
                              color: Color(0xFFFF00C8),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
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