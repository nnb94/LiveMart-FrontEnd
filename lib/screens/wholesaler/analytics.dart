import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/wholesaler_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/wholesaler_sale.dart';

class WholesalerAnalyticsScreen extends StatelessWidget {
  const WholesalerAnalyticsScreen({super.key});

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

    // Fetch analytics on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      wholesalerController.fetchAnalytics();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => wholesalerController.fetchAnalytics(),
          ),
        ],
      ),
      body: Obx(() {
        if (wholesalerController.isLoadingAnalytics.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (wholesalerController.analyticsError.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${wholesalerController.analyticsError}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => wholesalerController.fetchAnalytics(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (wholesalerController.analytics.value == null) {
          return const Center(
            child: Text('No analytics data available yet. Make some sales to see your metrics!'),
          );
        }

        final analytics = wholesalerController.analytics.value!;
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sales Summary',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // Summary Cards
                Row(
                  children: [
                    Expanded(
                      child: _AnalyticsCard(
                        title: 'Total Orders',
                        value: analytics.summary.totalOrders.toString(),
                        icon: Icons.shopping_cart,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _AnalyticsCard(
                        title: 'Total Revenue',
                        value: '\$${analytics.summary.totalRevenue.toStringAsFixed(2)}',
                        icon: Icons.attach_money,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _AnalyticsCard(
                        title: 'Avg Order Value',
                        value: '\$${analytics.summary.averageOrderValue.toStringAsFixed(2)}',
                        icon: Icons.trending_up,
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _AnalyticsCard(
                        title: 'Units Sold',
                        value: analytics.summary.totalUnitsSold.toString(),
                        icon: Icons.inventory,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _AnalyticsCard(
                        title: 'Unique Buyers',
                        value: analytics.summary.uniqueBuyers.toString(),
                        icon: Icons.people,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(child: SizedBox()),
                  ],
                ),

                const SizedBox(height: 32),
                const Text(
                  'Top Performing Products',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Top Products List
                if (analytics.topProducts.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('No sales data yet. Make your first sale to see top products!'),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: analytics.topProducts.length,
                    itemBuilder: (context, index) {
                      final product = analytics.topProducts[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.blue.shade100,
                                child: Text(
                                  '#${index + 1}',
                                  style: TextStyle(
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Orders: ${product.orderCount} | Total Sold: ${product.totalQuantitySold} units',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '\$${product.totalRevenue.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  const Text(
                                    'Revenue',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                const SizedBox(height: 32),

                // Additional insights
                if (analytics.topProducts.isNotEmpty && analytics.summary.totalOrders > 0)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Business Insights',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '• Your top product "${analytics.topProducts[0].name}" generated \$${analytics.topProducts[0].totalRevenue.toStringAsFixed(2)} in revenue',
                          ),
                          if (analytics.topProducts.length > 1)
                            Text(
                              '• Together, your top 3 products account for \$${analytics.topProducts.take(3).fold<double>(0, (sum, p) => sum + p.totalRevenue).toStringAsFixed(2)} in total revenue',
                            ),
                          Text(
                            '• Average ${analytics.summary.totalUnitsSold > 1 ? (analytics.summary.totalUnitsSold / analytics.summary.totalOrders).toStringAsFixed(1) : "0"} units sold per order',
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _AnalyticsCard({
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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
