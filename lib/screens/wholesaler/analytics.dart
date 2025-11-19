import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
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

    return DefaultTabController(
      length: 2,
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Business Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => wholesalerController.fetchAnalytics(),
          ),
        ],
        bottom: const TabBar(
          tabs: [
            Tab(text: 'Summary', icon: Icon(Icons.analytics)),
            Tab(text: 'Charts', icon: Icon(Icons.bar_chart)),
          ],
        ),
      ),
      body: TabBarView(
          children: [
            // Summary Tab
            Obx(() {
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
                        value: '₹${analytics.summary.totalRevenue.toStringAsFixed(2)}',
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
                        value: '₹${analytics.summary.averageOrderValue.toStringAsFixed(2)}',
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
                                    '₹${product.totalRevenue.toStringAsFixed(2)}',
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
                            '• Your top product "${analytics.topProducts[0].name}" generated ₹${analytics.topProducts[0].totalRevenue.toStringAsFixed(2)} in revenue',
                          ),
                          if (analytics.topProducts.length > 1)
                            Text(
                              '• Together, your top 3 products account for ₹${analytics.topProducts.take(3).fold<double>(0, (sum, p) => sum + p.totalRevenue).toStringAsFixed(2)} in total revenue',
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

            // Charts Tab
            Obx(() {
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

              if (wholesalerController.analytics.value == null ||
                  wholesalerController.salesOrders.isEmpty) {
                return const Center(
                  child: Text('No chart data available yet. Make some sales to see visualizations!'),
                );
              }

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Revenue Over Time',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 300,
                        child: _RevenueChart(salesOrders: wholesalerController.salesOrders),
                      ),

                      const SizedBox(height: 40),
                      const Text(
                        'Order Volume Trends',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 300,
                        child: _OrderVolumeChart(salesOrders: wholesalerController.salesOrders),
                      ),

                      const SizedBox(height: 40),
                      const Text(
                        'Top Selling Products',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 300,
                        child: _TopProductsChart(analytics: wholesalerController.analytics.value!),
                      ),

                      const SizedBox(height: 40),
                      const Text(
                        'Customer Purchase Patterns',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 400,
                        child: _CustomerPatternsChart(salesOrders: wholesalerController.salesOrders),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// =================== CHART WIDGETS ===================

class _RevenueChart extends StatelessWidget {
  final List<WholesalerSale> salesOrders;

  const _RevenueChart({required this.salesOrders});

  @override
  Widget build(BuildContext context) {
    // Group orders by date and calculate daily revenue
    final Map<String, double> dailyRevenue = {};

    for (final order in salesOrders) {
      final date = DateTime.parse(order.orderDate).toLocal();
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      if (!dailyRevenue.containsKey(dateKey)) {
        dailyRevenue[dateKey] = 0;
      }
      dailyRevenue[dateKey] = dailyRevenue[dateKey]! + order.orderDetails.totalAmount;
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
          crossAxisAlignment: CrossAxisAlignment.start,
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
                        reservedSize: 40,
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
                      belowBarData: BarAreaData(show: true, color: Colors.green.withValues(alpha: 51)), // 0.2 * 255
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

class _OrderVolumeChart extends StatelessWidget {
  final List<WholesalerSale> salesOrders;

  const _OrderVolumeChart({required this.salesOrders});

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
          crossAxisAlignment: CrossAxisAlignment.start,
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

class _TopProductsChart extends StatelessWidget {
  final WholesalerAnalytics analytics;

  const _TopProductsChart({required this.analytics});

  @override
  Widget build(BuildContext context) {
    if (analytics.topProducts.isEmpty) {
      return const Card(
        elevation: 4,
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Text('No product data available yet.'),
          ),
        ),
      );
    }

    final topProducts = analytics.topProducts.take(5).toList();
    final sections = topProducts.map((product) {
      final percentage = analytics.summary.totalRevenue > 0
          ? (product.totalRevenue / analytics.summary.totalRevenue) * 100
          : 0.0;

      return PieChartSectionData(
        value: product.totalRevenue,
        title: '${percentage.toStringAsFixed(1)}%',
        color: Colors.primaries[topProducts.indexOf(product) % Colors.primaries.length],
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
          crossAxisAlignment: CrossAxisAlignment.start,
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
                              final product = topProducts[index];
                              return Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    color: Colors.primaries[index % Colors.primaries.length],
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      product.name,
                                      style: const TextStyle(fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    '₹${product.totalRevenue.toStringAsFixed(0)}',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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

class _CustomerPatternsChart extends StatelessWidget {
  final List<WholesalerSale> salesOrders;

  const _CustomerPatternsChart({required this.salesOrders});

  @override
  Widget build(BuildContext context) {
    // Analyze customer purchase patterns
    final Map<int, List<WholesalerSale>> customerOrders = {};

    for (final order in salesOrders) {
      if (!customerOrders.containsKey(order.buyerId)) {
        customerOrders[order.buyerId] = [];
      }
      customerOrders[order.buyerId]!.add(order);
    }

    // Count customers by order frequency
    final Map<int, int> frequencyCount = {};
    for (final orders in customerOrders.values) {
      final frequency = orders.length;
      frequencyCount[frequency] = (frequencyCount[frequency] ?? 0) + 1;
    }

    // Sort by frequency and take top categories
    final sortedFrequencies = frequencyCount.keys.toList()..sort((a, b) => b.compareTo(a));
    final topFrequencies = sortedFrequencies.take(10).toList();

    final barGroups = topFrequencies.map((frequency) {
      return BarChartGroupData(
        x: frequency,
        barRods: [
          BarChartRodData(
            toY: frequencyCount[frequency]!.toDouble(),
            color: Colors.purple,
            width: 20,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();

    final maxY = frequencyCount.values.isEmpty ? 10.0 : (frequencyCount.values.reduce((a, b) => a > b ? a : b).toDouble()) * 1.2;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customer Order Frequency',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Number of orders per customer',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
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
                        getTitlesWidget: (value, meta) => Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 10),
                        ),
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
