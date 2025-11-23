import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:collection/collection.dart';
import 'package:live_mart_app/approutes.dart';
import '../../controllers/customer_orders_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/wishlist_controller.dart';
import '../../models/order.dart';
import '../../services/api_service.dart';
import '../../models/product.dart';
import 'product_card.dart';

class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({Key? key}) : super(key: key);

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  String searchQuery = '';
  String? selectedCategory;

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

    productService.fetchProducts(authController.accessToken.value);

    List<String> allCategories = productService.products
        .map((p) => p.category)
        .where((c) => c.trim().isNotEmpty)
        .toSet()
        .toList();

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
                route: AppRoutes.customerCart,
              ),
              _QuickAccessTile(
                icon: Icons.rate_review,
                label: 'Reviews',
                route: AppRoutes.customerReviews,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search products...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (value) {
                setState(() => searchQuery = value.trim().toLowerCase());
              },
            ),
          ),

          // Category Filter dropdown
          if (allCategories.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: DropdownButtonFormField<String>(
                value: selectedCategory,
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Categories')),
                  ...allCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))),
                ],
                onChanged: (val) {
                  setState(() => selectedCategory = val);
                },
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.filter_alt),
                  labelText: 'Filter Category',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          const SizedBox(height: 6),

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

          // Products grid with search and filter
          const Text(
            'Available Products',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Obx(() {
            var filtered = productService.products.where((product) {
              final matchesSearch = searchQuery.isEmpty ||
                  product.name.toLowerCase().contains(searchQuery) ||
                  product.description.toLowerCase().contains(searchQuery);
              final matchesCategory = selectedCategory == null ||
                  product.category == selectedCategory;
              return matchesSearch && matchesCategory;
            }).toList();

            if (filtered.isEmpty) {
              return const Center(child: Text('No products available'));
            }
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.9,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final product = filtered[index];

                // Reactive widget for quantity and buttons
                return Obx(() {
                  final qtyEntry = wishlistController.wishlist.entries
                      .firstWhereOrNull((entry) => entry.key.id == product.id);
                  final qty = qtyEntry?.value ?? 0;

                  final stockCount = product.stockQuantity ?? 0;

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
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 12),
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
                          Text(
                            stockCount > 30
                                ? 'Available'
                                : stockCount == 0
                                    ? 'Out of stock'
                                    : '$stockCount remaining',
                            style: TextStyle(
                              fontSize: 12,
                              color: stockCount > 0 ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (qty == 0)
                            ElevatedButton.icon(
                              icon: const Icon(Icons.add_shopping_cart, size: 15),
                              label: const Text('Add to Cart',
                                  style: TextStyle(fontSize: 11)),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(85, 28),
                                padding: EdgeInsets.zero,
                                textStyle: const TextStyle(fontSize: 11),
                              ),
                              onPressed: (stockCount > 0)
                                  ? () async {
                                      await wishlistController.addToWishlist(
                                          product.id,
                                          quantity: 1);
                                      if (wishlistController.errorMessage.isEmpty) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                              content:
                                                  Text('${product.name} added to cart')),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'Error: ${wishlistController.errorMessage.value}')),
                                        );
                                      }
                                    }
                                  : null, // disables button if out of stock
                            )
                          else
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline,
                                      size: 18),
                                  color: Colors.deepOrange,
                                  splashRadius: 18,
                                  padding: EdgeInsets.zero,
                                  onPressed: () async {
                                    if (qty == 1) {
                                      await wishlistController
                                          .removeFromWishlist(product.id);
                                      if (wishlistController.errorMessage.isEmpty) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  '${product.name} removed from cart')),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'Error: ${wishlistController.errorMessage.value}')),
                                        );
                                      }
                                    } else {
                                      await wishlistController.addToWishlist(
                                          product.id,
                                          quantity: -1);
                                      if (wishlistController.errorMessage.isEmpty) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'Quantity updated for ${product.name}')),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'Error: ${wishlistController.errorMessage.value}')),
                                        );
                                      }
                                    }
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4),
                                  child: Text(
                                    '$qty',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.deepOrange,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline, size: 18),
                                  color: Colors.green,
                                  splashRadius: 18,
                                  padding: EdgeInsets.zero,
                                  onPressed: () async {
                                    if (qty < stockCount) {
                                      await wishlistController.addToWishlist(
                                          product.id,
                                          quantity: 1);
                                      if (wishlistController.errorMessage.isEmpty) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'Quantity updated for ${product.name}')),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'Error: ${wishlistController.errorMessage.value}')),
                                        );
                                      }
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Cannot add more than available stock (${stockCount})'),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  );
                });
              },
            );
          }),
          const SizedBox(height: 32),

          // Removed Place Order Button as requested

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
