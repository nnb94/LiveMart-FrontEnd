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
        backgroundColor: const Color(0xFF0A0E27),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Please login to continue',
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Get.offAllNamed(AppRoutes.login),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF17A2B8),
                ),
                child: const Text('Go to Login'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1729),
        elevation: 0,
        title: const Text(
          'Customer Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF0F1729),
                const Color(0xFF0F1729).withOpacity(0.8),
              ],
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
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
          // -------- Modern Quick Actions Row --------
          Row(
            children: [
              _QuickAccessTile(
                icon: Icons.person,
                label: 'Profile',
                route: AppRoutes.customerProfile,
                bgColor: const Color(0xFF5BA8F7), // Blue
              ),
              _QuickAccessTile(
                icon: Icons.shopping_cart,
                label: 'Cart',
                route: AppRoutes.customerCart,
                bgColor: const Color(0xFF30D18C), // Green
              ),
              _QuickAccessTile(
                icon: Icons.rate_review,
                label: 'Reviews',
                route: AppRoutes.customerReviews,
                bgColor: const Color(0xFFB66BF1), // Purple
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                hintText: 'Search products...',
                hintStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF17A2B8)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF17A2B8)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF17A2B8), width: 2),
                ),
                filled: true,
                fillColor: const Color(0xFF0F1729),
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
                dropdownColor: const Color(0xFF0F1729),
                style: const TextStyle(color: Colors.white),
                iconEnabledColor: Colors.white70,
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Categories')),
                  ...allCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))),
                ],
                onChanged: (val) {
                  setState(() => selectedCategory = val);
                },
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.filter_alt, color: Colors.white70),
                  labelText: 'Filter Category',
                  labelStyle: const TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF17A2B8)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF17A2B8), width: 2),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF0F1729),
                ),
              ),
            ),
          const SizedBox(height: 6),

          const Text(
            'Recent Orders',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          Obx(() {
            if (ordersController.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF17A2B8))),
              );
            } else if (ordersController.errorMessage.isNotEmpty) {
              return Center(
                child: Text(
                  'Error loading orders: ${ordersController.errorMessage.value}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            } else if (ordersController.recentOrders.isEmpty) {
              return Center(
                child: Text(
                  'No recent orders found.',
                  style: TextStyle(color: Colors.grey[400]),
                ),
              );
            } else {
              return Column(
                children: ordersController.recentOrders.map((order) {
                  return Card(
                    color: const Color(0xFF0F1729),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      title: Text('Order #${order.orderId} - ${order.productInfo.name}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          )),
                      subtitle: Text(
                        'Status: ${order.orderDetails.status}',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                      trailing: TextButton(
                        child: const Text('Details'),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: const Color(0xFF0F1729),
                              title: Text(
                                'Order Details',
                                style: const TextStyle(color: Colors.white),
                              ),
                              content: Text(
                                'Product: ${order.productInfo.name}\n'
                                'Status: ${order.orderDetails.status}\n'
                                'Quantity: ${order.orderDetails.quantity}\n'
                                'Total: ${order.orderDetails.totalAmount}\n'
                                'Seller: ${order.sellerInfo.name} (${order.sellerInfo.email})',
                                style: const TextStyle(color: Colors.white70),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text(
                                    'Close',
                                    style: TextStyle(color: Color(0xFF17A2B8)),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }).toList(),
              );
            }
          }),
          const SizedBox(height: 32),

          const Text(
            'Available Products',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
          ),
          const SizedBox(height: 8),

          // Products Grid
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
              return Center(
                child: Text(
                  'No products available',
                  style: TextStyle(color: Colors.grey[400]),
                ),
              );
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
                return Obx(() {
                  final qtyEntry = wishlistController.wishlist.entries.firstWhereOrNull(
                      (entry) => entry.key.id == product.id);
                  final qty = qtyEntry?.value ?? 0;
                  // --- HARDCODED STOCK LOGIC STARTS HERE ---
                  String stockText;
                  Color stockColor;
                  if (product.name.toLowerCase().contains("men's cotton oversized t-shirt")) {
                    stockText = "Out of stock";
                    stockColor = Colors.red;
                  } else if (product.name.toLowerCase().contains("mintyfresh toothpaste pack")) {
                    stockText = "Only 7 left in stock";
                    stockColor = Colors.orange;
                  } else {
                    stockText = "Available";
                    stockColor = Colors.green;
                  }
                  // --- END HARDCODED LOGIC ---

                  return Card(
                    color: const Color(0xFF0F1729),
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: ProductCard(
                              product: product,
                              onTap: () {},
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '₹${product.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 11,
                              color: Colors.teal,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            stockText,
                            style: TextStyle(
                              fontSize: 12,
                              color: stockColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (qty == 0)
                            ElevatedButton.icon(
                              icon:
                                  const Icon(Icons.add_shopping_cart, size: 15),
                              label: const Text('Add to Cart',
                                  style: TextStyle(fontSize: 10)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: (stockText != "Out of stock")
                                    ? const Color(0xFF17A2B8)
                                    : Colors.white,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(85, 28),
                                padding: EdgeInsets.zero,
                                textStyle: const TextStyle(fontSize: 11),
                              ),
                              onPressed: (stockText != "Out of stock")
                                  ? () async {
                                      await wishlistController.addToWishlist(
                                          product.id,
                                          quantity: 1);
                                      if (wishlistController.errorMessage.isEmpty) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  '${product.name} added to cart')),
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
                                  : null,
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
                                      await wishlistController.removeFromWishlist(
                                          product.id);
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
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline,
                                      size: 18),
                                  color: Colors.green,
                                  splashRadius: 18,
                                  padding: EdgeInsets.zero,
                                  onPressed: () async {
                                    if (stockText == "Out of stock") return;
                                    if (qty < 100) {
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
                                          content: Text(
                                              'Cannot add more than available stock'),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          const SizedBox(height: 6),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.rate_review, size: 16),
                              label: const Text('Reviews',
                                  style: TextStyle(fontSize: 11)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF17A2B8),
                                foregroundColor: Colors.white,
                                minimumSize: const Size(80, 26),
                                padding: EdgeInsets.zero,
                                textStyle: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                Get.toNamed(
                                  AppRoutes.productReviews,
                                  arguments: {'product': product},
                                );
                              },
                            ),
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

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// --- Modern Quick Access tile styled as dashboard card ---
class _QuickAccessTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final Color bgColor;

  const _QuickAccessTile({
    Key? key,
    required this.icon,
    required this.label,
    required this.route,
    required this.bgColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => Get.toNamed(route),
        child: Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: bgColor.withOpacity(0.15),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 36),
              const SizedBox(height: 18),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: 0.6,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
