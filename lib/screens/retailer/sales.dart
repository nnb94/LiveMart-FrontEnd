import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/retailer_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/image_picker_components.dart';

class RetailerSalesScreen extends StatelessWidget {
  const RetailerSalesScreen({super.key});

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
        title: const Text('Sales to Customers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => retailerController.fetchSalesOrders(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSalesSummary(retailerController),
          Expanded(
            child: GetBuilder<RetailerController>(
              builder: (controller) {
                if (controller.isLoadingSales.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.salesError.value.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(controller.salesError.value),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => controller.fetchSalesOrders(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (controller.salesOrders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'No sales yet',
                          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                        Text(
                          'Customer orders will appear here',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: controller.salesOrders.length,
                  itemBuilder: (context, index) {
                    final order = controller.salesOrders[index];
                    return _buildSaleOrderCard(context, controller, order);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesSummary(RetailerController controller) {
    return GetBuilder<RetailerController>(
      builder: (controller) => Container(
        padding: const EdgeInsets.all(16),
        color: Colors.green.shade50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _SummaryItem(
              label: 'Total Sales',
              value: controller.salesOrders.length.toString(),
              icon: Icons.receipt,
              color: Colors.green,
            ),
            _SummaryItem(
              label: 'Revenue',
              value: '\$${controller.getTotalSalesValue().toStringAsFixed(2)}',
              icon: Icons.attach_money,
              color: Colors.blue,
            ),
            _SummaryItem(
              label: 'Customers',
              value: controller.salesOrders
                  .map((order) => order.buyerId)
                  .toSet()
                  .length
                  .toString(),
              icon: Icons.people,
              color: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaleOrderCard(BuildContext context, RetailerController controller, dynamic order) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: ProductImageWidget(
              imageUrl: order.productInfo?.imageUrl,
              fallbackText: order.productInfo?.productName ?? 'Product',
              size: 50,
            ),
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
                  'Customer: ${order.customerName ?? 'Unknown'}',
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
                if (order.offlineOrder == true) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'OFFLINE ORDER',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showOrderDetailsDialog(context, controller, order),
          ),
          if (order.deliveryDetails != null && order.deliveryDetails!.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Delivery: ${order.deliveryDetails}',
                      style: TextStyle(color: Colors.grey[700], fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showOrderDetailsDialog(BuildContext context, RetailerController controller, dynamic order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order #${order.orderId ?? 'N/A'}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('Product', order.productInfo?.productName ?? 'Unknown'),
              _detailRow('Customer', order.customerName ?? 'Unknown'),
              _detailRow('Quantity', '${order.orderDetails?.quantity ?? 0}'),
              _detailRow('Unit Price', '\$${order.orderDetails?.price?.toStringAsFixed(2) ?? '0.00'}'),
              _detailRow('Total Amount', '\$${order.orderDetails?.totalAmount?.toStringAsFixed(2) ?? '0.00'}'),
              _detailRow('Order Date', order.orderDate ?? 'Unknown'),
              _detailRow('Status', order.status ?? 'Unknown'),
              if (order.offlineOrder == true)
                _detailRow('Order Type', 'Offline Order'),
              if (order.deliveryDetails != null && order.deliveryDetails!.isNotEmpty)
                _detailRow('Delivery Address', order.deliveryDetails!),
              if (order.expectedDeliveryDate != null && order.expectedDeliveryDate!.isNotEmpty)
                _detailRow('Expected Delivery', order.expectedDeliveryDate!),
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
