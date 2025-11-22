import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/wholesaler_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/review.dart';
import '../../models/product.dart';
import '../../services/api_service.dart';
import '../../widgets/image_picker_components.dart';

class WholesalerReviewManagementScreen extends StatefulWidget {
  const WholesalerReviewManagementScreen({super.key});

  @override
  State<WholesalerReviewManagementScreen> createState() =>
      _WholesalerReviewManagementScreenState();
}

class _WholesalerReviewManagementScreenState
    extends State<WholesalerReviewManagementScreen> {
  final WholesalerController wholesalerController =
      Get.find<WholesalerController>();
  final AuthController authController = Get.find<AuthController>();
  final ApiService apiService = Get.find<ApiService>();

  late List<Product> _products;
  final Map<int, List<Review>> _productReviews = {};
  final Map<int, double> _productAverageRatings = {};
  final Map<int, int> _productReviewCounts = {};
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Load products first
      await _loadProducts();

      // Then load reviews for each product
      await _loadAllReviews();

      // Calculate summary statistics
      _calculateStatistics();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load data: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadProducts() async {
    try {
      final products = await apiService.getWholesalerProducts(
        authController.accessToken.value,
      );
      _products = products;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _loadAllReviews() async {
    for (final product in _products) {
      try {
        final reviews = await apiService.getProductReviews(
          product.id.toString(),
        );
        _productReviews[product.id] = reviews;
      } catch (e) {
        print('Error loading reviews for product ${product.id}: $e');
        _productReviews[product.id] = [];
      }

      // Small delay to be gentle on the API
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  void _calculateStatistics() {
    for (final product in _products) {
      final reviews = _productReviews[product.id] ?? [];
      _productAverageRatings[product.id] = Review.calculateAverageRating(
        reviews,
      );
      _productReviewCounts[product.id] = reviews.length;
    }
  }

  double _getOverallAverageRating() {
    int totalReviews = 0;
    double totalRatingSum = 0;

    for (final reviews in _productReviews.values) {
      totalReviews += reviews.length;
      totalRatingSum += reviews.fold<double>(
        0,
        (sum, review) => sum + review.rating,
      );
    }

    return totalReviews > 0 ? totalRatingSum / totalReviews : 0.0;
  }

  int _getTotalReviews() {
    return _productReviews.values.fold<int>(
      0,
      (sum, reviews) => sum + reviews.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!authController.isLoggedIn ||
        authController.role.value != 'wholesaler') {
      return Scaffold(
        backgroundColor: const Color(0xFF0A0E27),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Access Denied',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This page is restricted to wholesalers only',
                style: TextStyle(color: Colors.grey[400]),
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
          'Product Reviews',
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
                colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _loadAllData,
              tooltip: 'Refresh',
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
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B35)),
                ),
              )
            : _errorMessage.isNotEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B35),
                      ),
                      onPressed: _loadAllData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : _buildReviewContent(),
      ),
    );
  }

  Widget _buildReviewContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overall Statistics Card
          _buildOverallStatsCard(),
          const SizedBox(height: 24),

          // Top Rated Products
          _buildTopRatedProducts(),
          const SizedBox(height: 24),

          // Product Reviews List
          ..._buildProductReviewSections(),
        ],
      ),
    );
  }

  Widget _buildOverallStatsCard() {
    final totalReviews = _getTotalReviews();
    final averageRating = _getOverallAverageRating();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.rate_review, color: Colors.yellow, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Overall Statistics',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$totalReviews total reviews across all products',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.yellow.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${averageRating.toStringAsFixed(1)} ⭐',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('Average Rating'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopRatedProducts() {
    // Sort products by average rating (descending)
    final sortedProducts = _products.toList()
      ..sort((a, b) {
        final ratingA = _productAverageRatings[a.id] ?? 0;
        final ratingB = _productAverageRatings[b.id] ?? 0;
        return ratingB.compareTo(ratingA); // Higher rating first
      });

    final topProducts = sortedProducts.take(5).toList();

    if (topProducts.isEmpty ||
        topProducts.every(
          (product) => (_productReviewCounts[product.id] ?? 0) == 0,
        )) {
      return Container(); // Hide if no reviews
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Top Rated Products',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...topProducts.map((product) {
          final rating = _productAverageRatings[product.id] ?? 0;
          final reviewCount = _productReviewCounts[product.id] ?? 0;

          if (reviewCount == 0) return const SizedBox.shrink();

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: SizedBox(
                width: 40,
                height: 40,
                child: ProductImageWidget(
                  imageUrl: product.imageUrl,
                  fallbackText: product.name,
                  size: 40,
                ),
              ),
              title: Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text('${reviewCount} reviews'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getRatingColor(rating),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      rating.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Color _getRatingColor(double rating) {
    if (rating >= 4.5) return Colors.green;
    if (rating >= 4.0) return Colors.blue;
    if (rating >= 3.0) return Colors.orange;
    return Colors.red;
  }

  List<Widget> _buildProductReviewSections() {
    final widgets = <Widget>[];

    for (final product in _products) {
      final reviews = _productReviews[product.id] ?? [];
      if (reviews.isEmpty) continue;

      final averageRating = _productAverageRatings[product.id] ?? 0;

      widgets.addAll([
        Row(
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: ProductImageWidget(
                imageUrl: product.imageUrl,
                fallbackText: product.name,
                size: 40,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${reviews.length} reviews'),
                                Text(
                                  product.category,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.yellow,
                                size: 20,
                              ),
                              Text(
                                '${averageRating.toStringAsFixed(1)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...reviews.map((review) => _buildReviewTile(review)),
        const SizedBox(height: 24),
      ]);
    }

    return widgets;
  }

  Widget _buildReviewTile(Review review) {
    return Card(
      margin: const EdgeInsets.only(left: 16, right: 16, top: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with customer name and rating
            Row(
              children: [
                Text(
                  review.customerName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Row(
                  children: List.generate(5, (starIndex) {
                    return Icon(
                      starIndex < review.rating.toInt()
                          ? Icons.star
                          : Icons.star_border,
                      size: 16,
                      color: Colors.yellow,
                    );
                  }),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Review title
            if (review.title != null && review.title!.isNotEmpty)
              Text(
                review.title!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),

            // Review body
            if (review.body != null && review.body!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                review.body!,
                style: TextStyle(color: Colors.grey[700], height: 1.4),
              ),
            ],

            const SizedBox(height: 8),

            // Date
            Text(
              _formatReviewDate(review.createdAt),
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  String _formatReviewDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} days ago';
    } else {
      // Use a more readable format: DD/MM/YYYY
      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    }
  }
}
