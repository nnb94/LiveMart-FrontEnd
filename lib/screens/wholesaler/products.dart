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
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Product ID: This field cannot be edited',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                ),
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
}
