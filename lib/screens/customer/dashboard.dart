import 'package:flutter/material.dart';

class CustomerDashboard extends StatelessWidget {
  const CustomerDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dummy data placeholders
    final recommendations = ['Shoes', 'Headphones', 'Backpack'];
    final recentOrders = [
      {'id': 'ORD123', 'status': 'Delivered'},
      {'id': 'ORD124', 'status': 'Shipped'},
      {'id': 'ORD125', 'status': 'Processing'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.pushNamed(context, '/customers/notifications');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick Access Cards
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _QuickAccessTile(
                    icon: Icons.person,
                    label: 'Profile',
                    route: '/customers/profile',
                  ),
                  _QuickAccessTile(
                    icon: Icons.favorite,
                    label: 'Wishlist',
                    route: '/customers/wishlist',
                  ),
                  _QuickAccessTile(
                    icon: Icons.shopping_cart,
                    label: 'Cart',
                    route: '/customers/cart',
                  ),
                  _QuickAccessTile(
                    icon: Icons.rate_review,
                    label: 'Reviews',
                    route: '/customers/reviews/myreviews',
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Recommendations
              const Text('Recommendations', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              SizedBox(
                height: 60,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: recommendations.map((item) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(item),
                    ),
                  )).toList(),
                ),
              ),
              const SizedBox(height: 24),

              // Recent Orders
              const Text('Recent Orders', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
              ...recentOrders.map((order) => ListTile(
                title: Text('Order #${order['id']}'),
                subtitle: Text('Status: ${order['status']}'),
                trailing: TextButton(
                  child: const Text('Details'),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/customers/orders/${order['id']}',
                    );
                  },
                ),
              )),

              const SizedBox(height: 24),

              // Place Order Button
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('Place an Order'),
                  onPressed: () {
                    Navigator.pushNamed(context, '/customers/placeorder');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAccessTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;

  const _QuickAccessTile({
    Key? key,
    required this.icon,
    required this.label,
    required this.route,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 24,
            child: Icon(icon, size: 28),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
