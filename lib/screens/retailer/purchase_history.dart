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
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1729),
        elevation: 0,
        title: const Text(
          'Purchase History',
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
              onPressed: () => retailerController.fetchPurchaseOrders(),
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
            _buildPurchaseSummary(retailerController),
            Expanded(
              child: GetBuilder<RetailerController>(
                builder: (controller) {
                  if (controller.isLoadingPurchases.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF17A2B8),
                        ),
                      ),
                    );
                  }

                  if (controller.purchasesError.value.isNotEmpty) {
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
                            controller.purchasesError.value,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => controller.fetchPurchaseOrders(),
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

                  if (controller.purchaseOrders.isEmpty) {
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
                            'No purchase orders yet',
                            style: TextStyle(
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Orders from wholesalers will appear here',
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
                    itemCount: controller.purchaseOrders.length,
                    itemBuilder: (context, index) {
                      final order = controller.purchaseOrders[index];
                      return _buildPurchaseOrderCard(
                        context,
                        controller,
                        order,
                      );
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

  Widget _buildPurchaseSummary(RetailerController controller) {
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
              label: 'Total Orders',
              value: controller.purchaseOrders.length.toString(),
              icon: Icons.shopping_cart,
              gradient: const LinearGradient(
                colors: [Color(0xFF17A2B8), Color(0xFF0FB5D4)],
              ),
            ),
            _SummaryItem(
              label: 'Total Spent',
              value:
                  '\$${controller.getTotalPurchaseValue().toStringAsFixed(2)}',
              icon: Icons.account_balance_wallet,
              gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF34D399)],
              ),
            ),
            _SummaryItem(
              label: 'Wholesalers',
              value: controller.purchaseOrders
                  .map((order) => order.sellerId)
                  .toSet()
                  .length
                  .toString(),
              icon: Icons.business,
              gradient: const LinearGradient(
                colors: [Color(0xFFA855F7), Color(0xFFD946EF)],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchaseOrderCard(
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
              final productImageUrl = controller.getProductImageUrl(
                order.productId,
              );

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
                    order.productInfo?.productName
                            ?.substring(0, 1)
                            .toUpperCase() ??
                        'P',
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
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
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
                  'From: ${order.wholesalerName ?? 'Unknown Supplier'}',
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      'Order #${order.orderId ?? 'N/A'}',
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Qty: ${order.orderDetails?.quantity ?? 0}',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                    const SizedBox(width: 12),
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
                const SizedBox(height: 4),
                Text(
                  'Ordered: ${_formatOrderDate(order.orderDate ?? 'Unknown Date')}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
            trailing: const Icon(Icons.chevron_right, color: Color(0xFF17A2B8)),
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
        backgroundColor: const Color(0xFF0F1729),
        title: Text(
          'Wholesale Order #${order.orderId ?? 'N/A'}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
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
              _detailRow('Wholesaler', order.wholesalerName ?? 'Unknown'),
              _detailRow('Quantity', '${order.orderDetails?.quantity ?? 0}'),
              _detailRow(
                'Unit Price',
                '\$${order.orderDetails?.price?.toStringAsFixed(2) ?? '0.00'}',
              ),
              _detailRow(
                'Total Amount',
                '\$${order.orderDetails?.totalAmount?.toStringAsFixed(2) ?? '0.00'}',
              ),
              _detailRow('Order Type', 'Wholesale Order'),
              _detailRow('Status', order.status ?? 'Unknown'),
              _detailRow(
                'Order Date',
                _formatOrderDate(order.orderDate ?? 'Unknown'),
              ),
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
