import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/wholesaler_inventory.dart';
import '../models/product.dart';
import '../models/wholesaler_sale.dart';
import '../services/api_service.dart';
import '../controllers/auth_controller.dart';

class WholesalerController extends GetxController {
  final ApiService apiService = Get.find<ApiService>();
  final authController = Get.find<AuthController>();

  // Reactive state variables
  var inventory = <WholesalerInventoryItem>[].obs;
  var salesOrders = <WholesalerSale>[].obs;
  var products = <Product>[].obs;
  var analytics = Rxn<WholesalerAnalytics>();

  // Product cache for images throughout the system
  var productCache = <int, Product>{}.obs;

  // Loading states
  var isLoadingInventory = false.obs;
  var isLoadingSales = false.obs;
  var isLoadingProducts = false.obs;
  var isLoadingAnalytics = false.obs;

  // Error states
  var inventoryError = ''.obs;
  var salesError = ''.obs;
  var productsError = ''.obs;
  var analyticsError = ''.obs;

  // Operation loading states
  var isAddingProduct = false.obs;
  var isUpdatingProduct = false.obs;
  var isDeletingProduct = false.obs;
  var isUpdatingInventory = false.obs;
  var isRestocking = false.obs;
  var isUpdatingOrderStatus = false.obs;

  // Access token via getter

  String get accessToken => authController.accessToken.value;

  @override
  void onInit() {
    super.onInit();
    // Debug: Check initial values
    print('🔍 WholesalerController: Init - Role: ${authController.role.value}, Token: ${authController.accessToken.value.isNotEmpty ? "present" : "empty"}');

    // Don't load data automatically - wait for auth state
    debounce(authController.accessToken, (_) {
      print('🔍 WholesalerController: Token changed - Role: ${authController.role.value}, Token: ${authController.accessToken.value.isNotEmpty ? "present" : "empty"}');
      if (authController.accessToken.value.isNotEmpty && authController.role.value == 'wholesaler') {
        loadInitialData();
      }
    }, time: const Duration(milliseconds: 100));
  }

  Future<void> loadInitialData() async {
    print('🟡 WholesalerController: Loading initial data for role: ${authController.role.value}');
    await Future.wait([fetchInventory(), fetchProducts(), fetchSalesOrders()]);
    print('🟢 WholesalerController: Initial data loaded successfully');
  }

  // ================= INVENTORY MANAGEMENT =================

  Future<void> fetchInventory() async {
    try {
      isLoadingInventory(true);
      inventoryError('');

      final response = await apiService.getWholesalerInventory(accessToken);

      inventory.value = response;
    } catch (e) {
      final errorMessage = 'Failed to load inventory: ${e.toString()}';
      inventoryError(errorMessage);
      print('Error fetching inventory: $e');

      Get.snackbar(
        'Inventory Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFF3366),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(16),
        borderRadius: 15,
      );
    } finally {
      isLoadingInventory(false);
      update(); // Force UI update
    }
  }

  Future<bool> updateInventoryItem(
    int productId, {
    int? quantityInStock,
    int? minimumOrderQuantity,
  }) async {
    try {
      isUpdatingInventory(true);

      final response = await apiService.updateWholesalerInventory(
        productId: productId,
        quantityInStock: quantityInStock,
        minimumOrderQuantity: minimumOrderQuantity,
        accessToken: accessToken,
      );

      // Update local inventory item
      final index = inventory.indexWhere((item) => item.productId == productId);
      if (index != -1) {
        final updatedItem = WholesalerInventoryItem.fromJson(response);
        inventory[index] = updatedItem;
      }

      Get.snackbar('Success', 'Inventory updated successfully');
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to update inventory: ${e.toString()}');
      print('Error updating inventory: $e');
      return false;
    } finally {
      isUpdatingInventory(false);
    }
  }

  Future<bool> restockProduct(int productId, int quantity) async {
    try {
      isRestocking(true);

      final response = await apiService.restockWholesalerInventory(
        productId: productId,
        quantity: quantity,
        accessToken: accessToken,
      );

      // Update local inventory item
      final index = inventory.indexWhere((item) => item.productId == productId);
      if (index != -1) {
        final updatedItem = WholesalerInventoryItem.fromJson(
          response['inventory'],
        );
        inventory[index] = updatedItem;
      }

      Get.snackbar('Success', response['message']);
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to restock: ${e.toString()}');
      print('Error restocking: $e');
      return false;
    } finally {
      isRestocking(false);
    }
  }

  // ================= PRODUCT MANAGEMENT =================

  Future<void> fetchProducts() async {
    try {
      isLoadingProducts(true);
      productsError('');

      final response = await apiService.getWholesalerProducts(accessToken);
      products.value = response;

      // Debug: Check what products contain
      print('DEBUG: Fetched ${products.length} products');
      for (var product in products) {
        print('Product ${product.id}: "${product.name}" - Image URL: ${product.imageUrl ?? "NULL"}');
      }
    } catch (e) {
      productsError('Failed to load products: ${e.toString()}');
      print('Error fetching products: $e');
      // Sync cache with products list
      _syncProductCache();
    } finally {
      isLoadingProducts(false);
      update(); // Force UI update
    }
  }

  Future<bool> addProduct({
    required String name,
    required String description,
    required double price,
    required String category,
    required int initialStock,
    required int minimumOrderQuantity,
  }) async {
    try {
      isAddingProduct(true);

      await apiService.addProduct(
        name: name,
        description: description,
        price: price,
        category: category,
        initialStock: initialStock,
        minimumOrderQuantity: minimumOrderQuantity,
        accessToken: accessToken,
      );

      Get.snackbar('Success', 'Product added successfully');

      // Refresh inventory and products
      await Future.wait([fetchInventory(), fetchProducts()]);
      _syncProductCache(); // Sync cache after adding
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to add product: ${e.toString()}');
      print('Error adding product: $e');
      return false;
    } finally {
      isAddingProduct(false);
    }
  }

  Future<bool> addProductWithImage({
    required String name,
    required String description,
    required double price,
    required String category,
    required int initialStock,
    required int minimumOrderQuantity,
    required Map<String, dynamic> imageData,
  }) async {
    try {
      isAddingProduct(true);

      await apiService.addProductWithImage(
        name: name,
        description: description,
        price: price,
        category: category,
        initialStock: initialStock,
        minimumOrderQuantity: minimumOrderQuantity,
        imageData: imageData,
        accessToken: accessToken,
      );

      Get.snackbar('Success', 'Product added successfully');

      // Refresh inventory and products
      await Future.wait([fetchInventory(), fetchProducts()]);
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to add product: ${e.toString()}');
      print('Error adding product with image: $e');
      return false;
    } finally {
      isAddingProduct(false);
    }
  }

  Future<bool> updateProduct(
    int productId, {
    String? name,
    String? description,
    double? price,
    String? category,
  }) async {
    try {
      isUpdatingProduct(true);

      await apiService.updateProduct(
        productId: productId,
        name: name,
        description: description,
        price: price,
        category: category,
        accessToken: accessToken,
      );

      Get.snackbar('Success', 'Product updated successfully');

      // Refresh products
      await fetchProducts();
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to update product: ${e.toString()}');
      print('Error updating product: $e');
      return false;
    } finally {
      isUpdatingProduct(false);
    }
  }

  // ================= SALES MANAGEMENT =================

  Future<void> fetchSalesOrders() async {
    try {
      isLoadingSales(true);
      salesError('');

      final response = await apiService.getWholesalerSales(accessToken);
      salesOrders.value = response;
    } catch (e) {
      salesError('Failed to load sales orders: ${e.toString()}');
      print('Error fetching sales: $e');
    } finally {
      isLoadingSales(false);
      update(); // Force UI update
    }
  }

  Future<bool> updateOrderStatus(int orderId, String status) async {
    try {
      isUpdatingOrderStatus(true);

      final response = await apiService.updateWholesalerOrderStatus(
        orderId: orderId,
        status: status,
        accessToken: accessToken,
      );

      // Update local order status (response is just success message, not full order)
      final index = salesOrders.indexWhere((order) => order.orderId == orderId);
      if (index != -1) {
        // Create updated order with new status
        final existingOrder = salesOrders[index];
        final updatedOrder = WholesalerSale(
          orderId: existingOrder.orderId,
          buyerId: existingOrder.buyerId,
          retailerName: existingOrder.retailerName,
          retailerEmail: existingOrder.retailerEmail,
          productInfo: existingOrder.productInfo,
          orderDetails: existingOrder.orderDetails,
          orderDate: existingOrder.orderDate,
          status: status,  // Only update the status field
        );
        salesOrders[index] = updatedOrder;
      }

      Get.snackbar('Success', 'Order status updated');
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to update order status: ${e.toString()}');
      print('Error updating order status: $e');
      return false;
    } finally {
      isUpdatingOrderStatus(false);
      update(); // Force UI update since we modified the list
    }
  }

  // ================= ANALYTICS =================

  Future<void> fetchAnalytics() async {
    try {
      isLoadingAnalytics(true);
      analyticsError('');

      final response = await apiService.getWholesalerAnalytics(accessToken);
      analytics.value = response;
    } catch (e) {
      analyticsError('Failed to load analytics: ${e.toString()}');
      print('Error fetching analytics: $e');
    } finally {
      isLoadingAnalytics(false);
    }
  }

  // ================= PRODUCT MANAGEMENT =================

  Future<bool> deleteProduct(int productId) async {
    try {
      isDeletingProduct(true);

      final response = await apiService.deleteProduct(
        productId: productId,
        accessToken: accessToken,
      );

      Get.snackbar('Success', 'Product deleted successfully');

      // Remove from local products list
      products.removeWhere((product) => product.id == productId);
      // Also remove from inventory if exists
      inventory.removeWhere((item) => item.productId == productId);

      return true;

    } catch (e) {
      Get.snackbar('Error', 'Failed to delete product: ${e.toString()}');
      print('Error deleting product: $e');
      return false;
    } finally {
      isDeletingProduct(false);
    }
  }

  // ================= HELPERS =================

  WholesalerInventoryItem? getInventoryItem(int productId) {
    return inventory.firstWhereOrNull((item) => item.productId == productId);
  }

  Product? getProduct(int productId) {
    return products.firstWhereOrNull((product) => product.id == productId);
  }

  // Workaround: Find corresponding Product for WholesalerInventoryItem to get imageUrl
  Product? getProductForInventoryItem(WholesalerInventoryItem inventoryItem) {
    return getProduct(inventoryItem.productId);
  }

  // Helper to get image URL for inventory items
  String? getImageUrlForInventoryItem(WholesalerInventoryItem inventoryItem) {
    return getProductForInventoryItem(inventoryItem)?.imageUrl;
  }

  // Helper method to get product image URL (similar to retailers)
  String? getProductImageUrl(int? productId) {
    if (productId == null) return null;
    return getProduct(productId)?.imageUrl;
  }

  // Helper method to get product image URL by product name (for sales orders)
  String? getProductImageUrlByName(String productName) {
    final product = products.firstWhereOrNull((p) => p.name == productName);
    return product?.imageUrl;
  }

  // Cache products for image access (sync with products list)
  void _syncProductCache() {
    final newCache = <int, Product>{};
    for (final product in products) {
      newCache[product.id] = product;
    }
    productCache.value = newCache;
  }

  int getLowStockCount() {
    return inventory
        .where(
          (item) => item.quantityInStock < (item.minimumOrderQuantity ~/ 2),
        )
        .length;
  }

  double getTotalInventoryValue() {
    return inventory.fold(
      0.0,
      (sum, item) => sum + (item.price * item.quantityInStock),
    );
  }
}
