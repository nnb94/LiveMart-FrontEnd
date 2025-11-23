import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/wishlist_controller.dart';
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
        title: const Text('Cart'),
      ),
      body: Obx(() {
        if (wishlistController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (wishlistController.errorMessage.isNotEmpty) {
          return Center(
            child: Text(
              wishlistController.errorMessage.value,
              style: const TextStyle(color: Colors.red),
            ),
          );
        } else if (wishlistController.wishlist.isEmpty) {
          return const Center(child: Text('Your cart is empty.'));
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

                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.shopping_cart, color: Colors.teal),
                        title: Text(product.name),
                        subtitle: Text('₹${product.price.toStringAsFixed(2)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.deepOrange),
                              onPressed: () async {
                                if (qty > 1) {
                                  await wishlistController.addToWishlist(product.id, quantity: -1);
                                } else {
                                  await wishlistController.removeFromWishlist(product.id);
                                }
                                if (wishlistController.errorMessage.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Quantity updated for ${product.name}')),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: ${wishlistController.errorMessage.value}')),
                                  );
                                }
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Text(
                                '$qty',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.deepOrange),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                              onPressed: () async {
                                await wishlistController.addToWishlist(product.id, quantity: 1);
                                if (wishlistController.errorMessage.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Quantity updated for ${product.name}')),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: ${wishlistController.errorMessage.value}')),
                                  );
                                }
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
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Obx(() => Text(
                          '₹${getCartTotal().toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.teal),
                        )),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.payment),
                    label: const Text('Checkout'),
                    onPressed: () {
                      Get.toNamed(AppRoutes.customerPlaceOrder,
                      arguments: {'totalAmount': getCartTotal()},        
                    );
                    },
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
