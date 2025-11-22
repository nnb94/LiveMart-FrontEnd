import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../controllers/auth_controller.dart';
import '../../services/api_service.dart';
import '../../approutes.dart';

class RetailerWishlistScreen extends StatefulWidget {
  const RetailerWishlistScreen({super.key});

  @override
  State<RetailerWishlistScreen> createState() => _RetailerWishlistScreenState();
}

class _RetailerWishlistScreenState extends State<RetailerWishlistScreen> {
  final authController = Get.find<AuthController>();
  final apiService = Get.find<ApiService>();

  bool isLoading = true;
  List<Map<String, dynamic>> wishlistItems = [];
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  Future<void> _loadWishlist() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final url = Uri.parse('${ApiService.baseUrl}/retailer-wishlists/list');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${authController.accessToken.value}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('DEBUG: Raw wishlist data: $data');

        // API returns array directly, not wrapped in 'wishlistItems'
        final items = (data is List)
            ? data
            : (data['wishlistItems'] as List<dynamic>? ?? []);

        print('DEBUG: Items count: ${items.length}');
        if (items.isNotEmpty) {
          print('DEBUG: First item: ${items[0]}');
          print('DEBUG: First item type: ${items[0].runtimeType}');
        }
        setState(() {
          wishlistItems = items.map((item) {
            final itemMap = Map<String, dynamic>.from(item as Map);
            // Restructure to match expected format
            return {
              'product_id': itemMap['product_id'].toString(),
              'quantity': itemMap['quantity'],
              'notes': itemMap['notes'],
              'product': {
                'name': itemMap['product_name'],
                'price': itemMap['price'],
                'description': itemMap['description'],
                'category': itemMap['category'],
                'image_url': itemMap['image_url'],
              },
              'wholesaler': {
                'name': itemMap['wholesaler_name'],
                'email': itemMap['wholesaler_email'],
              },
            };
          }).toList();
          isLoading = false;
        });
      } else {
        final data = jsonDecode(response.body);
        setState(() {
          errorMessage = data['message'] ?? 'Failed to load wishlist';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading wishlist: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _updateQuantity(
    int productId,
    int newQuantity,
    String? notes,
  ) async {
    try {
      final url = Uri.parse('${ApiService.baseUrl}/retailer-wishlists/update');
      final response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer ${authController.accessToken.value}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'productId': productId,
          'quantity': newQuantity,
          if (notes != null) 'notes': notes,
        }),
      );

      if (response.statusCode == 200) {
        Get.snackbar(
          'Success',
          'Wishlist item updated',
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        _loadWishlist();
      } else {
        final data = jsonDecode(response.body);
        Get.snackbar(
          'Error',
          data['message'] ?? 'Failed to update item',
          backgroundColor: const Color(0xFFEF4444),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update item: $e',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _removeFromWishlist(int productId) async {
    try {
      final url = Uri.parse('${ApiService.baseUrl}/retailer-wishlists/remove');
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer ${authController.accessToken.value}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'productId': productId}),
      );

      if (response.statusCode == 200) {
        Get.snackbar(
          'Success',
          'Item removed from wishlist',
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        _loadWishlist();
      } else {
        final data = jsonDecode(response.body);
        Get.snackbar(
          'Error',
          data['message'] ?? 'Failed to remove item',
          backgroundColor: const Color(0xFFEF4444),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to remove item: $e',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _clearWishlist() async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: const Color(0xFF0F1729),
        title: const Text(
          'Clear Wishlist',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to clear your entire wishlist?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Get.back(result: true),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final url = Uri.parse('${ApiService.baseUrl}/retailer-wishlists/clear');
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer ${authController.accessToken.value}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        Get.snackbar(
          'Success',
          'Wishlist cleared',
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        _loadWishlist();
      } else {
        final data = jsonDecode(response.body);
        Get.snackbar(
          'Error',
          data['message'] ?? 'Failed to clear wishlist',
          backgroundColor: const Color(0xFFEF4444),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to clear wishlist: $e',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _orderFromWishlist({bool clearAfter = false}) async {
    if (wishlistItems.isEmpty) {
      Get.snackbar(
        'Error',
        'Your wishlist is empty',
        backgroundColor: const Color(0xFFFF6B35),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final confirm = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: const Color(0xFF0F1729),
        title: const Text(
          'Order from Wishlist',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Place order for ${wishlistItems.length} item(s)?',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            if (clearAfter)
              const Text(
                'Your wishlist will be cleared after ordering.',
                style: TextStyle(color: Color(0xFFFF6B35), fontSize: 13),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF17A2B8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Get.back(result: true),
            child: const Text('Place Order'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final url = Uri.parse(
        '${ApiService.baseUrl}/retailers/order/from-wishlist',
      );
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer ${authController.accessToken.value}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'clearWishlist': clearAfter}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          'Success',
          'Order placed successfully!',
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
        _loadWishlist();
      } else {
        final data = jsonDecode(response.body);
        Get.snackbar(
          'Error',
          data['message'] ?? 'Failed to place order',
          backgroundColor: const Color(0xFFEF4444),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to place order: $e',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _showEditDialog(Map<String, dynamic> item) {
    final quantityController = TextEditingController(
      text: item['quantity'].toString(),
    );
    final notesController = TextEditingController(text: item['notes'] ?? '');

    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF0F1729),
        title: Text(
          item['product']['name'],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: quantityController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Quantity',
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
              controller: notesController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Notes (optional)',
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
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF17A2B8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              final qty = item['quantity'];
              final currentQuantity = qty is int
                  ? qty
                  : int.tryParse(qty.toString()) ?? 0;
              final quantity =
                  int.tryParse(quantityController.text) ?? currentQuantity;
              final notes = notesController.text.trim();
              Get.back();
              _updateQuantity(
                int.parse(item['product_id'].toString()),
                quantity,
                notes.isEmpty ? null : notes,
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1729),
        elevation: 0,
        title: const Text(
          'My Wishlist',
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
          if (wishlistItems.isNotEmpty)
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEF4444), Color(0xFFF87171)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.delete_sweep, color: Colors.white),
                tooltip: 'Clear Wishlist',
                onPressed: _clearWishlist,
              ),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await authController.clearUser();
              Get.offAllNamed(AppRoutes.login);
            },
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
        child: RefreshIndicator(
          onRefresh: _loadWishlist,
          color: const Color(0xFF17A2B8),
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF17A2B8),
                    ),
                  ),
                )
              : errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        errorMessage,
                        style: const TextStyle(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadWishlist,
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
              : wishlistItems.isEmpty
              ? Center(
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
                          Icons.shopping_cart_outlined,
                          size: 80,
                          color: Color(0xFF17A2B8),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Your wishlist is empty',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Browse wholesale products and add items\nto your wishlist for easy ordering',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () =>
                            Get.toNamed(AppRoutes.retailerPurchasing),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF17A2B8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.shopping_bag),
                        label: const Text(
                          'Browse Products',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Summary Card
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF17A2B8), Color(0xFF0FB5D4)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF17A2B8).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Total Items',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '${wishlistItems.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Total Quantity',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '${wishlistItems.fold<int>(0, (sum, item) {
                                  final qty = item['quantity'];
                                  final quantity = qty is int ? qty : int.tryParse(qty.toString()) ?? 0;
                                  return sum + quantity;
                                })}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Wishlist Items
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: wishlistItems.length,
                        itemBuilder: (context, index) {
                          final item = wishlistItems[index];
                          final product = item['product'];
                          final wholesaler = item['wholesaler'];

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
                                  leading: Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      gradient: LinearGradient(
                                        colors: [
                                          const Color(
                                            0xFF17A2B8,
                                          ).withOpacity(0.3),
                                          const Color(
                                            0xFF0FB5D4,
                                          ).withOpacity(0.2),
                                        ],
                                      ),
                                    ),
                                    child:
                                        product['image_url'] != null &&
                                            product['image_url']
                                                .toString()
                                                .isNotEmpty
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            child: Image.network(
                                              product['image_url'],
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                    return const Icon(
                                                      Icons.inventory_2,
                                                      size: 32,
                                                      color: Color(0xFF17A2B8),
                                                    );
                                                  },
                                            ),
                                          )
                                        : const Icon(
                                            Icons.inventory_2,
                                            size: 32,
                                            color: Color(0xFF17A2B8),
                                          ),
                                  ),
                                  title: Text(
                                    product['name'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Text(
                                        'Wholesaler: ${wholesaler['name']}',
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Qty: ${item['quantity']} | \$${product['price']}',
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 13,
                                        ),
                                      ),
                                      if (item['notes'] != null &&
                                          item['notes'].toString().isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 4,
                                          ),
                                          child: Text(
                                            '📝 ${item['notes']}',
                                            style: const TextStyle(
                                              color: Color(0xFF17A2B8),
                                              fontSize: 12,
                                              fontStyle: FontStyle.italic,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                // Action buttons row at bottom (like dashboard cards)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.2),
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(16),
                                      bottomRight: Radius.circular(16),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      if (product['category'] != null)
                                        Expanded(
                                          child: Text(
                                            'Category: ${product['category']}',
                                            style: TextStyle(
                                              color: Colors.grey[500],
                                              fontSize: 12,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      const SizedBox(width: 8),
                                      ElevatedButton.icon(
                                        onPressed: () => _showEditDialog(item),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF17A2B8,
                                          ),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        icon: const Icon(Icons.edit, size: 16),
                                        label: const Text('Edit'),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton.icon(
                                        onPressed: () => _removeFromWishlist(
                                          int.parse(
                                            item['product_id'].toString(),
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFFEF4444,
                                          ),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        icon: const Icon(
                                          Icons.delete,
                                          size: 16,
                                        ),
                                        label: const Text('Remove'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ),
      ),
      floatingActionButton: wishlistItems.isNotEmpty
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.extended(
                  onPressed: () => _orderFromWishlist(clearAfter: false),
                  backgroundColor: const Color(0xFF17A2B8),
                  elevation: 8,
                  heroTag: 'order_keep',
                  icon: const Icon(
                    Icons.shopping_cart_checkout,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Order (Keep Wishlist)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                FloatingActionButton.extended(
                  onPressed: () => _orderFromWishlist(clearAfter: true),
                  backgroundColor: const Color(0xFF10B981),
                  elevation: 8,
                  heroTag: 'order_clear',
                  icon: const Icon(
                    Icons.playlist_add_check,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Order & Clear',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            )
          : null,
    );
  }
}
