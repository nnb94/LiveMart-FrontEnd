import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/wholesaler_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/wholesaler_inventory.dart';
import '../../widgets/image_picker_components.dart';

class WholesalerInventoryScreen extends StatelessWidget {
  const WholesalerInventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final wholesalerController = Get.find<WholesalerController>();

    // Check authentication
    if (!authController.isLoggedIn ||
        authController.role.value != 'wholesaler') {
      return Scaffold(
        backgroundColor: const Color(0xFF0A0E27),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Please login as a wholesaler to continue',
                style: TextStyle(color: Colors.white),
              ),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () => wholesalerController.fetchInventory(),
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
        child: Obx(() {
          if (wholesalerController.isLoadingInventory.value) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
              ),
            );
          }

          if (wholesalerController.inventoryError.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${wholesalerController.inventoryError}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                    ),
                    onPressed: () => wholesalerController.fetchInventory(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (wholesalerController.inventory.isEmpty) {
            return Center(
              child: Text(
                'No products in inventory. Add some products first!',
                style: TextStyle(color: Colors.grey[400]),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: wholesalerController.inventory.length,
            itemBuilder: (context, index) {
              final item = wholesalerController.inventory[index];
              final imageUrl = wholesalerController.getImageUrlForInventoryItem(
                item,
              );
              final stockStatus =
                  item.quantityInStock > item.minimumOrderQuantity * 2
                  ? 'In Stock'
                  : item.quantityInStock >= item.minimumOrderQuantity
                  ? 'Low Stock'
                  : 'Critical';
              final statusColors =
                  item.quantityInStock > item.minimumOrderQuantity * 2
                  ? [const Color(0xFF10B981), const Color(0xFF34D399)]
                  : item.quantityInStock >= item.minimumOrderQuantity
                  ? [const Color(0xFFFF6B35), const Color(0xFFFF8C42)]
                  : [const Color(0xFFEF4444), const Color(0xFFF87171)];

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
                    color: const Color(0xFF3B82F6).withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: SizedBox(
                    width: 50,
                    height: 50,
                    child: ProductImageWidget(
                      imageUrl: imageUrl,
                      fallbackText: item.productName,
                      size: 50,
                    ),
                  ),
                  title: Text(
                    item.productName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        'Stock: ${item.quantityInStock} | Min Order: ${item.minimumOrderQuantity}',
                        style: TextStyle(color: Colors.grey[400], fontSize: 13),
                      ),
                      Text(
                        '₹${item.price.toStringAsFixed(2)} each',
                        style: TextStyle(color: Colors.grey[400], fontSize: 13),
                      ),
                    ],
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: statusColors),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      stockStatus,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  onTap: () => _showInventoryItemDialog(
                    context,
                    wholesalerController,
                    item,
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  void _showInventoryItemDialog(
    BuildContext context,
    WholesalerController controller,
    WholesalerInventoryItem item,
  ) {
    final stockController = TextEditingController(
      text: item.quantityInStock.toString(),
    );
    final minOrderController = TextEditingController(
      text: item.minimumOrderQuantity.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F1729),
        title: Text(
          item.productName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: stockController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Current Stock',
                labelStyle: const TextStyle(color: Color(0xFF3B82F6)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF3B82F6)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF3B82F6),
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: const Color(0xFF0A0E27),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: minOrderController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Minimum Order Quantity',
                labelStyle: const TextStyle(color: Color(0xFF3B82F6)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF3B82F6)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF3B82F6),
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
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              final stock =
                  int.tryParse(stockController.text) ?? item.quantityInStock;
              final minOrder =
                  int.tryParse(minOrderController.text) ??
                  item.minimumOrderQuantity;
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
            child: const Text(
              'Restock',
              style: TextStyle(color: Color(0xFF3B82F6)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  void _showRestockDialog(
    BuildContext context,
    WholesalerController controller,
    WholesalerInventoryItem item,
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
        content: TextField(
          controller: quantityController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Quantity to add',
            labelStyle: const TextStyle(color: Color(0xFF3B82F6)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF3B82F6)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
            ),
            filled: true,
            fillColor: const Color(0xFF0A0E27),
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              final quantity = int.tryParse(quantityController.text) ?? 0;
              final success = await controller.restockProduct(
                item.productId,
                quantity,
              );
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
