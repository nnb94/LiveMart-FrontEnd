import 'package:flutter/material.dart';

class CustomerNotifications extends StatelessWidget {
  const CustomerNotifications({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dummy notifications data
    final notifications = [
      'Your order #ORD123 has been shipped.',
      'New discount on your favorite product!',
      'Delivery scheduled for your recent order #ORD124.',
      'Your review on Running Shoes has been approved.'
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.notifications),
            title: Text(notifications[index]),
            onTap: () {
              // Add action when notification tapped, e.g., open details page
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Tapped: ${notifications[index]}')),
              );
            },
          );
        },
      ),
    );
  }
}
