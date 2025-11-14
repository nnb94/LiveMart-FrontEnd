import 'package:flutter/material.dart';

class CustomerProfile extends StatelessWidget {
  const CustomerProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dummy user data (replace with model or backend integration)
    final customer = {
      'name': 'John Doe',
      'email': 'john.doe@example.com',
      'phone': '+91 9876543210',
      'address': '123, Neo-Tokyo Street, Tokyo',
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 38,
              child: Icon(Icons.person, size: 44),
            ),
            const SizedBox(height: 24),
            Text('Name: ${customer['name']}', style: Theme.of(context).textTheme.titleMedium),
            Text('Email: ${customer['email']}', style: Theme.of(context).textTheme.titleMedium),
            Text('Phone: ${customer['phone']}', style: Theme.of(context).textTheme.titleMedium),
            Text('Address: ${customer['address']}', style: Theme.of(context).textTheme.titleMedium),
            const Spacer(),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text('Edit Profile'),
                onPressed: () {
                  // Placeholder: Add navigation to edit profile screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Edit Profile pressed')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
