import 'package:flutter/material.dart';

class CustomerOrders extends StatelessWidget {
  const CustomerOrders({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dummy order data
    final orders = [
      {'id': 'ORD123', 'date': '2025-11-01', 'status': 'Delivered', 'total': 2500},
      {'id': 'ORD124', 'date': '2025-11-05', 'status': 'Shipped', 'total': 1750},
      {'id': 'ORD125', 'date': '2025-11-06', 'status': 'Processing', 'total': 3200},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Card(
            child: ListTile(
              title: Text('Order #${order['id']}'),
              subtitle: Text('Date: ${order['date']}'),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Status: ${order['status']}'),
                  Text('Total: ₹${order['total']}'),
                ],
              ),
              onTap: () {
                // Navigate to Order Details page with order ID
                Navigator.pushNamed(context, '/customer/orders/${order['id']}');
              },
            ),
          );
        },
      ),
    );
  }
}
