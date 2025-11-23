import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlaceOrder extends StatefulWidget {
  const PlaceOrder({Key? key}) : super(key: key);

  @override
  _PlaceOrderState createState() => _PlaceOrderState();
}

class _PlaceOrderState extends State<PlaceOrder> {
  bool _isOnlineOrder = true;
  late double totalAmount;

  @override
  void initState() {
    super.initState();
    // Get totalAmount from arguments, or default to 0.0
    final args = Get.arguments as Map<String, dynamic>?;
    totalAmount = args != null && args['totalAmount'] != null ? args['totalAmount'] as double : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1729),
        elevation: 0,
        title: const Text(
          'Place an Order',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF0F1729),
                const Color(0xFF0F1729).withOpacity(0.8),
              ],
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose Order Type',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            Row(
              children: [
                Radio<bool>(
                  value: true,
                  groupValue: _isOnlineOrder,
                  activeColor: const Color(0xFF17A2B8),
                  onChanged: (value) {
                    setState(() {
                      _isOnlineOrder = value!;
                    });
                  },
                ),
                const Text(
                  'Online Order',
                  style: TextStyle(color: Colors.white),
                ),
                Radio<bool>(
                  value: false,
                  groupValue: _isOnlineOrder,
                  activeColor: const Color(0xFF17A2B8),
                  onChanged: (value) {
                    setState(() {
                      _isOnlineOrder = value!;
                    });
                  },
                ),
                const Text(
                  'Offline Order',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Total Amount: ₹${totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 20),
            _isOnlineOrder
                ? const Text(
                    'Online Order Selected.\nYou will proceed with online payment and delivery.',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  )
                : const Text(
                    'Offline Order Selected.\nPlease visit the nearest store to complete your purchase.',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF17A2B8),
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  // Dummy payment here
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: const Color(0xFF0F1729),
                      content: Text(_isOnlineOrder
                          ? 'Dummy payment of ₹${totalAmount.toStringAsFixed(2)} is successful.'
                          : 'Offline order selected. Please visit the store.'),
                    ),
                  );
                },
                child: const Text('Place Order'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
