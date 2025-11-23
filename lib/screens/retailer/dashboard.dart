import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_mart_app/controllers/wishlist_controller.dart';
import '../../controllers/retailer_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../approutes.dart';
import '../../models/retailer_inventory.dart';
import '../../widgets/image_picker_components.dart';

class RetailerDashboard extends StatelessWidget {
  const RetailerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    // Get existing retailer controller or create new one
    final retailerController = Get.isRegistered<RetailerController>()
        ? Get.find<RetailerController>() // Use existing instance with data
        : Get.put(RetailerController()); // Create new if none exists

    // Ensure data is always loaded when building the dashboard (dashboard is authoritative)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authController.role.value == 'retailer') {
        retailerController.loadInitialData(); // Always load fresh data
      }
    });

    // Check authentication
    if (!authController.isLoggedIn || authController.role.value != 'retailer') {
      return Scaffold(
        backgroundColor: const Color(0xFF0A0E27),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Please login as a retailer to continue',
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
          'Retailer Dashboard',
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
              icon: const Icon(Icons.analytics, color: Colors.white),
              onPressed: () => Get.toNamed(AppRoutes.retailerAnalytics),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEF4444), Color(0xFFF87171)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () {
                authController.clearUser();
                Get.offAllNamed('/login');
              },
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
        child: SingleChildScrollView(
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showWholesaleOrdering(context, retailerController),
        backgroundColor: const Color(0xFF17A2B8),
        elevation: 8,
        icon: const Icon(Icons.shopping_cart, color: Colors.white),
        label: const Text(
          'Order from Wholesalers',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildOverviewCards(RetailerController controller) {
    return GetBuilder<RetailerController>(
      builder: (controller) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4.0, bottom: 16.0),
            child: Text(
              'Business Overview',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _OverviewCard(
                  title: 'Total Inventory',
                  value: '${controller.inventory.length}',
                  icon: Icons.inventory,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF17A2B8), Color(0xFF0FB5D4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _OverviewCard(
                  title: 'Low Stock Items',
                  value: '${controller.getLowStockCount()}',
                  icon: Icons.warning,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
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
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF34D399)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _OverviewCard(
                  title: 'Inventory Value',
                  value:
                      '\$${controller.getTotalInventoryValue().toStringAsFixed(2)}',
                  icon: Icons.attach_money,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFA855F7), Color(0xFFD946EF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
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
        const Padding(
          padding: EdgeInsets.only(left: 4.0, bottom: 16.0),
          child: Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _ActionCard(
                title: 'Manage Inventory',
                icon: Icons.inventory_2,
                onTap: () => Get.toNamed(AppRoutes.retailerInventory),
                color: const Color(0xFF17A2B8),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _ActionCard(
                title: 'Purchase History',
                icon: Icons.history,
                onTap: () => Get.toNamed(AppRoutes.retailerPurchaseHistory),
                color: const Color(0xFF0FB5D4),
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
                color: const Color(0xFF10B981),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _ActionCard(
                title: 'Analytics',
                icon: Icons.bar_chart,
                onTap: () => Get.toNamed(AppRoutes.retailerAnalytics),
                color: const Color(0xFFA855F7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _ActionCard(
                title: 'Product Reviews',
                icon: Icons.rate_review,
                onTap: () => Get.toNamed('/retailer/reviews'),
                color: const Color(0xFFFF6B35),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _ActionCard(
                title: 'Wishlist',
                icon: Icons.favorite,
                onTap: () => Get.toNamed(AppRoutes.retailerWishlist),
                color: const Color.fromARGB(255, 247, 85, 85),
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
          const Padding(
            padding: EdgeInsets.only(left: 4.0, bottom: 16.0),
            child: Text(
              'Inventory Overview',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
          () {
            if (controller.isLoadingInventory.value) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF17A2B8)),
                ),
              );
            }

            if (controller.inventory.isEmpty) {
              return Center(
                child: Text(
                  'No products in inventory. Order from wholesalers first!',
                  style: TextStyle(color: Colors.grey[400]),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.inventory.length.clamp(0, 3),
              itemBuilder: (context, index) {
                final item = controller.inventory[index];
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
                      color: const Color(0xFF17A2B8).withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF17A2B8).withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Obx(() {
                      final productImageUrl = controller.getProductImageUrl(
                        item.productId,
                      );

                      if (productImageUrl != null) {
                        return ProductImageWidget(
                          imageUrl: productImageUrl,
                          fallbackText: item.productName,
                          size: 40,
                        );
                      } else {
                        return Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF17A2B8), Color(0xFF0FB5D4)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              item.productName.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        );
                      }
                    }),
                    title: Text(
                      item.productName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      'Stock: ${item.quantityInStock} | Reorder: ${item.reorderLevel}',
                      style: TextStyle(color: Colors.grey[400], fontSize: 13),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: item.needsRestock
                              ? [
                                  const Color(0xFFFF6B35),
                                  const Color(0xFFFF8C42),
                                ]
                              : [
                                  const Color(0xFF10B981),
                                  const Color(0xFF34D399),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item.needsRestock ? 'Low Stock' : 'In Stock',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    onTap: () =>
                        _showInventoryItemDialog(context, controller, item),
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
          const Padding(
            padding: EdgeInsets.only(left: 4.0, bottom: 16.0),
            child: Text(
              'Recent Purchase Orders',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
          () {
            if (controller.isLoadingPurchases.value) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF17A2B8)),
                ),
              );
            }

            if (controller.purchaseOrders.isEmpty) {
              return Center(
                child: Text(
                  'No purchase orders yet. Start ordering from wholesalers!',
                  style: TextStyle(color: Colors.grey[400]),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.purchaseOrders.length.clamp(0, 3),
              itemBuilder: (context, index) {
                final order = controller.purchaseOrders[index];
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
                      color: const Color(0xFF17A2B8).withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF17A2B8).withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Obx(() {
                      final productImageUrl = controller.getProductImageUrl(
                        order.productId,
                      );

                      if (productImageUrl != null) {
                        return ProductImageWidget(
                          imageUrl: productImageUrl,
                          fallbackText:
                              order.productInfo?.productName ?? 'Product',
                          size: 40,
                        );
                      } else {
                        return Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF17A2B8), Color(0xFF0FB5D4)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              order.productInfo?.productName
                                      ?.substring(0, 1)
                                      .toUpperCase() ??
                                  'P',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        );
                      }
                    }),
                    title: Text(
                      '${order.productInfo.productName} → ${order.wholesalerName}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order ID: #${order.orderId}',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'Qty: ${order.orderDetails.quantity} | \$${order.orderDetails.totalAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'Date: ${_formatOrderDate(order.orderDate)}',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
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
                  ),
                );
              },
            );
          }(),
        ],
      ),
    );
  }

  void _showWholesaleOrdering(
    BuildContext context,
    RetailerController controller,
  ) {
    Get.toNamed(AppRoutes.retailerPurchasing);
  }

  void _showInventoryItemDialog(
    BuildContext context,
    RetailerController controller,
    RetailerInventoryItem item,
  ) {
    final stockController = TextEditingController(
      text: item.quantityInStock.toString(),
    );
    final reorderController = TextEditingController(
      text: item.reorderLevel.toString(),
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
                labelStyle: const TextStyle(color: Color(0xFF17A2B8)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF17A2B8)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF17A2B8),
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
              controller: reorderController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Reorder Level',
                labelStyle: const TextStyle(color: Color(0xFF17A2B8)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF17A2B8)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF17A2B8),
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
              backgroundColor: const Color(0xFF17A2B8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              final stock =
                  int.tryParse(stockController.text) ?? item.quantityInStock;
              final reorder =
                  int.tryParse(reorderController.text) ?? item.reorderLevel;
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
            child: const Text(
              'Restock',
              style: TextStyle(color: Color(0xFF17A2B8)),
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
    RetailerController controller,
    RetailerInventoryItem item,
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
            labelStyle: const TextStyle(color: Color(0xFF17A2B8)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF17A2B8)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF17A2B8), width: 2),
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
              backgroundColor: const Color(0xFF17A2B8),
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
                Navigator.of(context).pop();
              }
            },
            child: const Text('Restock'),
          ),
        ],
      ),
    );
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

  String _formatOrderDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString).toLocal();
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
}

class _OverviewCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final LinearGradient gradient;

  const _OverviewCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: gradient,
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 32, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
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
  final Color color;

  const _ActionCard({
    required this.title,
    required this.icon,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF0F1729), const Color(0xFF1A2332)],
        ),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 28, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
