import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/retailer_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/review.dart';
import '../../services/api_service.dart';
import '../../widgets/image_picker_components.dart';

class RetailerReviewManagementScreen extends StatefulWidget {
  const RetailerReviewManagementScreen({super.key});

  @override
  State<RetailerReviewManagementScreen> createState() =>
      _RetailerReviewManagementScreenState();
}

class _RetailerReviewManagementScreenState
    extends State<RetailerReviewManagementScreen> {
  final RetailerController retailerController = Get.find<RetailerController>();
  final AuthController authController = Get.find<AuthController>();
  final ApiService apiService = Get.find<ApiService>();

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
      // Load reviews for each product in retailer's inventory
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

  Future<void> _loadAllReviews() async {
    // Get unique product IDs from retailer inventory
    final productIds = retailerController.inventory
        .map((item) => item.productId)
        .toSet()
        .toList();

    print(
      '🔍 DEBUG: Found ${productIds.length} products in retailer inventory',
    );
    print('🔍 DEBUG: Product IDs: $productIds');

    for (final productId in productIds) {
      try {
        print('📡 Fetching reviews for product ID: $productId');
        final reviews = await apiService.getProductReviews(
          productId.toString(),
        );
        _productReviews[productId] = reviews;
        print('✅ Got ${reviews.length} reviews for product $productId');
      } catch (e) {
        print('❌ Error loading reviews for product $productId: $e');
        _productReviews[productId] = [];
      }

      // Small delay to be gentle on the API
      await Future.delayed(const Duration(milliseconds: 100));
    }

    print(
      '🎉 Finished loading reviews. Total products with reviews: ${_productReviews.length}',
    );
  }

  void _calculateStatistics() {
    for (final productId in _productReviews.keys) {
      final reviews = _productReviews[productId] ?? [];
      _productAverageRatings[productId] = Review.calculateAverageRating(
        reviews,
      );
      _productReviewCounts[productId] = reviews.length;
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
    if (!authController.isLoggedIn || authController.role.value != 'retailer') {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Access Denied'),
              const Text('This page is restricted to retailers only'),
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
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF17A2B8)),
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
                      color: Color(0xFFEF4444),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadAllData,
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

    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF17A2B8), Color(0xFF0FB5D4)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF17A2B8).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.rate_review,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Customer Satisfaction Overview',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '$totalReviews total reviews across ${retailerController.inventory.length} products',
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF6B35).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${averageRating.toStringAsFixed(1)} ⭐',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Average Rating',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopRatedProducts() {
    // Sort products by average rating (descending)
    final sortedInventoryItems = retailerController.inventory.toList()
      ..sort((a, b) {
        final ratingA = _productAverageRatings[a.productId] ?? 0;
        final ratingB = _productAverageRatings[b.productId] ?? 0;
        return ratingB.compareTo(ratingA); // Higher rating first
      });

    final topItems = sortedInventoryItems
        .take(5)
        .where((item) => (_productReviewCounts[item.productId] ?? 0) > 0)
        .toList();

    if (topItems.isEmpty) {
      return SizedBox.shrink(); // Hide if no reviews
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Top Rated Products in Your Inventory',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        ...topItems.map((item) {
          final rating = _productAverageRatings[item.productId] ?? 0;
          final reviewCount = _productReviewCounts[item.productId] ?? 0;

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
                color: _getRatingColor(rating).withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: _getRatingColor(rating).withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: Obx(() {
                final productImageUrl = retailerController.getProductImageUrl(
                  item.productId,
                );
                return ProductImageWidget(
                  imageUrl: productImageUrl,
                  fallbackText: item.productName,
                  size: 50,
                );
              }),
              title: Text(
                item.productName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '$reviewCount reviews • Stock: ${item.quantityInStock}',
                style: TextStyle(color: Colors.grey[400]),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getRatingColor(rating),
                      _getRatingColor(rating).withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: _getRatingColor(rating).withOpacity(0.3),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, size: 18, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      rating.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
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
    if (rating >= 4.5) return const Color(0xFF10B981);
    if (rating >= 4.0) return const Color(0xFF17A2B8);
    if (rating >= 3.0) return const Color(0xFFFF6B35);
    return const Color(0xFFEF4444);
  }

  List<Widget> _buildProductReviewSections() {
    final widgets = <Widget>[];

    for (final item in retailerController.inventory) {
      final reviews = _productReviews[item.productId] ?? [];
      if (reviews.isEmpty) continue;

      final averageRating = _productAverageRatings[item.productId] ?? 0;

      widgets.addAll([
        Row(
          children: [
            Obx(() {
              final productImageUrl = retailerController.getProductImageUrl(
                item.productId,
              );
              return ProductImageWidget(
                imageUrl: productImageUrl,
                fallbackText: item.productName,
                size: 50,
              );
            }),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${reviews.length} customer reviews',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            Text(
                              'Current Stock: ${item.quantityInStock}',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF6B35).withOpacity(0.3),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                averageRating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 16,
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
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, top: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0F1729),
            const Color(0xFF1A2332).withOpacity(0.3),
          ],
        ),
        border: Border.all(
          color: const Color(0xFF17A2B8).withOpacity(0.2),
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
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Row(
                  children: List.generate(5, (starIndex) {
                    return Icon(
                      starIndex < review.rating.toInt()
                          ? Icons.star
                          : Icons.star_border,
                      size: 18,
                      color: const Color(0xFFFF6B35),
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
                  color: Colors.white,
                ),
              ),

            // Review body
            if (review.body != null && review.body!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                review.body!,
                style: TextStyle(
                  color: Colors.grey[400],
                  height: 1.4,
                  fontSize: 14,
                ),
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
