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
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1729),
        elevation: 0,
        title: const Text(
          'Sales to Customers',
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
              onPressed: () => retailerController.fetchSalesOrders(),
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
            _buildSalesSummary(retailerController),
            Expanded(
              child: GetBuilder<RetailerController>(
                builder: (controller) {
                  if (controller.isLoadingSales.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF17A2B8),
                        ),
                      ),
                    );
                  }

                  if (controller.salesError.value.isNotEmpty) {
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
                            controller.salesError.value,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => controller.fetchSalesOrders(),
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

                  if (controller.salesOrders.isEmpty) {
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
                              Icons.receipt_long_outlined,
                              size: 80,
                              color: Color(0xFF17A2B8),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'No sales yet',
                            style: TextStyle(
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Customer orders will appear here',
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
      ),
    );
  }

  Widget _buildSalesSummary(RetailerController controller) {
    return GetBuilder<RetailerController>(
      builder: (controller) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0F1729),
              const Color(0xFF1A2332).withOpacity(0.8),
            ],
          ),
          border: Border.all(
            color: const Color(0xFF17A2B8).withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF17A2B8).withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _SummaryItem(
              label: 'Total Sales',
              value: controller.salesOrders.length.toString(),
              icon: Icons.receipt,
              gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF34D399)],
              ),
            ),
            _SummaryItem(
              label: 'Revenue',
              value: '\$${controller.getTotalSalesValue().toStringAsFixed(2)}',
              icon: Icons.attach_money,
              gradient: const LinearGradient(
                colors: [Color(0xFF17A2B8), Color(0xFF0FB5D4)],
              ),
            ),
            _SummaryItem(
              label: 'Customers',
              value: controller.salesOrders
                  .map((order) => order.buyerId)
                  .toSet()
                  .length
                  .toString(),
              icon: Icons.people,
              gradient: const LinearGradient(
                colors: [Color(0xFFA855F7), Color(0xFFD946EF)],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaleOrderCard(
    BuildContext context,
    RetailerController controller,
    dynamic order,
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
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Obx(() {
              final productImageUrl = controller.getProductImageUrlByName(
                order.productInfo?.productName,
              );
              return ProductImageWidget(
                imageUrl: productImageUrl,
                fallbackText: order.productInfo?.productName ?? 'Product',
                size: 50,
              );
            }),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    order.productInfo?.productName ?? 'Unknown Product',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    gradient: _getStatusGradient(order.status),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: _getStatusColor(order.status).withOpacity(0.3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Text(
                    order.status?.toUpperCase() ?? 'UNKNOWN',
                    style: const TextStyle(
                      color: Colors.white,
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
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    Text(
                      'Order #${order.orderId ?? 'N/A'}',
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Qty: ${order.orderDetails?.quantity ?? 0}',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                    Text(
                      '\$${order.orderDetails?.totalAmount?.toStringAsFixed(2) ?? '0.00'}',
                      style: const TextStyle(
                        color: Color(0xFF17A2B8),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (order.offlineOrder == true) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF6B35).withOpacity(0.3),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: const Text(
                      'OFFLINE ORDER',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            trailing: const Icon(Icons.chevron_right, color: Color(0xFF17A2B8)),
            onTap: () => _showOrderDetailsDialog(context, controller, order),
          ),
          if (order.deliveryDetails != null &&
              order.deliveryDetails!.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF1A2332).withOpacity(0.3),
                    const Color(0xFF0F1729).withOpacity(0.2),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 16,
                    color: Color(0xFF17A2B8),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Delivery: ${order.deliveryDetails}',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showOrderDetailsDialog(
    BuildContext context,
    RetailerController controller,
    dynamic order,
  ) {
    final statusOptions = ['pending', 'shipped', 'delivered', 'cancelled'];
    String selectedStatus = order.status ?? 'pending';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF0F1729),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: const Color(0xFF17A2B8).withOpacity(0.3)),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF17A2B8), Color(0xFF0FB5D4)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.receipt_long,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Order #${order.orderId ?? 'N/A'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _detailRow(
                  'Product',
                  order.productInfo?.productName ?? 'Unknown',
                ),
                _detailRow('Customer', order.customerName ?? 'Unknown'),
                _detailRow('Quantity', '${order.orderDetails?.quantity ?? 0}'),
                _detailRow(
                  'Unit Price',
                  '\$${order.orderDetails?.price?.toStringAsFixed(2) ?? '0.00'}',
                ),
                _detailRow(
                  'Total Amount',
                  '\$${order.orderDetails?.totalAmount?.toStringAsFixed(2) ?? '0.00'}',
                ),
                _detailRow(
                  'Order Date',
                  _formatOrderDate(order.orderDate ?? ''),
                ),
                if (order.offlineOrder == true)
                  _detailRow('Order Type', 'Offline Order'),
                if (order.deliveryDetails != null &&
                    order.deliveryDetails!.isNotEmpty)
                  _detailRow('Delivery Address', order.deliveryDetails!),
                if (order.expectedDeliveryDate != null &&
                    order.expectedDeliveryDate!.isNotEmpty)
                  _detailRow(
                    'Expected Delivery',
                    _formatOrderDate(order.expectedDeliveryDate!),
                  ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF1A2332).withOpacity(0.5),
                        const Color(0xFF0F1729).withOpacity(0.3),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF17A2B8).withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Update Order Status',
                        style: TextStyle(
                          color: Color(0xFF17A2B8),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF0F1729),
                              const Color(0xFF1A2332).withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFF17A2B8).withOpacity(0.3),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedStatus,
                            isExpanded: true,
                            dropdownColor: const Color(0xFF0F1729),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: Color(0xFF17A2B8),
                            ),
                            items: statusOptions.map((status) {
                              return DropdownMenuItem(
                                value: status,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _getStatusColor(status),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      status.toUpperCase(),
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (newStatus) {
                              if (newStatus != null) {
                                setState(() {
                                  selectedStatus = newStatus;
                                });
                              }
                            },
                          ),
                        ),
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
              child: Text('Close', style: TextStyle(color: Colors.grey[400])),
            ),
            if (selectedStatus != order.status)
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF17A2B8), Color(0xFF0FB5D4)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    final success = await controller.updateSalesOrderStatus(
                      order.orderId,
                      selectedStatus,
                    );
                    if (success) {
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Update Status',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatOrderDate(String dateString) {
    if (dateString.isEmpty) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          if (difference.inMinutes == 0) {
            return 'Just now';
          }
          return '${difference.inMinutes} minute${difference.inMinutes != 1 ? 's' : ''} ago';
        }
        return '${difference.inHours} hour${difference.inHours != 1 ? 's' : ''} ago';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return '${date.day.toString().padLeft(2, '0')}/' +
            '${date.month.toString().padLeft(2, '0')}/' +
            '${date.year}';
      }
    } catch (e) {
      return dateString;
    }
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: Color(0xFF17A2B8),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFFF6B35);
      case 'confirmed':
        return const Color(0xFF17A2B8);
      case 'shipped':
        return const Color(0xFF3B82F6);
      case 'delivered':
        return const Color(0xFF10B981);
      case 'cancelled':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  LinearGradient _getStatusGradient(String? status) {
    if (status == null)
      return const LinearGradient(colors: [Colors.grey, Colors.grey]);
    switch (status.toLowerCase()) {
      case 'pending':
        return const LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
        );
      case 'confirmed':
        return const LinearGradient(
          colors: [Color(0xFF17A2B8), Color(0xFF0FB5D4)],
        );
      case 'shipped':
        return const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
        );
      case 'delivered':
        return const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF34D399)],
        );
      case 'cancelled':
        return const LinearGradient(
          colors: [Color(0xFFEF4444), Color(0xFFF87171)],
        );
      default:
        return const LinearGradient(colors: [Colors.grey, Colors.grey]);
    }
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final LinearGradient gradient;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: gradient.colors.first.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[400])),
      ],
    );
  }
}
