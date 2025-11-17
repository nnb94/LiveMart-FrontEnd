import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_mart_app/approutes.dart';
import '../../controllers/customer_orders_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/order.dart'; 
import '../../services/api_service.dart';
import '../../models/product.dart'; 
import 'product_card.dart'; // your existing ProductCard widget

class CustomerDashboard extends StatelessWidget {
  const CustomerDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    if (!authController.isLoggedIn) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Please login to continue'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Get.offAllNamed(AppRoutes.login),
                child: const Text('Go to Login'),
              ),
            ],
          ),
        ),
      );
    }

    final CustomerOrdersController ordersController = Get.put(
      CustomerOrdersController(
        customerId: authController.userId.value,
        accessToken: authController.accessToken.value,
        apiService: Get.find<ApiService>(),
      ),
    );

    final ProductService productService = Get.put(ProductService());
    productService.fetchProducts(); // fetch products on load

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => Get.toNamed(AppRoutes.customerNotifications),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await authController.clearUser();
              Get.offAllNamed(AppRoutes.login);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Action Cards section
            const Text('Quick Actions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: _ActionCard(
                        icon: Icons.person,
                        title: 'Profile',
                        onTap: () => Get.toNamed(AppRoutes.customerProfile),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _ActionCard(
                        icon: Icons.favorite,
                        title: 'Wishlist',
                        onTap: () => Get.toNamed(AppRoutes.customerWishlist),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _ActionCard(
                        icon: Icons.shopping_cart,
                        title: 'Cart',
                        onTap: () => Get.toNamed(AppRoutes.customerCart),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _ActionCard(
                        icon: Icons.rate_review,
                        title: 'Reviews',
                        onTap: () => Get.toNamed('/customer/reviews/myreviews'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Recent Orders Section
            const Text('Recent Orders',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Obx(() {
                  if (ordersController.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (ordersController.errorMessage.isNotEmpty) {
                    return Center(
                      child: Text(
                        'Error loading orders: ${ordersController.errorMessage.value}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  } else if (ordersController.recentOrders.isEmpty) {
                    return const Center(child: Text('No recent orders found.'));
                  } else {
                    return Column(
                      children: ordersController.recentOrders.map((order) {
                        return ListTile(
                          title: Text(
                              'Order #${order.orderId} - ${order.productInfo.name}'),
                          subtitle: Text('Status: ${order.orderDetails.status}'),
                          trailing: TextButton(
                            child: const Text('Details'),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Order Details'),
                                  content: Text(
                                      'Product: ${order.productInfo.name}\n'
                                      'Status: ${order.orderDetails.status}\n'
                                      'Quantity: ${order.orderDetails.quantity}\n'
                                      'Total: ${order.orderDetails.totalAmount}\n'
                                      'Seller: ${order.sellerInfo.name} (${order.sellerInfo.email})'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Close'),
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      }).toList(),
                    );
                  }
                }),
              ),
            ),
            const SizedBox(height: 32),

            // Available Products Section
            const Text('Available Products',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Obx(() {
                  if (productService.products.isEmpty) {
                    return const Center(child: Text('No products available'));
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: productService.products.length,
                    itemBuilder: (context, index) {
                      final product = productService.products[index];
                      return ProductCard(
                        product: product,
                        onTap: () {
                          // Implement product detail or purchase navigation here
                        },
                      );
                    },
                  );
                }),
              ),
            ),
            const SizedBox(height: 32),

            // Place Order Button
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Place an Order'),
                onPressed: () {
                  Get.toNamed(AppRoutes.customerPlaceOrder);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ActionCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: Colors.blue),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}
