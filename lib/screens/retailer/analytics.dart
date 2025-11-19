import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../controllers/retailer_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/retailer_inventory.dart';

class RetailerAnalyticsScreen extends StatefulWidget {
  const RetailerAnalyticsScreen({super.key});

  @override
  State<RetailerAnalyticsScreen> createState() => _RetailerAnalyticsScreenState();
}

class _RetailerAnalyticsScreenState extends State<RetailerAnalyticsScreen> {
  final RetailerController controller = Get.find<RetailerController>();
  final AuthController authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  @override
  Widget build(BuildContext context) {
    // Check authentication - same as retailer dashboard
    if (!authController.isLoggedIn || authController.role.value != 'retailer') {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Access Denied',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red),
              ),
              const SizedBox(height: 8),
              const Text(
                'This page is restricted to retailers only.\nPlease login as a retailer to access analytics.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Get.offAllNamed('/login'),
                child: const Text('Go to Login'),
              ),
            ],
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Business Analytics'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Summary'),
              Tab(text: 'Charts'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildSummaryTab(),
            _buildChartsTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _loadAnalytics(),
          child: const Icon(Icons.refresh),
        ),
      ),
    );
  }

  Future<void> _loadAnalytics() async {
    await controller.fetchAnalytics();
  }

  Widget _buildSummaryTab() {
    return Obx(() {
      if (controller.isLoadingAnalytics.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.analytics.value == null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'No analytics data available',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadAnalytics,
                icon: const Icon(Icons.refresh),
                label: const Text('Load Analytics'),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  controller.analyticsError.value,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      }

      final summary = controller.analytics.value!.summary;

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMetricCard(
              title: 'Total Revenue',
              value: '₹${summary.totalRevenue.toStringAsFixed(2)}',
              icon: Icons.currency_rupee,
              color: Colors.green,
            ),
            _buildMetricCard(
              title: 'Total Orders',
              value: '${summary.totalOrders}',
              icon: Icons.shopping_cart,
              color: Colors.blue,
            ),
            _buildMetricCard(
              title: 'Average Order Value',
              value: '₹${summary.averageOrderValue.toStringAsFixed(2)}',
              icon: Icons.trending_up,
              color: Colors.orange,
            ),
            _buildMetricCard(
              title: 'Total Units Sold',
              value: '${summary.totalUnitsSold}',
              icon: Icons.inventory,
              color: Colors.purple,
            ),
            _buildMetricCard(
              title: 'Unique Customers',
              value: '${summary.uniqueBuyers}',
              icon: Icons.people,
              color: Colors.teal,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildMetricCard({required String title, required String value, required IconData icon, required Color color}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 26), // 0.1 * 255
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildChartsTab() {
    return Obx(() {
      if (controller.isLoadingAnalytics.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.analytics.value == null ||
          controller.salesOrders.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.show_chart, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No chart data available',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text(
                'Make some sales to see your analytics charts',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sales Revenue Over Time',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: _RetailerRevenueChart(salesOrders: controller.salesOrders),
            ),

            const SizedBox(height: 40),
            const Text(
              'Customer Order Trends',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: _CustomerOrderTrendsChart(salesOrders: controller.salesOrders),
            ),

            const SizedBox(height: 40),
            const Text(
              'Purchase Cost vs Sales Revenue',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: _PurchaseVsSalesChart(
                salesOrders: controller.salesOrders,
                purchaseOrders: controller.purchaseOrders,
              ),
            ),

            const SizedBox(height: 40),
            const Text(
              'Top Selling Products',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 350,
              child: _RetailerTopProductsChart(salesOrders: controller.salesOrders),
            ),

            const SizedBox(height: 20),
          ],
        ),
      );
    });
  }
}

// =================== RETAILER CHART WIDGETS ===================

class _RetailerRevenueChart extends StatelessWidget {
  final List<RetailingSaleOrder> salesOrders;

  const _RetailerRevenueChart({required this.salesOrders});

  @override
  Widget build(BuildContext context) {
    // Group sales orders by date and calculate daily revenue
    final Map<String, double> dailyRevenue = {};

    for (final order in salesOrders) {
      final date = DateTime.parse(order.orderDate).toLocal();
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      if (!dailyRevenue.containsKey(dateKey)) {
        dailyRevenue[dateKey] = 0;
      }
      dailyRevenue[dateKey] = dailyRevenue[dateKey]! + (order.orderDetails.price * order.orderDetails.quantity);
    }

    // Sort dates and prepare data for chart
    final sortedDates = dailyRevenue.keys.toList()..sort();
    final spots = <FlSpot>[];
    double maxY = 0;

    for (int i = 0; i < sortedDates.length; i++) {
      final revenue = dailyRevenue[sortedDates[i]]!;
      spots.add(FlSpot(i.toDouble(), revenue));
      if (revenue > maxY) maxY = revenue;
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) => Text(
                          '₹${value.toInt()}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < sortedDates.length) {
                            final date = sortedDates[value.toInt()].split('-');
                            return Text('${date[1]}/${date[2]}', style: const TextStyle(fontSize: 10));
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: true, color: Colors.green.withValues(alpha: 51)),
                    ),
                  ],
                  minY: 0,
                  maxY: maxY * 1.1, // Add 10% margin on top
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomerOrderTrendsChart extends StatelessWidget {
  final List<RetailingSaleOrder> salesOrders;

  const _CustomerOrderTrendsChart({required this.salesOrders});

  @override
  Widget build(BuildContext context) {
    // Group orders by date and count daily orders
    final Map<String, int> dailyOrders = {};

    for (final order in salesOrders) {
      final date = DateTime.parse(order.orderDate).toLocal();
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      dailyOrders[dateKey] = (dailyOrders[dateKey] ?? 0) + 1;
    }

    // Sort dates and prepare data for chart
    final sortedDates = dailyOrders.keys.toList()..sort();
    final barGroups = <BarChartGroupData>[];

    for (int i = 0; i < sortedDates.length; i++) {
      final orderCount = dailyOrders[sortedDates[i]]!;
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: orderCount.toDouble(),
              color: Colors.blue,
              width: 16,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    final maxY = dailyOrders.values.isEmpty ? 10.0 : (dailyOrders.values.reduce((a, b) => a > b ? a : b).toDouble()) * 1.2;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: BarChart(
                BarChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) => Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < sortedDates.length) {
                            final date = sortedDates[value.toInt()].split('-');
                            return Text('${date[1]}/${date[2]}', style: const TextStyle(fontSize: 10));
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  barGroups: barGroups,
                  maxY: maxY,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PurchaseVsSalesChart extends StatelessWidget {
  final List<RetailingSaleOrder> salesOrders;
  final List<RetailingPurchaseOrder> purchaseOrders;

  const _PurchaseVsSalesChart({
    required this.salesOrders,
    required this.purchaseOrders,
  });

  @override
  Widget build(BuildContext context) {
    // Group by date for last 30 days
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    // Daily purchase costs
    final Map<String, double> dailyPurchases = {};
    final Map<String, double> dailySales = {};

    // Process purchase orders (costs to retailer)
    for (final order in purchaseOrders) {
      final date = DateTime.parse(order.orderDate).toLocal();
      if (date.isAfter(thirtyDaysAgo)) {
        final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        dailyPurchases[dateKey] = (dailyPurchases[dateKey] ?? 0) + (order.orderDetails.price * order.orderDetails.quantity);
      }
    }

    // Process sales orders (revenue from customers)
    for (final order in salesOrders) {
      final date = DateTime.parse(order.orderDate).toLocal();
      if (date.isAfter(thirtyDaysAgo)) {
        final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        dailySales[dateKey] = (dailySales[dateKey] ?? 0) + (order.orderDetails.price * order.orderDetails.quantity);
      }
    }

    // Create combined date keys
    final allDateKeys = {...dailyPurchases.keys, ...dailySales.keys}.toList()..sort();
    final purchaseSpots = <FlSpot>[];
    final salesSpots = <FlSpot>[];

    for (int i = 0; i < allDateKeys.length; i++) {
      final dateKey = allDateKeys[i];
      final purchaseAmount = dailyPurchases[dateKey] ?? 0.0;
      final salesAmount = dailySales[dateKey] ?? 0.0;

      purchaseSpots.add(FlSpot(i.toDouble(), purchaseAmount));
      salesSpots.add(FlSpot(i.toDouble(), salesAmount));
    }

    final maxPurchase = purchaseSpots.isEmpty ? 0 : purchaseSpots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    final maxSales = salesSpots.isEmpty ? 0 : salesSpots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    final maxY = [maxPurchase, maxSales].reduce((a, b) => a > b ? a : b) * 1.2;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 12, height: 12, color: Colors.red),
                const SizedBox(width: 4),
                const Text('Purchase Cost', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 16),
                Container(width: 12, height: 12, color: Colors.green),
                const SizedBox(width: 4),
                const Text('Sales Revenue', style: TextStyle(fontSize: 12)),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) => Text(
                          '₹${value.toInt()}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < allDateKeys.length && value.toInt() % 3 == 0) {
                            final date = allDateKeys[value.toInt()].split('-');
                            return Text('${date[1]}/${date[2]}', style: const TextStyle(fontSize: 10));
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: purchaseSpots,
                      isCurved: true,
                      color: Colors.red,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: salesSpots,
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                  minY: 0,
                  maxY: maxY,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RetailerTopProductsChart extends StatelessWidget {
  final List<RetailingSaleOrder> salesOrders;

  const _RetailerTopProductsChart({required this.salesOrders});

  @override
  Widget build(BuildContext context) {
    // Count products sold from sales orders
    final Map<String, int> productUnitsSold = {};
    final Map<String, double> productRevenue = {};

    for (final order in salesOrders) {
      final productName = order.productInfo.productName;
      final quantity = order.orderDetails.quantity;
      final revenue = order.orderDetails.price * quantity;

      productUnitsSold[productName] = (productUnitsSold[productName] ?? 0) + quantity;
      productRevenue[productName] = (productRevenue[productName] ?? 0) + revenue;
    }

    if (productRevenue.isEmpty) {
      return const Card(
        elevation: 4,
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Text('No sales data available yet.'),
          ),
        ),
      );
    }

    // Sort by revenue and take top 5
    final sortedProducts = productRevenue.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topProducts = sortedProducts.take(5);

    final sections = topProducts.map((entry) {
      final percentage = productRevenue.values.fold<double>(0, (sum, rev) => sum + rev) > 0
          ? (entry.value / productRevenue.values.fold<double>(0, (sum, rev) => sum + rev)) * 100
          : 0.0;

      return PieChartSectionData(
        value: entry.value,
        title: '${percentage.toStringAsFixed(1)}%',
        color: Colors.primaries[topProducts.toList().indexOf(entry) % Colors.primaries.length],
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: PieChart(
                      PieChartData(
                        sections: sections,
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Legend',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: ListView.builder(
                            itemCount: topProducts.length,
                            itemBuilder: (context, index) {
                              final product = topProducts.elementAt(index);
                              final units = productUnitsSold[product.key] ?? 0;
                              return Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    color: Colors.primaries[index % Colors.primaries.length],
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.key,
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          '$units units - ₹${product.value.toStringAsFixed(0)}',
                                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
