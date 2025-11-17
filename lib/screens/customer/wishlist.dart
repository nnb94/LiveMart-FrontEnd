import 'package:flutter/material.dart';

class CustomerWishlist extends StatelessWidget {
  const CustomerWishlist({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dummy wishlist items
    final wishlistItems = ['Sleek Shoes', 'Noise Cancelling Headphones', 'Travel Backpack'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: wishlistItems.length,
        itemBuilder: (context, index) {
          final item = wishlistItems[index];
          return Card(
            child: ListTile(
              leading: const Icon(Icons.favorite, color: Colors.red),
              title: Text(item),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  // Add remove from wishlist logic here
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$item removed from wishlist')),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
