import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../controllers/retailer_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/retailer_inventory.dart';

class RetailerAnalyticsScreen extends StatefulWidget {
  const RetailerAnalyticsScreen({super.key});

  @override
  State<RetailerAnalyticsScreen> createState() =>
      _RetailerAnalyticsScreenState();
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
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
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
        backgroundColor: const Color(0xFF0A0E27),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0F1729),
          elevation: 0,
          title: const Text(
            'Business Analytics',
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
          bottom: const TabBar(
            indicatorColor: Color(0xFF17A2B8),
            indicatorWeight: 3,
            labelColor: Color(0xFF17A2B8),
            unselectedLabelColor: Colors.white60,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            tabs: [
              Tab(text: 'Summary'),
              Tab(text: 'Charts'),
            ],
          ),
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
          child: TabBarView(children: [_buildSummaryTab(), _buildChartsTab()]),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _loadAnalytics(),
          backgroundColor: const Color(0xFF17A2B8),
          elevation: 8,
          child: const Icon(Icons.refresh, color: Colors.white),
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
                  Icons.analytics_outlined,
                  size: 80,
                  color: Color(0xFF17A2B8),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'No analytics data available',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadAnalytics,
                icon: const Icon(Icons.refresh),
                label: const Text('Load Analytics'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF17A2B8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  controller.analyticsError.value,
                  style: const TextStyle(
                    color: Color(0xFFEF4444),
                    fontSize: 12,
                  ),
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

  LinearGradient _getMetricGradient(Color color) {
    if (color == Colors.green) {
      return const LinearGradient(
        colors: [Color(0xFF10B981), Color(0xFF34D399)],
      );
    } else if (color == Colors.blue) {
      return const LinearGradient(
        colors: [Color(0xFF17A2B8), Color(0xFF0FB5D4)],
      );
    } else if (color == Colors.orange) {
      return const LinearGradient(
        colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
      );
    } else if (color == Colors.purple) {
      return const LinearGradient(
        colors: [Color(0xFFA855F7), Color(0xFFD946EF)],
      );
    } else if (color == Colors.teal) {
      return const LinearGradient(
        colors: [Color(0xFF14B8A6), Color(0xFF2DD4BF)],
      );
    }
    return LinearGradient(colors: [color, color]);
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final gradient = _getMetricGradient(color);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0F1729),
            const Color(0xFF1A2332).withOpacity(0.5),
          ],
        ),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

  Widget _buildChartsTab() {
    return Obx(() {
      if (controller.isLoadingAnalytics.value) {
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF17A2B8)),
          ),
        );
      }

      if (controller.analytics.value == null ||
          controller.salesOrders.isEmpty) {
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
                  Icons.show_chart,
                  size: 80,
                  color: Color(0xFF17A2B8),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'No chart data available',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Make some sales to see your analytics charts',
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
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
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: _RetailerRevenueChart(salesOrders: controller.salesOrders),
            ),

            const SizedBox(height: 40),
            const Text(
              'Customer Order Trends',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: _CustomerOrderTrendsChart(
                salesOrders: controller.salesOrders,
              ),
            ),

            const SizedBox(height: 40),
            const Text(
              'Purchase Cost vs Sales Revenue',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
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
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 350,
              child: _RetailerTopProductsChart(
                salesOrders: controller.salesOrders,
              ),
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
      final dateKey =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      if (!dailyRevenue.containsKey(dateKey)) {
        dailyRevenue[dateKey] = 0;
      }
      dailyRevenue[dateKey] =
          dailyRevenue[dateKey]! +
          (order.orderDetails.price * order.orderDetails.quantity);
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

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
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
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
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
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 &&
                              value.toInt() < sortedDates.length) {
                            final date = sortedDates[value.toInt()].split('-');
                            return Text(
                              '${date[1]}/${date[2]}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white70,
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF34D399)],
                      ),
                      barWidth: 4,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF10B981).withOpacity(0.3),
                            const Color(0xFF34D399).withOpacity(0.1),
                          ],
                        ),
                      ),
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
      final dateKey =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

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
              gradient: const LinearGradient(
                colors: [Color(0xFF17A2B8), Color(0xFF0FB5D4)],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
              width: 16,
              borderRadius: BorderRadius.circular(6),
            ),
          ],
        ),
      );
    }

    final maxY = dailyOrders.values.isEmpty
        ? 10.0
        : (dailyOrders.values.reduce((a, b) => a > b ? a : b).toDouble()) * 1.2;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
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
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
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
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 &&
                              value.toInt() < sortedDates.length) {
                            final date = sortedDates[value.toInt()].split('-');
                            return Text(
                              '${date[1]}/${date[2]}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white70,
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
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
        final dateKey =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        dailyPurchases[dateKey] =
            (dailyPurchases[dateKey] ?? 0) +
            (order.orderDetails.price * order.orderDetails.quantity);
      }
    }

    // Process sales orders (revenue from customers)
    for (final order in salesOrders) {
      final date = DateTime.parse(order.orderDate).toLocal();
      if (date.isAfter(thirtyDaysAgo)) {
        final dateKey =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        dailySales[dateKey] =
            (dailySales[dateKey] ?? 0) +
            (order.orderDetails.price * order.orderDetails.quantity);
      }
    }

    // Create combined date keys
    final allDateKeys = {...dailyPurchases.keys, ...dailySales.keys}.toList()
      ..sort();
    final purchaseSpots = <FlSpot>[];
    final salesSpots = <FlSpot>[];

    for (int i = 0; i < allDateKeys.length; i++) {
      final dateKey = allDateKeys[i];
      final purchaseAmount = dailyPurchases[dateKey] ?? 0.0;
      final salesAmount = dailySales[dateKey] ?? 0.0;

      purchaseSpots.add(FlSpot(i.toDouble(), purchaseAmount));
      salesSpots.add(FlSpot(i.toDouble(), salesAmount));
    }

    final maxPurchase = purchaseSpots.isEmpty
        ? 0
        : purchaseSpots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    final maxSales = salesSpots.isEmpty
        ? 0
        : salesSpots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    final maxY = [maxPurchase, maxSales].reduce((a, b) => a > b ? a : b) * 1.2;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
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
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFEF4444), Color(0xFFF87171)],
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'Purchase Cost',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF34D399)],
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'Sales Revenue',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
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
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 &&
                              value.toInt() < allDateKeys.length &&
                              value.toInt() % 3 == 0) {
                            final date = allDateKeys[value.toInt()].split('-');
                            return Text(
                              '${date[1]}/${date[2]}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white70,
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: purchaseSpots,
                      isCurved: true,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFEF4444), Color(0xFFF87171)],
                      ),
                      barWidth: 4,
                      dotData: const FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: salesSpots,
                      isCurved: true,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF34D399)],
                      ),
                      barWidth: 4,
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

      productUnitsSold[productName] =
          (productUnitsSold[productName] ?? 0) + quantity;
      productRevenue[productName] =
          (productRevenue[productName] ?? 0) + revenue;
    }

    if (productRevenue.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
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
        ),
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Text(
              'No sales data available yet.',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ),
      );
    }

    // Sort by revenue and take top 5
    final sortedProducts = productRevenue.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topProducts = sortedProducts.take(5);

    final sections = topProducts.map((entry) {
      final percentage =
          productRevenue.values.fold<double>(0, (sum, rev) => sum + rev) > 0
          ? (entry.value /
                    productRevenue.values.fold<double>(
                      0,
                      (sum, rev) => sum + rev,
                    )) *
                100
          : 0.0;

      return PieChartSectionData(
        value: entry.value,
        title: '${percentage.toStringAsFixed(1)}%',
        color:
            Colors.primaries[topProducts.toList().indexOf(entry) %
                Colors.primaries.length],
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0F1729),
            const Color(0xFF1A2332).withOpacity(0.5),
          ],
        ),
        border: Border.all(
          color: const Color(0xFFA855F7).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFA855F7).withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
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
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
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
                                    color:
                                        Colors.primaries[index %
                                            Colors.primaries.length],
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.key,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          '$units units - ₹${product.value.toStringAsFixed(0)}',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey[400],
                                          ),
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
