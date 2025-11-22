import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/wishlist_controller.dart'; // Assuming this file exists and is set up
import '../../services/api_service.dart';

class CustomerWishlist extends StatelessWidget {
  const CustomerWishlist({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    // Initialize WishlistController with ApiService and AuthController
    final wishlistController = Get.put(
      WishlistController(
        apiService: Get.find<ApiService>(),
        authController: Get.find<AuthController>(),
        productService: Get.find<ProductService>(),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Wishlist')),
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
          return const Center(child: Text('Your wishlist is empty.'));
        } else {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: wishlistController.wishlist.length,
            itemBuilder: (context, index) {
              final product = wishlistController.wishlist[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.favorite, color: Colors.red),
                  title: Text(product.name),
                  subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      await wishlistController.removeFromWishlist(product.id);
                      if (wishlistController.errorMessage.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${product.name} removed from wishlist',
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Error: ${wishlistController.errorMessage.value}',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              );
            },
          );
        }
      }),
    );
  }
}
