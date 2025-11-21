import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/wholesaler_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/wholesaler_sale.dart';
import '../../widgets/image_picker_components.dart';

class WholesalerSalesScreen extends StatelessWidget {
  const WholesalerSalesScreen({super.key});

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
        title: const Text('Sales Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => wholesalerController.fetchSalesOrders(),
          ),
        ],
      ),
      body: Obx(() {
        if (wholesalerController.isLoadingSales.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (wholesalerController.salesError.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${wholesalerController.salesError}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => wholesalerController.fetchSalesOrders(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (wholesalerController.salesOrders.isEmpty) {
          return const Center(
            child: Text('No sales orders yet. Orders will appear here when retailers buy from you.'),
          );
        }

        return ListView.builder(
          itemCount: wholesalerController.salesOrders.length,
          itemBuilder: (context, index) {
            final order = wholesalerController.salesOrders[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  child: Obx(() {
                    final productImageUrl = wholesalerController.getProductImageUrlByName(order.productInfo.productName);
                    return ProductImageWidget(
                      imageUrl: productImageUrl,
                      fallbackText: order.productInfo.productName,
                      size: 50,
                    );
                  }),
                ),
                title: Text('${order.productInfo.productName} → ${order.retailerName}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Order ID: #${order.orderId}'),
                    Text('Quantity: ${order.orderDetails.quantity}'),
                    Text('Total: \$${order.orderDetails.totalAmount.toStringAsFixed(2)}'),
                    Text('Date: ${_formatOrderDate(order.orderDate)}'),
                  ],
                ),
                trailing: Chip(
                  label: Text(order.status.toUpperCase()),
                  backgroundColor: _getStatusColor(order.status),
                ),
                onTap: () => _showOrderDialog(context, wholesalerController, order),
              ),
            );
          },
        );
      }),
    );
  }

  void _showOrderDialog(BuildContext context, WholesalerController controller, WholesalerSale order) {
    final statusOptions = ['pending', 'shipped', 'delivered'];
    String selectedStatus = order.status;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order #${order.orderId}'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Product: ${order.productInfo.productName}'),
              Text('Customer: ${order.retailerName}'),
              Text('Quantity: ${order.orderDetails.quantity}'),
              Text('Total: \$${order.orderDetails.totalAmount.toStringAsFixed(2)}'),
              Text('Order Date: ${_formatOrderDate(order.orderDate)}'),
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

  String _formatOrderDate(String dateString) {
    try {
      // Try parsing as ISO 8601 format first (common for APIs)
      DateTime dateTime = DateTime.parse(dateString);

      // Format the date nicely
      return '${dateTime.day.toString().padLeft(2, '0')}/'
             '${dateTime.month.toString().padLeft(2, '0')}/'
             '${dateTime.year} '
             '${dateTime.hour.toString().padLeft(2, '0')}:'
             '${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      // If parsing fails, return the original string
      return dateString;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
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
