import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/retailer_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/image_picker_components.dart';

class RetailerPurchaseHistoryScreen extends StatelessWidget {
  const RetailerPurchaseHistoryScreen({super.key});

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
        title: const Text('Purchase History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => retailerController.fetchPurchaseOrders(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildPurchaseSummary(retailerController),
          Expanded(
            child: GetBuilder<RetailerController>(
              builder: (controller) {
                if (controller.isLoadingPurchases.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.purchasesError.value.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(controller.purchasesError.value),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => controller.fetchPurchaseOrders(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (controller.purchaseOrders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'No purchase orders yet',
                          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                        Text(
                          'Orders from wholesalers will appear here',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: controller.purchaseOrders.length,
                  itemBuilder: (context, index) {
                    final order = controller.purchaseOrders[index];
                    return _buildPurchaseOrderCard(context, controller, order);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseSummary(RetailerController controller) {
    return GetBuilder<RetailerController>(
      builder: (controller) => Container(
        padding: const EdgeInsets.all(16),
        color: Colors.blue.shade50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _SummaryItem(
              label: 'Total Orders',
              value: controller.purchaseOrders.length.toString(),
              icon: Icons.shopping_cart,
              color: Colors.blue,
            ),
            _SummaryItem(
              label: 'Total Spent',
              value: '\$${controller.getTotalPurchaseValue().toStringAsFixed(2)}',
              icon: Icons.account_balance_wallet,
              color: Colors.green,
            ),
            _SummaryItem(
              label: 'Wholesalers',
              value: controller.purchaseOrders
                  .map((order) => order.sellerId)
                  .toSet()
                  .length
                  .toString(),
              icon: Icons.business,
              color: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchaseOrderCard(BuildContext context, RetailerController controller, dynamic order) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Obx(() {
              final productImageUrl = controller.getProductImageUrl(order.productId);

              if (productImageUrl != null) {
                // Display actual product image
                return ProductImageWidget(
                  imageUrl: productImageUrl,
                  fallbackText: order.productInfo?.productName ?? 'Product',
                  size: 50,
                );
              } else {
                // Fallback to initial letter avatar
                return CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    order.productInfo?.productName?.substring(0, 1).toUpperCase() ?? 'P',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }
            }),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    order.productInfo?.productName ?? 'Unknown Product',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.status?.toUpperCase() ?? 'UNKNOWN',
                    style: TextStyle(
                      color: _getStatusColor(order.status),
                      fontSize: 10,
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
                  'From: ${order.wholesalerName ?? 'Unknown Supplier'}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      'Order #${order.orderId ?? 'N/A'}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Qty: ${order.orderDetails?.quantity ?? 0}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '\$${order.orderDetails?.totalAmount?.toStringAsFixed(2) ?? '0.00'}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Ordered: ${_formatOrderDate(order.orderDate ?? 'Unknown Date')}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showOrderDetailsDialog(context, order),
          ),
        ],
      ),
    );
  }

  void _showOrderDetailsDialog(BuildContext context, dynamic order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Wholesale Order #${order.orderId ?? 'N/A'}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('Product', order.productInfo?.productName ?? 'Unknown'),
              _detailRow('Wholesaler', order.wholesalerName ?? 'Unknown'),
              _detailRow('Quantity', '${order.orderDetails?.quantity ?? 0}'),
              _detailRow('Unit Price', '\$${order.orderDetails?.price?.toStringAsFixed(2) ?? '0.00'}'),
              _detailRow('Total Amount', '\$${order.orderDetails?.totalAmount?.toStringAsFixed(2) ?? '0.00'}'),
              _detailRow('Order Type', 'Wholesale Order'),
              _detailRow('Status', order.status ?? 'Unknown'),
              _detailRow('Order Date', _formatOrderDate(order.orderDate ?? 'Unknown')),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'shipped':
        return Colors.indigo;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatOrderDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString).toLocal();
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString; // Fallback to original if parsing fails
    }
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
