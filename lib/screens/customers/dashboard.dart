import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_mart_app/approutes.dart';
import '../../controllers/customer_orders_controller.dart'; 
import '../../models/order.dart'; 

class CustomerDashboard extends StatelessWidget {
  const CustomerDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // You should replace these with data from backend/api later
    final recommendations = ['Shoes', 'Headphones', 'Backpack'];

    // Instantiate or get the controller (ensure only one instance is created!)
    final CustomerOrdersController ordersController = Get.put(
      CustomerOrdersController(
        customerId: LoggedInUser.id, // Provide currently logged in user id
        accessToken: LoggedInUser.accessToken, // Provide JWT access token
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Get.toNamed(AppRoutes.customersNotifications);
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
                    route: AppRoutes.customersProfile,
                  ),
                  _QuickAccessTile(
                    icon: Icons.favorite,
                    label: 'Wishlist',
                    route: AppRoutes.customersWishlist,
                  ),
                  _QuickAccessTile(
                    icon: Icons.shopping_cart,
                    label: 'Cart',
                    route: AppRoutes.customersCart,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Recommendations
              const Text('Recommendations',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              SizedBox(
                height: 60,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: recommendations
                      .map(
                        (item) => Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(item),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 24),

              // Recent Orders (GetX Integration)
              const Text('Recent Orders',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
              Obx(() {
                if (ordersController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                } else if (ordersController.errorMessage.isNotEmpty) {
                  return Center(child: Text('Error: ${ordersController.errorMessage.value}'));
                } else if (ordersController.recentOrders.isEmpty) {
                  return const Center(child: Text('No recent orders found.'));
                } else {
                  return Column(
                    children: ordersController.recentOrders.map((order) {
                      return ListTile(
                        title: Text('Order #${order.orderId} - ${order.productInfo.name}'),
                        subtitle: Text('Status: ${order.orderDetails.status}'),
                        trailing: TextButton(
                          child: const Text('Details'),
                          onPressed: () {
                            Get.toNamed('${AppRoutes.customersOrders}/${order.orderId}');
                          },
                        ),
                      );
                    }).toList(),
                  );
                }
              }),

              const SizedBox(height: 24),

              // Place Order Button
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('Place an Order'),
                  onPressed: () {
                    Get.toNamed(AppRoutes.customersPlaceOrder);
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
        Get.toNamed(route);
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
