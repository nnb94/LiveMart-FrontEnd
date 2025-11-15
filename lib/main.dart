import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_mart_app/services/api_service.dart';
import 'package:live_mart_app/controllers/auth_controller.dart';
import 'approutes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  Get.put(ApiService());
  
  // Initialize and load saved user data
  final authController = Get.put(AuthController());
  await authController.loadUser();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LiveMart - Neo Tokyo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00FFF7),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.customerDashboard,
      getPages: AppRoutes.routes,
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
