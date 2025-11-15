import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/wholesaler_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/wholesaler_inventory.dart';
import '../../models/wholesaler_sale.dart';
import '../../approutes.dart';

class WholesalerDashboard extends StatelessWidget {
  const WholesalerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    // Get wholesaler controller (it will be automatically initialized)
    final wholesalerController = Get.put(WholesalerController());

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
        title: const Text('Wholesaler Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () => _showAnalyticsDialog(context, wholesalerController),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOverviewCards(wholesalerController),
              const SizedBox(height: 24),
              _buildQuickActions(),
              const SizedBox(height: 24),
              _buildInventorySection(wholesalerController),
              const SizedBox(height: 24),
              _buildRecentSalesSection(wholesalerController),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddProductDialog(context, wholesalerController),
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),
    );
  }

  Widget _buildOverviewCards(WholesalerController controller) {
    return Column(
      children: [
        const Text('Business Overview',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Obx(() => _OverviewCard(
                title: 'Total Inventory',
                value: '${controller.inventory.length}',
                icon: Icons.inventory,
                color: Colors.blue,
              )),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Obx(() => _OverviewCard(
                title: 'Low Stock Items',
                value: '${controller.getLowStockCount()}',
                icon: Icons.warning,
                color: Colors.orange,
              )),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Obx(() => _OverviewCard(
                title: 'Total Orders',
                value: '${controller.salesOrders.length}',
                icon: Icons.shopping_cart,
                color: Colors.green,
              )),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Obx(() => _OverviewCard(
                title: 'Inventory Value',
                value: '\$${controller.getTotalInventoryValue().toStringAsFixed(2)}',
                icon: Icons.attach_money,
                color: Colors.purple,
              )),
            ),
          ],
        ),
      ],
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
                onTap: () => Get.toNamed('/wholesaler/inventory'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _ActionCard(
                title: 'Sales Orders',
                icon: Icons.receipt_long,
                onTap: () => Get.toNamed('/wholesaler/sales'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _ActionCard(
                title: 'My Products',
                icon: Icons.category,
                onTap: () => Get.toNamed('/wholesaler/products'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _ActionCard(
                title: 'Analytics',
                icon: Icons.bar_chart,
                onTap: () => Get.toNamed(AppRoutes.wholesalerAnalytics),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInventorySection(WholesalerController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Inventory Overview',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.isLoadingInventory.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.inventory.isEmpty) {
            return const Center(
              child: Text('No products in inventory. Add your first product!'),
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
                  subtitle: Text('Stock: ${item.quantityInStock} | Min Order: ${item.minimumOrderQuantity}'),
                  trailing: Chip(
                    label: Text('\$${item.price.toStringAsFixed(2)}'),
                    backgroundColor: item.quantityInStock < item.minimumOrderQuantity
                        ? Colors.red.shade100
                        : Colors.green.shade100,
                  ),
                  onTap: () => _showInventoryItemDialog(context, controller, item),
                ),
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildRecentSalesSection(WholesalerController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent Sales Orders',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.isLoadingSales.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.salesOrders.isEmpty) {
            return const Center(
              child: Text('No sales orders yet. Orders will appear here when retailers buy from you.'),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.salesOrders.length.clamp(0, 3),
            itemBuilder: (context, index) {
              final order = controller.salesOrders[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text('${order.productInfo.productName} → ${order.retailerName}'),
                  subtitle: Text('Qty: ${order.orderDetails.quantity} | \$${order.orderDetails.totalAmount.toStringAsFixed(2)}'),
                  trailing: Chip(
                    label: Text(order.status.toUpperCase()),
                    backgroundColor: _getStatusColor(order.status),
                  ),
                  onTap: () => _showOrderDialog(context, controller, order),
                ),
              );
            },
          );
        }),
      ],
    );
  }

  void _showAnalyticsDialog(BuildContext context, WholesalerController controller) {
    controller.fetchAnalytics();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sales Analytics'),
        content: Obx(() {
          if (controller.isLoadingAnalytics.value) {
            return const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (controller.analytics.value == null) {
            return const Text('No analytics data available');
          }

          final analytics = controller.analytics.value!;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total Orders: ${analytics.summary.totalOrders}'),
              Text('Total Revenue: \$${analytics.summary.totalRevenue.toStringAsFixed(2)}'),
              Text('Avg Order Value: \$${analytics.summary.averageOrderValue.toStringAsFixed(2)}'),
              Text('Units Sold: ${analytics.summary.totalUnitsSold}'),
              Text('Unique Buyers: ${analytics.summary.uniqueBuyers}'),
            ],
          );
        }),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAddProductDialog(BuildContext context, WholesalerController controller) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    final categoryController = TextEditingController();
    final stockController = TextEditingController();
    final minOrderController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Product'),
        content: SingleChildScrollView(
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
              TextField(
                controller: stockController,
                decoration: const InputDecoration(labelText: 'Initial Stock'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: minOrderController,
                decoration: const InputDecoration(labelText: 'Minimum Order Quantity'),
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
              final success = await controller.addProduct(
                name: nameController.text,
                description: descriptionController.text,
                price: double.tryParse(priceController.text) ?? 0.0,
                category: categoryController.text,
                initialStock: int.tryParse(stockController.text) ?? 0,
                minimumOrderQuantity: int.tryParse(minOrderController.text) ?? 1,
              );
              if (success) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Add Product'),
          ),
        ],
      ),
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
              final stock = int.tryParse(stockController.text);
              final minOrder = int.tryParse(minOrderController.text) ?? 1;
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

  void _showOrderDialog(BuildContext context, WholesalerController controller, WholesalerSale order) {
    final statusOptions = ['pending', 'shipped', 'delivered'];
    String selectedStatus = order.status;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order #${order.orderId}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Product: ${order.productInfo.productName}'),
            Text('Customer: ${order.retailerName}'),
            Text('Quantity: ${order.orderDetails.quantity}'),
            Text('Total: \$${order.orderDetails.totalAmount.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedStatus,
              decoration: const InputDecoration(labelText: 'Order Status'),
              items: statusOptions.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) => selectedStatus = value!,
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
              final success = await controller.updateOrderStatus(order.orderId, selectedStatus);
              if (success) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Update Status'),
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
