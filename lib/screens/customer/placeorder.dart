import 'package:flutter/material.dart';

class PlaceOrder extends StatefulWidget {
  const PlaceOrder({Key? key}) : super(key: key);

  @override
  _PlaceOrderState createState() => _PlaceOrderState();
}

class _PlaceOrderState extends State<PlaceOrder> {
  bool _isOnlineOrder = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Place an Order'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose Order Type',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            Row(
              children: [
                Radio<bool>(
                  value: true,
                  groupValue: _isOnlineOrder,
                  onChanged: (value) {
                    setState(() {
                      _isOnlineOrder = value!;
                    });
                  },
                ),
                const Text('Online Order'),
                Radio<bool>(
                  value: false,
                  groupValue: _isOnlineOrder,
                  onChanged: (value) {
                    setState(() {
                      _isOnlineOrder = value!;
                    });
                  },
                ),
                const Text('Offline Order'),
              ],
            ),
            const SizedBox(height: 20),
            _isOnlineOrder
                ? const Text(
                    'Online Order Selected.\nYou will proceed with online payment and delivery.',
                    style: TextStyle(fontSize: 16),
                  )
                : const Text(
                    'Offline Order Selected.\nPlease visit the nearest store to complete your purchase.',
                    style: TextStyle(fontSize: 16),
                  ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Add place order logic here or navigate to next screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_isOnlineOrder
                          ? 'Placing online order...'
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
