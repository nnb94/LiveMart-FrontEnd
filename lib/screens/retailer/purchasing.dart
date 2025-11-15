import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/retailer_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/retailer_inventory.dart';
import '../../models/product.dart';

class RetailerPurchasingScreen extends StatelessWidget {
  const RetailerPurchasingScreen({super.key});

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
        title: const Text('Wholesale Purchasing'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => retailerController.fetchWholesaleProducts(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(
            child: GetBuilder<RetailerController>(
              builder: (controller) {
                if (controller.isLoadingWholesaleProducts.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.wholesaleProductsError.value.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(controller.wholesaleProductsError.value),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => controller.fetchWholesaleProducts(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (controller.availableWholesaleProducts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'No products available',
                          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                        Text(
                          'Wholesalers haven\'t added products yet',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: controller.availableWholesaleProducts.length,
                  itemBuilder: (context, index) {
                    final item = controller.availableWholesaleProducts[index];
                    return _buildWholesaleProductCard(context, controller, item);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _buildCartFab(retailerController),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blue.shade50,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                // TODO: Implement search functionality
              },
            ),
          ),
          const SizedBox(width: 12),
          PopupMenuButton<String>(
            onSelected: (value) {
              // TODO: Implement sorting
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'name', child: Text('Sort by Name')),
              const PopupMenuItem(value: 'price', child: Text('Sort by Price')),
              const PopupMenuItem(value: 'seller', child: Text('Sort by Seller')),
            ],
            icon: const Icon(Icons.sort),
            tooltip: 'Sort products',
          ),
        ],
      ),
    );
  }

  Widget _buildWholesaleProductCard(BuildContext context, RetailerController controller, AvailableWholesaleProduct item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue.shade100,
              child: Text(
                item.product.name[0].toUpperCase(),
                style: TextStyle(
                  color: Colors.blue.shade800,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    item.product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Min: ${item.minimumOrderQuantity}',
                    style: TextStyle(
                      color: Colors.blue.shade800,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  'Seller: ${item.sellerName}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  '\$${item.product.price.toStringAsFixed(2)} • Stock: ${item.availableStock} units',
                  style: const TextStyle(fontSize: 14),
                ),
                if (item.product.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.product.description,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Category: ${item.product.category}',
                        style: TextStyle(color: Colors.grey[700], fontSize: 12),
                      ),
                      Text(
                        'Minimum Order: ${item.minimumOrderQuantity} units',
                        style: TextStyle(color: Colors.grey[700], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _showBulkOrderDialog(context, controller, item),
                  child: const Text('Place Bulk Order'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showBulkOrderDialog(BuildContext context, RetailerController controller, AvailableWholesaleProduct item) {
    final quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order ${item.product.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Seller: ${item.sellerName}'),
            Text('Price: \$${item.product.price.toStringAsFixed(2)} per unit'),
            Text('Available Stock: ${item.availableStock} units'),
            Text('Minimum Order: ${item.minimumOrderQuantity} units'),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              decoration: InputDecoration(
                labelText: 'Quantity to order',
                hintText: 'Min: ${item.minimumOrderQuantity}',
              ),
              keyboardType: TextInputType.number,
              autofocus: true,
            ),
          ],
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

              if (quantity < item.minimumOrderQuantity) {
                Get.snackbar(
                  'Error',
                  'Minimum order quantity is ${item.minimumOrderQuantity} units'
                );
                return;
              }

              if (quantity > item.availableStock) {
                Get.snackbar(
                  'Error',
                  'Only ${item.availableStock} units available in stock'
                );
                return;
              }

              // Place the order
              final success = await controller.placeWholesaleOrder([
                {
                  'product_id': item.product.id,
                  'quantity': quantity,
                  'seller_id': item.sellerId,
                }
              ]);

              if (success) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Place Order'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartFab(RetailerController controller) {
    // TODO: Add cart functionality later
    // For now, just show refresh button
    return FloatingActionButton(
      onPressed: () => controller.fetchWholesaleProducts(),
      child: const Icon(Icons.refresh),
    );
  }
}
