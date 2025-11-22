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
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1729),
        elevation: 0,
        title: const Text(
          'Inventory Management',
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
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF17A2B8), Color(0xFF0FB5D4)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () => retailerController.fetchInventory(),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0E27),
              Color(0xFF0F1729),
              Color(0xFF1A2332),
              Color(0xFF0F1729),
              Color(0xFF050A1A),
            ],
            stops: [0.1, 0.3, 0.6, 0.8, 1.0],
          ),
        ),
        child: Column(
          children: [
            // Low stock alerts banner
            _buildLowStockAlertsBanner(retailerController),

            // Inventory list
            Expanded(
              child: GetBuilder<RetailerController>(
                builder: (controller) {
                  if (controller.isLoadingInventory.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF17A2B8),
                        ),
                      ),
                    );
                  }

                  if (controller.inventoryError.value.isNotEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Color(0xFFEF4444),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            controller.inventoryError.value,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => controller.fetchInventory(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF17A2B8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
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
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF17A2B8).withOpacity(0.2),
                                  const Color(0xFF0FB5D4).withOpacity(0.1),
                                ],
                              ),
                            ),
                            child: const Icon(
                              Icons.inventory_2_outlined,
                              size: 80,
                              color: Color(0xFF17A2B8),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'No products in inventory',
                            style: TextStyle(
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Order from wholesalers first',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed('/retailer/purchasing'),
        backgroundColor: const Color(0xFF17A2B8),
        elevation: 8,
        icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
        label: const Text(
          'Order Stock',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildLowStockAlertsBanner(RetailerController controller) {
    return GetBuilder<RetailerController>(
      builder: (controller) => controller.getLowStockCount() == 0
          ? const SizedBox.shrink()
          : Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF6B35).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${controller.getLowStockCount()} products are low on stock',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _showLowStockAlertsDialog(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFFF6B35),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('View'),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInventoryItemCard(
    BuildContext context,
    RetailerController controller,
    RetailerInventoryItem item,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
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
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Price: \$${item.price.toStringAsFixed(2)}',
              style: TextStyle(color: Colors.grey[300]),
            ),
            const SizedBox(height: 2),
            Text(
              'Stock: ${item.quantityInStock} units',
              style: TextStyle(color: Colors.grey[400]),
            ),
            Text(
              'Reorder Level: ${item.reorderLevel} units',
              style: TextStyle(color: Colors.grey[400]),
            ),
            if (item.needsRestock) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEF4444), Color(0xFFF87171)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'LOW STOCK',
                  style: TextStyle(
                    color: Colors.white,
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
                  Text(
                    'Remove Product',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateInventoryDialog(
    BuildContext context,
    RetailerController controller,
    RetailerInventoryItem item,
  ) {
    final stockController = TextEditingController(
      text: item.quantityInStock.toString(),
    );
    final reorderController = TextEditingController(
      text: item.reorderLevel.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F1729),
        title: Text(
          'Update ${item.productName}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IgnorePointer(
                ignoring: true,
                child: TextField(
                  controller: TextEditingController(
                    text: item.productId.toString(),
                  ),
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
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: stockController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Current Stock',
                  labelStyle: const TextStyle(color: Color(0xFF17A2B8)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF17A2B8)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF17A2B8),
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF0A0E27),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reorderController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Reorder Level',
                  labelStyle: const TextStyle(color: Color(0xFF17A2B8)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF17A2B8)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF17A2B8),
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF0A0E27),
                ),
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

  void _showRestockDialog(
    BuildContext context,
    RetailerController controller,
    RetailerInventoryItem item,
  ) {
    final quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F1729),
        title: Text(
          'Restock ${item.productName}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IgnorePointer(
                ignoring: true,
                child: TextField(
                  controller: TextEditingController(
                    text: item.productId.toString(),
                  ),
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
                    fontWeight: FontWeight.w500,
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

              final success = await controller.restockProduct(
                item.productId,
                quantity,
              );
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

  void _showDeleteConfirmationDialog(
    BuildContext context,
    RetailerController controller,
    RetailerInventoryItem item,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F1729),
        title: const Text(
          'Remove Product from Inventory',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IgnorePointer(
                ignoring: true,
                child: TextField(
                  controller: TextEditingController(
                    text: item.productId.toString(),
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Product ID',
                    filled: true,
                    fillColor: Color(0xFFF5F5F5),
                  ),
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Are you sure you want to remove "${item.productName}" from your inventory?',
              ),
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
                      style: TextStyle(
                        color: Colors.orange.shade800,
                        fontSize: 12,
                      ),
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
              final success = await controller.deleteInventoryItem(
                item.productId,
              );
              if (!success) {
                // If deletion failed, show error
                Get.snackbar(
                  'Error',
                  'Failed to remove product. Please try again.',
                );
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
        backgroundColor: const Color(0xFF0F1729),
        title: const Text(
          'Low Stock Alerts',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: GetBuilder<RetailerController>(
            builder: (controller) {
              if (controller.isLoadingLowStock.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final lowStockItems = controller.lowStockAlerts;
              if (lowStockItems.isEmpty) {
                return const Center(child: Text('No low stock alerts found'));
              }

              return ListView.builder(
                shrinkWrap: true,
                itemCount: lowStockItems.length,
                itemBuilder: (context, index) {
                  final item = lowStockItems[index];
                  return ListTile(
                    leading: Obx(() {
                      final productImageUrl = controller.getProductImageUrl(
                        item.productId,
                      );

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
                      'Stock: ${item.currentStock} / Reorder: ${item.reorderLevel} • \$${item.price.toStringAsFixed(2)}',
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _showRestockDialog(
                          context,
                          controller,
                          controller.inventory.firstWhere(
                            (inv) => inv.productId == item.productId,
                          ),
                        );
                      },
                      child: const Text('Restock'),
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await retailerController.fetchLowStockAlerts();
            },
            child: const Text('Refresh'),
          ),
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
      ),
    );
  }
}
