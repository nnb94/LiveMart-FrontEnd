import 'package:flutter/material.dart';
class RetailerDashboard extends StatelessWidget {
  const RetailerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Retailer Dashboard')),
      body: const Center(child: Text('Welcome, Retailer!')),
    );
  }
}