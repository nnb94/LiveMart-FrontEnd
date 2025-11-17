import 'package:flutter/material.dart';

class CustomerCart extends StatelessWidget {
  const CustomerCart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dummy cart items
    final cartItems = [
      {'name': 'Running Shoes', 'quantity': 2, 'price': 1200},
      {'name': 'Bluetooth Headphones', 'quantity': 1, 'price': 3500},
    ];

    double totalPrice = cartItems.fold(
        0, (sum, item) => sum + ((item['quantity'] as int) * (item['price'] as int)));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return Card(
                  child: ListTile(
                    title: Text(item['name'] as String),
                    subtitle: Text('Quantity: ${item['quantity'] as int}'),
                    trailing: Text('₹${item['price'] as int}'),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total: ₹$totalPrice',
                    style: Theme.of(context).textTheme.titleLarge),
                ElevatedButton(
                  onPressed: () {
                    // Add checkout logic here
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Proceeding to Checkout')),
                    );
                  },
                  child: const Text('Checkout'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
