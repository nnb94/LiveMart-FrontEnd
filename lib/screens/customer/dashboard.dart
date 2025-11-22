import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:collection/collection.dart'; // For firstWhereOrNull
import 'package:live_mart_app/approutes.dart';
import '../../controllers/customer_orders_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/wishlist_controller.dart';
import '../../models/order.dart';
import '../../services/api_service.dart';
import '../../models/product.dart';
import 'product_card.dart';

class CustomerDashboard extends StatelessWidget {
  const CustomerDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final ProductService productService = Get.put(ProductService(), permanent: true);
    final WishlistController wishlistController = Get.put(
      WishlistController(
        apiService: Get.find<ApiService>(),
        authController: authController,
        productService: productService,
      ),
      permanent: true,
    );

    // Orders Controller setup
    final CustomerOrdersController ordersController = Get.put(
      CustomerOrdersController(
        customerId: authController.userId.value,
        accessToken: authController.accessToken.value,
        apiService: Get.find<ApiService>(),
      ),
    );

    // Fetch products initially
    productService.fetchProducts(authController.accessToken.value);

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Dashboard'),
        actions: [
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
      body: ListView(
        padding: const EdgeInsets.all(16),
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
                icon: Icons.shopping_cart,
                label: 'Cart',
                route: AppRoutes.customerWishlist, // Navigates to the wishlist screen
              ),
              _QuickAccessTile(
                icon: Icons.rate_review,
                label: 'Reviews',
                route: '/customer/reviews/myreviews',
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Recent Orders (GetX integration)
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
                    title: Text('Order #${order.orderId} - ${order.productInfo.name}'),
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

          // Available Products With "Cart" (Wishlist) Button/Controls
          const Text(
            'Available Products',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Obx(() {
            if (productService.products.isEmpty) {
              return const Center(child: Text('No products available'));
            }
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,    // 3 columns = compact
                childAspectRatio: 0.9,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: productService.products.length,
              itemBuilder: (context, index) {
                final product = productService.products[index];
                // Quantities are simulated as 1 (in cart = in wishlist)
                return Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ProductCard(
                            product: product,
                            onTap: () {},
                          ),
                        ),
                        Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          '₹${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 11,
                            color: Colors.teal,
                          ),
                        ),
                        Obx(() {
                          final isInCart = wishlistController.wishlist.any((p) => p.id == product.id);
                          if (!isInCart) {
                            // Not in cart: Show "Add to Cart"
                            return ElevatedButton.icon(
                              icon: const Icon(Icons.add_shopping_cart, size: 15),
                              label: const Text('Add to Cart', style: TextStyle(fontSize: 11)),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(85, 28),
                                padding: EdgeInsets.zero,
                                textStyle: const TextStyle(fontSize: 11),
                              ),
                              onPressed: () async {
                                await wishlistController.addToWishlist(product.id);
                                if (wishlistController.errorMessage.isNotEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(wishlistController.errorMessage.value)),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('${product.name} added to cart')),
                                  );
                                }
                              },
                            );
                          } else {
                            // In cart: Show "Remove from Cart" (simulate quantity 1 only)
                            return ElevatedButton.icon(
                              icon: const Icon(Icons.remove_shopping_cart, size: 15),
                              label: const Text('Remove', style: TextStyle(fontSize: 11)),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(85, 28),
                                padding: EdgeInsets.zero,
                                textStyle: const TextStyle(fontSize: 11),
                                backgroundColor: Colors.red.shade400,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () async {
                                await wishlistController.removeFromWishlist(product.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('${product.name} removed from cart')),
                                );
                              },
                            );
                          }
                        }),
                      ],
                    ),
                  ),
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
          const SizedBox(height: 24),
        ],
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
