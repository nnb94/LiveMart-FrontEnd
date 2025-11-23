import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_mart_app/controllers/wishlist_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../services/api_service.dart';
import '../../models/product.dart';
import '../../approutes.dart';

class CustomerCart extends StatefulWidget {
  const CustomerCart({Key? key}) : super(key: key);

  @override
  State<CustomerCart> createState() => _CustomerCartState();
}

class _CustomerCartState extends State<CustomerCart> {
  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    final wishlistController = Get.put(
      WishlistController(
        apiService: Get.find<ApiService>(),
        authController: authController,
        productService: Get.find<ProductService>(),
      ),
    );

    double getCartTotal() {
      return wishlistController.wishlist.entries.fold(
        0.0,
        (sum, entry) => sum + (entry.key.price ?? 0) * entry.value,
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1729),
        elevation: 0,
        title: const Text(
          'Cart',
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
      ),
      backgroundColor: const Color(0xFF0A0E27),
      body: Obx(() {
        if (wishlistController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF17A2B8)),
            ),
          );
        } else if (wishlistController.errorMessage.isNotEmpty) {
          return Center(
            child: Text(
              wishlistController.errorMessage.value,
              style: const TextStyle(color: Colors.red),
            ),
          );
        } else if (wishlistController.wishlist.isEmpty) {
          return Center(
            child: Text(
              'Your cart is empty.',
              style: TextStyle(color: Colors.white),
            ),
          );
        } else {
          final entries = wishlistController.wishlist.entries.toList();

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final product = entries[index].key;
                    final qty = entries[index].value;
                    final stockCount = product.stockQuantity ?? 0;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF0F1729),
                            const Color(0xFF1A2332).withOpacity(0.5),
                          ],
                        ),
                        border: Border.all(
                          color: const Color(0xFF17A2B8).withOpacity(0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF17A2B8).withOpacity(0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Icon(Icons.shopping_cart, color: Colors.teal),
                        title: Text(
                          product.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '₹${product.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              stockCount > 5
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
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline,
                                  color: Colors.deepOrange),
                              splashRadius: 20,
                              onPressed: () async {
                                if (qty > 1) {
                                  await wishlistController.addToWishlist(
                                      product.id, quantity: -1);
                                } else {
                                  await wishlistController.removeFromWishlist(
                                      product.id);
                                }
                                if (wishlistController.errorMessage.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Quantity updated for ${product.name}'),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Error: ${wishlistController.errorMessage.value}'),
                                    ),
                                  );
                                }
                              },
                            ),
                            Text(
                              '$qty',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline,
                                  color: Colors.green),
                              splashRadius: 20,
                              onPressed: (qty < stockCount)
                                  ? () async {
                                      await wishlistController.addToWishlist(
                                          product.id, quantity: 1);
                                      if (wishlistController.errorMessage.isEmpty) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'Quantity updated for ${product.name}')),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'Error: ${wishlistController.errorMessage.value}')),
                                        );
                                      }
                                    }
                                  : () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Cannot add more than available stock ($stockCount)')),
                                      );
                                    },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    Obx(() => Text(
                          '₹${getCartTotal().toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: Colors.white),
                        )),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.payment),
                    label: const Text('Checkout'),
                    onPressed: () {
                      Get.toNamed(
                        AppRoutes.customerPlaceOrder,
                        arguments: {'totalAmount': getCartTotal()},
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF17A2B8),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }
      }),
    );
  }
}
