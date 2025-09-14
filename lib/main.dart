import 'package:flutter/material.dart';
import 'screens/email_screen.dart';
import 'screens/otp_screen.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OTP Signup Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/email',
      routes: {
        '/email': (context) => const EmailScreen(),
        '/otp': (context) => const OtpScreen(email: ''),
        '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }
}
