import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/retailer_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/retailer_inventory.dart';
import '../../widgets/image_picker_components.dart';

class RetailerInventoryScreen extends StatelessWidget {
  const RetailerInventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final retailerController = Get.find<RetailerController>();

    // Check authentication
    if (!authController.isLoggedIn || authController.role.value != 'retailer') {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Please login as a retailer to continue'),
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
            onPressed: () => retailerController.fetchInventory(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Low stock alerts banner
          _buildLowStockAlertsBanner(retailerController),

          // Inventory list
          Expanded(
            child: GetBuilder<RetailerController>(
              builder: (controller) {
                if (controller.isLoadingInventory.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.inventoryError.value.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(controller.inventoryError.value),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => controller.fetchInventory(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (controller.inventory.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'No products in inventory',
                          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                        Text(
                          'Order from wholesalers first',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: controller.inventory.length,
                  itemBuilder: (context, index) {
                    final item = controller.inventory[index];
                    return _buildInventoryItemCard(context, controller, item);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed('/retailer/purchasing'),
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('Order Stock'),
      ),
    );
  }

  Widget _buildLowStockAlertsBanner(RetailerController controller) {
    return GetBuilder<RetailerController>(
      builder: (controller) => controller.getLowStockCount() == 0
        ? const SizedBox.shrink()
        : Container(
            color: Colors.orange.shade50,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${controller.getLowStockCount()} products are low on stock',
                    style: TextStyle(color: Colors.orange.shade900, fontWeight: FontWeight.w500),
                  ),
                ),
                TextButton(
                  onPressed: () => _showLowStockAlertsDialog(),
                  child: const Text('View'),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildInventoryItemCard(BuildContext context, RetailerController controller, RetailerInventoryItem item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Obx(() {
          final productImageUrl = controller.getProductImageUrl(item.productId);

          if (productImageUrl != null) {
            // Display actual product image
            return ProductImageWidget(
              imageUrl: productImageUrl,
              fallbackText: item.productName,
              size: 60,
            );
          } else {
            // Fallback to initial letter avatar
            return CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              radius: 30,
              child: Text(
                item.productName.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            );
          }
        }),
        title: Text(
          item.productName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Price: \$${item.price.toStringAsFixed(2)}'),
            const SizedBox(height: 2),
            Text('Stock: ${item.quantityInStock} units'),
            Text('Reorder Level: ${item.reorderLevel} units'),
            if (item.needsRestock) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'LOW STOCK',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            switch (value) {
              case 'update':
                _showUpdateInventoryDialog(context, controller, item);
                break;
              case 'restock':
                _showRestockDialog(context, controller, item);
                break;
              case 'delete':
                _showDeleteConfirmationDialog(context, controller, item);
                break;
            }
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem<String>(
              value: 'update',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 18),
                  SizedBox(width: 8),
                  Text('Update Stock'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'restock',
              child: Row(
                children: [
                  Icon(Icons.add_circle, size: 18),
                  SizedBox(width: 8),
                  Text('Restock'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red, size: 18),
                  SizedBox(width: 8),
                  Text('Remove Product',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateInventoryDialog(BuildContext context, RetailerController controller, RetailerInventoryItem item) {
    final stockController = TextEditingController(text: item.quantityInStock.toString());
    final reorderController = TextEditingController(text: item.reorderLevel.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update ${item.productName}'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IgnorePointer(
                ignoring: true,
                child: TextField(
                  controller: TextEditingController(text: item.productId.toString()),
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
              const SizedBox(height: 16),
              TextField(
                controller: stockController,
                decoration: const InputDecoration(labelText: 'Current Stock'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: reorderController,
                decoration: const InputDecoration(labelText: 'Reorder Level'),
                keyboardType: TextInputType.number,
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
              final stock = int.tryParse(stockController.text);
              final reorder = int.tryParse(reorderController.text);

              if (stock == null || reorder == null) {
                Get.snackbar('Error', 'Please enter valid numbers');
                return;
              }

              final success = await controller.updateInventoryItem(
                item.productId,
                quantityInStock: stock,
                reorderLevel: reorder,
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

  void _showRestockDialog(BuildContext context, RetailerController controller, RetailerInventoryItem item) {
    final quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Restock ${item.productName}'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IgnorePointer(
                ignoring: true,
                child: TextField(
                  controller: TextEditingController(text: item.productId.toString()),
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
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Product ID (reference only)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                    fontWeight: FontWeight.w500
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              Text('Current Stock: ${item.quantityInStock} units'),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'Quantity to add'),
                keyboardType: TextInputType.number,
                autofocus: true,
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
              final quantity = int.tryParse(quantityController.text);
              if (quantity == null || quantity <= 0) {
                Get.snackbar('Error', 'Please enter a valid quantity');
                return;
              }

              final success = await controller.restockProduct(item.productId, quantity);
              if (success) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Restock'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, RetailerController controller, RetailerInventoryItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Product from Inventory'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IgnorePointer(
                ignoring: true,
                child: TextField(
                  controller: TextEditingController(text: item.productId.toString()),
                  decoration: const InputDecoration(
                    labelText: 'Product ID',
                    filled: true,
                    fillColor: Color(0xFFF5F5F5),
                  ),
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),
              Text('Are you sure you want to remove "${item.productName}" from your inventory?'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.warning, color: Colors.orange),
                    const SizedBox(height: 8),
                    Text(
                      'This will stop selling this product to customers, but you can always add it back later. The product will remain available from wholesalers.',
                      style: TextStyle(color: Colors.orange.shade800, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
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
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              // Close confirmation dialog first
              Navigator.of(context).pop();

              // Delete the product from inventory
              final success = await controller.deleteInventoryItem(item.productId);
              if (!success) {
                // If deletion failed, show error
                Get.snackbar('Error', 'Failed to remove product. Please try again.');
              }
            },
            child: const Text(
              'Remove Product',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showLowStockAlertsDialog() {
    final retailerController = Get.find<RetailerController>();

    Get.dialog(
      AlertDialog(
        title: const Text('Low Stock Alerts'),
        content: SizedBox(
          width: double.maxFinite,
          child: GetBuilder<RetailerController>(
            builder: (controller) {
              if (controller.isLoadingLowStock.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final lowStockItems = controller.lowStockAlerts;
              if (lowStockItems.isEmpty) {
                return const Center(
                  child: Text('No low stock alerts found'),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                itemCount: lowStockItems.length,
                itemBuilder: (context, index) {
                  final item = lowStockItems[index];
                  return ListTile(
                    leading: Obx(() {
                      final productImageUrl = controller.getProductImageUrl(item.productId);

                      if (productImageUrl != null) {
                        // Display actual product image
                        return ProductImageWidget(
                          imageUrl: productImageUrl,
                          fallbackText: item.productName,
                          size: 40,
                        );
                      } else {
                        // Fallback to initial letter avatar
                        return CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          radius: 20,
                          child: Text(
                            item.productName.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }
                    }),
                    title: Text(item.productName),
                    subtitle: Text(
                      'Stock: ${item.currentStock} / Reorder: ${item.reorderLevel} • \$${item.price.toStringAsFixed(2)}'
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _showRestockDialog(context, controller,
                            controller.inventory.firstWhere((inv) => inv.productId == item.productId));
                      },
                      child: const Text('Restock'),
                    ),
                  );
                },
              );
            }),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await retailerController.fetchLowStockAlerts();
            },
            child: const Text('Refresh'),
          ),
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
