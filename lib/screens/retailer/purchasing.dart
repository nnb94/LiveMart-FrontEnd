import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/retailer_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/retailer_inventory.dart';
import '../../models/review.dart';
import '../../services/api_service.dart';
import '../../widgets/image_picker_components.dart';

class RetailerPurchasingScreen extends StatefulWidget {
  const RetailerPurchasingScreen({super.key});

  @override
  State<RetailerPurchasingScreen> createState() => _RetailerPurchasingScreenState();
}

class _RetailerPurchasingScreenState extends State<RetailerPurchasingScreen> {
  String _searchText = '';
  String _sortOption = 'name';

  // Computed property that applies search and sort filters
  List<AvailableWholesaleProduct> get _filteredProducts {
    final controller = Get.find<RetailerController>();
    final products = controller.availableWholesaleProducts;

    // Apply search filter
    final filtered = _searchText.isEmpty
        ? products
        : products.where((product) =>
              product.product.name.toLowerCase().contains(_searchText.toLowerCase()) ||
              product.sellerName.toLowerCase().contains(_searchText.toLowerCase()) ||
              product.product.category.toLowerCase().contains(_searchText.toLowerCase()) ||
              product.product.description.toLowerCase().contains(_searchText.toLowerCase())).toList();

    // Apply sorting
    filtered.sort((a, b) {
      switch (_sortOption) {
        case 'name':
          return a.product.name.toLowerCase().compareTo(b.product.name.toLowerCase());
        case 'price':
          return a.product.price.compareTo(b.product.price);
        case 'seller':
          return a.sellerName.toLowerCase().compareTo(b.sellerName.toLowerCase());
        default:
          return 0;
      }
    });

    return filtered;
  }

  @override
  void initState() {
    super.initState();
    // Load products when screen opens if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.find<RetailerController>();
      if (controller.availableWholesaleProducts.isEmpty && !controller.isLoadingWholesaleProducts.value) {
        controller.fetchWholesaleProducts();
      }
    });
  }

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
      appBar: AppBar(
        title: const Text('Wholesale Purchasing'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => retailerController.fetchWholesaleProducts(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(
            child: GetBuilder<RetailerController>(
              builder: (controller) {
                if (controller.isLoadingWholesaleProducts.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.wholesaleProductsError.value.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(controller.wholesaleProductsError.value),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => controller.fetchWholesaleProducts(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (controller.availableWholesaleProducts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'No products available',
                          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                        Text(
                          'Wholesalers haven\'t added products yet',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: _filteredProducts.length,
                  itemBuilder: (context, index) {
                    final item = _filteredProducts[index];
                    return _buildWholesaleProductCard(context, controller, item);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _buildCartFab(retailerController),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blue.shade50,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() => _searchText = value);
              },
            ),
          ),
          const SizedBox(width: 12),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() => _sortOption = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'name', child: Text('Sort by Name')),
              const PopupMenuItem(value: 'price', child: Text('Sort by Price')),
              const PopupMenuItem(value: 'seller', child: Text('Sort by Seller')),
            ],
            icon: const Icon(Icons.sort),
            tooltip: 'Sort products',
          ),
        ],
      ),
    );
  }

  Widget _buildWholesaleProductCard(BuildContext context, RetailerController controller, AvailableWholesaleProduct item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            onTap: () => _showProductDetailsDialog(context, controller, item),
            leading: ProductImageWidget(
              imageUrl: item.product.imageUrl,
              fallbackText: item.product.name,
              size: 60,
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    item.product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Min: ${item.minimumOrderQuantity}',
                    style: TextStyle(
                      color: Colors.blue.shade800,
                      fontSize: 12,
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
                  'Seller: ${item.sellerName}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  '\$${item.product.price.toStringAsFixed(2)} • Stock: ${item.availableStock} units',
                  style: const TextStyle(fontSize: 14),
                ),
                if (item.product.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.product.description,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Category: ${item.product.category}',
                        style: TextStyle(color: Colors.grey[700], fontSize: 12),
                      ),
                      Text(
                        'Minimum Order: ${item.minimumOrderQuantity} units',
                        style: TextStyle(color: Colors.grey[700], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _showBulkOrderDialog(context, controller, item),
                  child: const Text('Place Bulk Order'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showBulkOrderDialog(BuildContext context, RetailerController controller, AvailableWholesaleProduct item) {
    final quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order ${item.product.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Seller: ${item.sellerName}'),
            Text('Price: \$${item.product.price.toStringAsFixed(2)} per unit'),
            Text('Available Stock: ${item.availableStock} units'),
            Text('Minimum Order: ${item.minimumOrderQuantity} units'),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              decoration: InputDecoration(
                labelText: 'Quantity to order',
                hintText: 'Min: ${item.minimumOrderQuantity}',
              ),
              keyboardType: TextInputType.number,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final quantity = int.tryParse(quantityController.text);
              if (quantity == null || quantity <= 0) {
                Get.snackbar('Error', 'Please enter a valid quantity');
                return;
              }

              if (quantity < item.minimumOrderQuantity) {
                Get.snackbar(
                  'Error',
                  'Minimum order quantity is ${item.minimumOrderQuantity} units'
                );
                return;
              }

              if (quantity > item.availableStock) {
                Get.snackbar(
                  'Error',
                  'Only ${item.availableStock} units available in stock'
                );
                return;
              }

              // Place the order
              final success = await controller.placeWholesaleOrder([
                {
                  'product_id': item.product.id,
                  'quantity': quantity,
                  'seller_id': item.sellerId,
                }
              ]);

              if (success) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Place Order'),
          ),
        ],
      ),
    );
  }

  void _showProductDetailsDialog(BuildContext context, RetailerController controller, AvailableWholesaleProduct item) {
    final quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => DefaultTabController(
        length: 2, // Two tabs: Details and Reviews
        child: StatefulBuilder(
          builder: (context, setState) => Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
              child: Column(
                children: [
                  // Header with tabs
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Header with product name and close button
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.product.name,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () => Navigator.of(context).pop(),
                                icon: const Icon(Icons.close),
                              ),
                            ],
                          ),
                        ),
                        // Tab bar
                        const TabBar(
                          tabs: [
                            Tab(
                              icon: Icon(Icons.info),
                              text: 'Details',
                            ),
                            Tab(
                              icon: Icon(Icons.rate_review),
                              text: 'Reviews',
                            ),
                          ],
                          labelColor: Colors.blue,
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: Colors.blue,
                        ),
                      ],
                    ),
                  ),

                  // Tab content
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Details Tab
                        _buildProductDetailsTab(context, quantityController, item),

                        // Reviews Tab
                        _buildProductReviewsTab(context, item),
                      ],
                    ),
                  ),

                  // Action buttons
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.grey.shade50,
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // Close detail dialog and open order dialog
                              Navigator.of(context).pop();
                              _showBulkOrderDialog(context, controller, item);
                            },
                            icon: const Icon(Icons.shopping_cart),
                            label: const Text('Place Order'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductDetailsTab(BuildContext context, TextEditingController quantityController, AvailableWholesaleProduct item) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          Center(
            child: Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ProductImageWidget(
                imageUrl: item.product.imageUrl,
                fallbackText: item.product.name,
                size: 120,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Price section
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pricing Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Unit Price: \$${item.product.price.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Minimum Order: ${item.minimumOrderQuantity} units',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                Text(
                  'Available Stock: ${item.availableStock} units',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Seller information
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Seller Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Wholesaler: ${item.sellerName}',
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  'Product ID: ${item.product.id}',
                  style: TextStyle(color: Colors.grey[700], fontSize: 12),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Product specifications
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Product Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Category: ${item.product.category}',
                  style: const TextStyle(fontSize: 14),
                ),
                if (item.product.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Description:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.product.description,
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Order placement section
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Place Bulk Order',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: quantityController,
                  decoration: InputDecoration(
                    labelText: 'Quantity to order',
                    hintText: 'Min: ${item.minimumOrderQuantity}',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  autofocus: true,
                ),
                const SizedBox(height: 12),
                // Calculate estimated cost
                Row(
                  children: [
                    const Icon(Icons.calculate, size: 20, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        quantityController.text.isNotEmpty &&
                                int.tryParse(quantityController.text) != null
                            ? 'Estimated Cost: \$${(int.parse(quantityController.text) * item.product.price).toStringAsFixed(2)}'
                            : 'Enter quantity to see cost estimate',
                        style: const TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductReviewsTab(BuildContext context, AvailableWholesaleProduct item) {
    return StatefulBuilder(
      builder: (context, setState) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Reviews header with stats
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.rate_review, size: 24, color: Colors.teal),
                      const SizedBox(width: 8),
                      const Text(
                        'Customer Reviews',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Reviews for ${item.product.name}',
                    style: TextStyle(color: Colors.grey[700]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Reviews content
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: Get.find<ApiService>().getProductReviews(item.product.id.toString()),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error, size: 48, color: Colors.red),
                          const SizedBox(height: 16),
                          const Text('Failed to load reviews'),
                          const SizedBox(height: 8),
                          Text(
                            snapshot.error.toString(),
                            style: TextStyle(color: Colors.grey[600]),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.reviews, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No reviews yet',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'This product hasn\'t been reviewed by customers yet.',
                            style: TextStyle(color: Colors.grey[600]),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  List<Review> reviews = snapshot.data!
                      .map((json) => Review.fromJson(json))
                      .toList();

                  // Calculate average rating
                  double averageRating = reviews.isNotEmpty
                      ? reviews.fold<double>(0, (sum, review) => sum + review.rating) / reviews.length
                      : 0.0;

                  return Column(
                    children: [
                      // Summary card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.yellow.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${reviews.length} reviews',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Icon(Icons.star, color: Colors.yellow, size: 20),
                            Text(
                              averageRating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Reviews list
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: reviews.length.clamp(0, 5), // Show first 5 reviews
                          itemBuilder: (context, index) {
                            final review = reviews[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
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
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                          height: 1.4,
                                        ),
                                      ),
                                    ],

                                    const SizedBox(height: 8),

                                    // Date
                                    Text(
                                      _formatReviewDate(review.createdAt),
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Show more reviews hint if there are many reviews
                      if (reviews.length > 5)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'Showing 5 of ${reviews.length} reviews',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
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

  Widget _buildCartFab(RetailerController controller) {
    // TODO: Add cart functionality later
    // For now, just show refresh button
    return FloatingActionButton(
      onPressed: () => controller.fetchWholesaleProducts(),
      child: const Icon(Icons.refresh),
    );
  }
}
