import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/wholesaler_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/wholesaler_inventory.dart';

class WholesalerInventoryScreen extends StatelessWidget {
  const WholesalerInventoryScreen({super.key});

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
        title: const Text('Inventory Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => wholesalerController.fetchInventory(),
          ),
        ],
      ),
      body: Obx(() {
        if (wholesalerController.isLoadingInventory.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (wholesalerController.inventoryError.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${wholesalerController.inventoryError}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => wholesalerController.fetchInventory(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (wholesalerController.inventory.isEmpty) {
          return const Center(
            child: Text('No products in inventory. Add some products first!'),
          );
        }

        return ListView.builder(
          itemCount: wholesalerController.inventory.length,
          itemBuilder: (context, index) {
            final item = wholesalerController.inventory[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(item.productName[0].toUpperCase()),
                ),
                title: Text(item.productName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Stock: ${item.quantityInStock} | Min Order: ${item.minimumOrderQuantity}'),
                    Text('\$${item.price.toStringAsFixed(2)} each'),
                  ],
                ),
                trailing: Chip(
                  label: Text(item.quantityInStock > item.minimumOrderQuantity * 2 ? 'In Stock' :
                              item.quantityInStock >= item.minimumOrderQuantity ? 'Low Stock' : 'Critical'),
                  backgroundColor: item.quantityInStock > item.minimumOrderQuantity * 2 ? Colors.green.shade100 :
                                 item.quantityInStock >= item.minimumOrderQuantity ? Colors.yellow.shade100 :
                                 Colors.red.shade100,
                ),
                onTap: () => _showInventoryItemDialog(context, wholesalerController, item),
              ),
            );
          },
        );
      }),
    );
  }

  void _showInventoryItemDialog(BuildContext context, WholesalerController controller, WholesalerInventoryItem item) {
    final stockController = TextEditingController(text: item.quantityInStock.toString());
    final minOrderController = TextEditingController(text: item.minimumOrderQuantity.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item.productName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: stockController,
              decoration: const InputDecoration(labelText: 'Current Stock'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: minOrderController,
              decoration: const InputDecoration(labelText: 'Minimum Order Quantity'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              final stock = int.tryParse(stockController.text) ?? item.quantityInStock;
              final minOrder = int.tryParse(minOrderController.text) ?? item.minimumOrderQuantity;
              final success = await controller.updateInventoryItem(
                item.productId,
                quantityInStock: stock,
                minimumOrderQuantity: minOrder,
              );
              if (success) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Update'),
          ),
          TextButton(
            onPressed: () => _showRestockDialog(context, controller, item),
            child: const Text('Restock'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showRestockDialog(BuildContext context, WholesalerController controller, WholesalerInventoryItem item) {
    final quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Restock ${item.productName}'),
        content: TextField(
          controller: quantityController,
          decoration: const InputDecoration(labelText: 'Quantity to add'),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final quantity = int.tryParse(quantityController.text) ?? 0;
              final success = await controller.restockProduct(item.productId, quantity);
              if (success) {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Close inventory dialog too
              }
            },
            child: const Text('Restock'),
          ),
        ],
      ),
    );
  }
}
