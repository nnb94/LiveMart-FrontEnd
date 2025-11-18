import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/wholesaler_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/product.dart';

class WholesalerProductsScreen extends StatelessWidget {
  const WholesalerProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final wholesalerController = Get.find<WholesalerController>();

    // Check authentication
    if (!authController.isLoggedIn || authController.role.value != 'wholesaler') {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Please login as a wholesaler to continue'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Get.offAllNamed('/login'),
                child: const Text('Go to Login'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => wholesalerController.fetchProducts(),
          ),
        ],
      ),
      body: Obx(() {
        if (wholesalerController.isLoadingProducts.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (wholesalerController.productsError.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${wholesalerController.productsError}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => wholesalerController.fetchProducts(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (wholesalerController.products.isEmpty) {
          return const Center(
            child: Text('No products added yet. Use the dashboard to add your first product!'),
          );
        }

        return ListView.builder(
          itemCount: wholesalerController.products.length,
          itemBuilder: (context, index) {
            final product = wholesalerController.products[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(product.name[0].toUpperCase()),
                ),
                title: Text(product.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.description),
                    Text('Category: ${product.category}'),
                    Text('Price: \$${product.price.toStringAsFixed(2)}'),
                  ],
                ),
                trailing: Chip(
                  label: const Text('VIEW'),
                  backgroundColor: Colors.blue.shade100,
                ),
                onTap: () => _showProductDialog(context, wholesalerController, product),
              ),
            );
          },
        );
      }),
    );
  }

  void _showProductDialog(BuildContext context, WholesalerController controller, Product product) {
    final nameController = TextEditingController(text: product.name);
    final descriptionController = TextEditingController(text: product.description);
    final priceController = TextEditingController(text: product.price.toString());
    final categoryController = TextEditingController(text: product.category);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Product: ${product.name}'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 16),
              IgnorePointer(
                ignoring: true,
                child: TextField(
                  controller: TextEditingController(text: product.id.toString()),
                  decoration: const InputDecoration(
                    labelText: 'Product ID',
                    filled: true,
                    fillColor: Color(0xFFF5F5F5),
                  ),
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Product ID cannot be edited',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue,
                    fontWeight: FontWeight.w500
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () =>
              _showDeleteConfirmationDialog(Get.context!, controller, product),
            child: const Text('Delete'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text;
              final description = descriptionController.text;
              final price = double.tryParse(priceController.text);
              final category = categoryController.text;

              if (name.isEmpty || description.isEmpty || price == null || category.isEmpty) {
                Get.snackbar('Error', 'Please fill all fields correctly');
                return;
              }

              final success = await controller.updateProduct(
                product.id,
                name: name,
                description: description,
                price: price,
                category: category,
              );

              if (success) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, WholesalerController controller, Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Are you sure you want to delete "${product.name}"?'),
              const SizedBox(height: 8),
              Text(
                'This action cannot be undone. The product will be removed from your inventory.',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              // Close confirmation dialog first
              Navigator.of(context).pop();
              // Close product dialog
              Navigator.of(context).pop();

              // Delete the product
              final success = await controller.deleteProduct(product.id);
              if (!success) {
                // If deletion failed, re-show the product dialog
                Get.snackbar('Error', 'Failed to delete product. Please try again.');
              }
            },
            child: const Text(
              'Delete Product',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
