import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/retailer_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../approutes.dart';
import '../../models/retailer_inventory.dart';

class RetailerDashboard extends StatelessWidget {
  const RetailerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    // Get retailer controller (it will be automatically initialized)
    final retailerController = Get.put(RetailerController());

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
        title: const Text('Retailer Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () => Get.toNamed(AppRoutes.retailerAnalytics),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOverviewCards(retailerController),
              const SizedBox(height: 24),
              _buildQuickActions(),
              const SizedBox(height: 24),
              _buildInventorySection(retailerController),
              const SizedBox(height: 24),
              _buildRecentPurchaseOrders(retailerController),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showWholesaleOrdering(context, retailerController),
        icon: const Icon(Icons.shopping_cart),
        label: const Text('Order from Wholesalers'),
      ),
    );
  }

  Widget _buildOverviewCards(RetailerController controller) {
    return GetBuilder<RetailerController>(
      builder: (controller) => Column(
        children: [
          const Text('Business Overview',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _OverviewCard(
                  title: 'Total Inventory',
                  value: '${controller.inventory.length}',
                  icon: Icons.inventory,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _OverviewCard(
                  title: 'Low Stock Items',
                  value: '${controller.getLowStockCount()}',
                  icon: Icons.warning,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _OverviewCard(
                  title: 'Purchase Orders',
                  value: '${controller.purchaseOrders.length}',
                  icon: Icons.local_shipping,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _OverviewCard(
                  title: 'Inventory Value',
                  value: '\$${controller.getTotalInventoryValue().toStringAsFixed(2)}',
                  icon: Icons.attach_money,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Actions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _ActionCard(
                title: 'Manage Inventory',
                icon: Icons.inventory_2,
                onTap: () => Get.toNamed(AppRoutes.retailerInventory),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _ActionCard(
                title: 'Purchase History',
                icon: Icons.history,
                onTap: () => Get.toNamed(AppRoutes.retailerPurchasing),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _ActionCard(
                title: 'Sales to Customers',
                icon: Icons.point_of_sale,
                onTap: () => Get.toNamed(AppRoutes.retailerSales),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _ActionCard(
                title: 'Analytics',
                icon: Icons.bar_chart,
                onTap: () => Get.toNamed(AppRoutes.retailerAnalytics),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInventorySection(RetailerController controller) {
    return GetBuilder<RetailerController>(
      builder: (controller) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Inventory Overview',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          () {
            if (controller.isLoadingInventory.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.inventory.isEmpty) {
              return const Center(
                child: Text('No products in inventory. Order from wholesalers first!'),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.inventory.length.clamp(0, 3), // Show first 3 items
              itemBuilder: (context, index) {
                final item = controller.inventory[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(item.productName[0].toUpperCase()),
                    ),
                    title: Text(item.productName),
                    subtitle: Text('Stock: ${item.quantityInStock} | Reorder: ${item.reorderLevel}'),
                    trailing: Chip(
                      label: Text(item.needsRestock ? 'Low Stock' : 'In Stock'),
                      backgroundColor: item.needsRestock
                          ? Colors.red.shade100
                          : Colors.green.shade100,
                    ),
                    onTap: () => _showInventoryItemDialog(context, controller, item),
                  ),
                );
              },
            );
          }(),
        ],
      ),
    );
  }

  Widget _buildRecentPurchaseOrders(RetailerController controller) {
    return GetBuilder<RetailerController>(
      builder: (controller) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recent Purchase Orders',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          () {
            if (controller.isLoadingPurchases.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.purchaseOrders.isEmpty) {
              return const Center(
                child: Text('No purchase orders yet. Start ordering from wholesalers!'),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.purchaseOrders.length.clamp(0, 3),
              itemBuilder: (context, index) {
                final order = controller.purchaseOrders[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(order.wholesalerName[0].toUpperCase()),
                    ),
                    title: Text('${order.productInfo.productName} → ${order.wholesalerName}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Order ID: #${order.orderId}'),
                        Text('Quantity: ${order.orderDetails.quantity} | \$${order.orderDetails.totalAmount.toStringAsFixed(2)}'),
                        Text('Date: ${order.orderDate}'),
                      ],
                    ),
                    trailing: Chip(
                      label: Text(order.status.toUpperCase()),
                      backgroundColor: _getStatusColor(order.status),
                    ),
                  ),
                );
              },
            );
          }(),
        ],
      ),
    );
  }

  void _showWholesaleOrdering(BuildContext context, RetailerController controller) {
    Get.toNamed(AppRoutes.retailerPurchasing);
  }

  void _showInventoryItemDialog(BuildContext context, RetailerController controller, RetailerInventoryItem item) {
    final stockController = TextEditingController(text: item.quantityInStock.toString());
    final reorderController = TextEditingController(text: item.reorderLevel.toString());

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
              controller: reorderController,
              decoration: const InputDecoration(labelText: 'Reorder Level'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              final stock = int.tryParse(stockController.text) ?? item.quantityInStock;
              final reorder = int.tryParse(reorderController.text) ?? item.reorderLevel;
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

  void _showRestockDialog(BuildContext context, RetailerController controller, RetailerInventoryItem item) {
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange.shade100;
      case 'shipped':
        return Colors.blue.shade100;
      case 'delivered':
        return Colors.green.shade100;
      case 'cancelled':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade100;
    }
  }
}

class _OverviewCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _OverviewCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, size: 32, color: Colors.blue),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}
