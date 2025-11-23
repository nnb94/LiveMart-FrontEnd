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
          'Sales Orders',
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
                colors: [Color(0xFF10B981), Color(0xFF34D399)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () => wholesalerController.fetchSalesOrders(),
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
          if (wholesalerController.isLoadingSales.value) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
              ),
            );
          }

          if (wholesalerController.salesError.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${wholesalerController.salesError}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                    ),
                    onPressed: () => wholesalerController.fetchSalesOrders(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (wholesalerController.salesOrders.isEmpty) {
            return Center(
              child: Text(
                'No sales orders yet. Orders will appear here when retailers buy from you.',
                style: TextStyle(color: Colors.grey[400]),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: wholesalerController.salesOrders.length,
            itemBuilder: (context, index) {
              final order = wholesalerController.salesOrders[index];
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
                    color: const Color(0xFF10B981).withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Obx(() {
                    final productImageUrl = wholesalerController
                        .getProductImageUrlByName(
                          order.productInfo.productName,
                        );
                    return SizedBox(
                      width: 50,
                      height: 50,
                      child: ProductImageWidget(
                        imageUrl: productImageUrl,
                        fallbackText: order.productInfo.productName,
                        size: 50,
                      ),
                    );
                  }),
                  title: Text(
                    '${order.productInfo.productName} → ${order.retailerName}',
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
                        'Order ID: #${order.orderId}',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                      Text(
                        'Quantity: ${order.orderDetails.quantity}',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                      Text(
                        'Total: ₹${order.orderDetails.totalAmount.toStringAsFixed(2)}',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                      Text(
                        'Date: ${_formatOrderDate(order.orderDate)}',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    ],
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _getStatusGradientColors(order.status),
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      order.status.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  onTap: () =>
                      _showOrderDialog(context, wholesalerController, order),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  void _showOrderDialog(
    BuildContext context,
    WholesalerController controller,
    WholesalerSale order,
  ) {
    final statusOptions = ['pending', 'shipped', 'delivered'];
    String selectedStatus = order.status;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F1729),
        title: Text(
          'Order #${order.orderId}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Product: ${order.productInfo.productName}',
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                'Customer: ${order.retailerName}',
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                'Quantity: ${order.orderDetails.quantity}',
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                'Total: ₹${order.orderDetails.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                'Order Date: ${_formatOrderDate(order.orderDate)}',
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedStatus,
                dropdownColor: const Color(0xFF0A0E27),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Order Status',
                  labelStyle: const TextStyle(color: Color(0xFF10B981)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF10B981)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF10B981),
                      width: 2,
                    ),
                  ),
                ),
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
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              final success = await controller.updateOrderStatus(
                order.orderId,
                selectedStatus,
              );
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

  List<Color> _getStatusGradientColors(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return [const Color(0xFFFF6B35), const Color(0xFFFF8C42)];
      case 'shipped':
        return [const Color(0xFF3B82F6), const Color(0xFF60A5FA)];
      case 'delivered':
        return [const Color(0xFF10B981), const Color(0xFF34D399)];
      case 'cancelled':
        return [const Color(0xFFEF4444), const Color(0xFFF87171)];
      default:
        return [Colors.grey.shade600, Colors.grey.shade400];
    }
  }
}
