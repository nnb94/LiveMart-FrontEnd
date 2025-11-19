import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_mart_app/approutes.dart';
import '../../controllers/customer_orders_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/order.dart';

import '../../services/api_service.dart';
import '../../models/product.dart';
import 'product_card.dart'; // the ProductCard widget from previous snippet

class CustomerDashboard extends StatelessWidget {
  const CustomerDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get user data from AuthController instead of LoggedInUser
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
    productService.fetchProducts(
      authController.accessToken.value,
    ); // load products

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Get.toNamed(AppRoutes.customerNotifications);
            },
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
                    route: AppRoutes.customerProfile,
                  ),
                  _QuickAccessTile(
                    icon: Icons.favorite,
                    label: 'Wishlist',
                    route: AppRoutes.customerWishlist,
                  ),
                  _QuickAccessTile(
                    icon: Icons.shopping_cart,
                    label: 'Cart',
                    route: AppRoutes.customerCart,
                  ),
                  _QuickAccessTile(
                    icon: Icons.rate_review,
                    label: 'Reviews',
                    route: '/customer/reviews/myreviews',
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Recent Orders (GetX Integration)
              const Text(
                'Recent Orders',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              Obx(() {
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
                          'Order #${order.orderId} - ${order.productInfo.name}',
                        ),
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
                                  'Seller: ${order.sellerInfo.name} (${order.sellerInfo.email})',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Close'),
                                  ),
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
              const SizedBox(height: 32),

              // Product Listing
              const Text(
                'Available Products',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Obx(() {
                if (productService.products.isEmpty) {
                  return const Center(child: Text('No products available'));
                }
                print(
                  'DEBUG Dashboard: Total products = ${productService.products.length}',
                );
                for (var i = 0; i < productService.products.length; i++) {
                  print('Product $i: ${productService.products[i].name}');
                }
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: productService.products.length,
                  itemBuilder: (context, index) {
                    final product = productService.products[index];
                    return ProductCard(
                      product: product,
                      onTap: () {
                        print('Tapped product: ${product.name}');
                      },
                    );
                  },
                );
              }),

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
          CircleAvatar(radius: 24, child: Icon(icon, size: 28)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
