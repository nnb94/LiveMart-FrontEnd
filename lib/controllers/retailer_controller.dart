import 'package:get/get.dart';
import '../models/retailer_inventory.dart';
import '../models/product.dart';
import '../models/wholesaler_sale.dart';
import '../services/api_service.dart';
import '../controllers/auth_controller.dart';

class RetailerController extends GetxController {
  final ApiService apiService = Get.find<ApiService>();
  final authController = Get.find<AuthController>();

  // Reactive state variables
  var inventory = <RetailerInventoryItem>[].obs;
  var purchaseOrders = <RetailingPurchaseOrder>[].obs;
  var salesOrders = <RetailingSaleOrder>[].obs;
  var availableWholesaleProducts = <AvailableWholesaleProduct>[].obs;
  var lowStockAlerts = <LowStockAlert>[].obs;
  var analytics = Rxn<RetailerAnalytics>();

  // Product cache for images in purchase history
  var productCache = <int, Product>{}.obs;

  // Loading states
  var isLoadingInventory = false.obs;
  var isLoadingPurchases = false.obs;
  var isLoadingSales = false.obs;
  var isLoadingWholesaleProducts = false.obs;
  var isLoadingLowStock = false.obs;
  var isLoadingAnalytics = false.obs;

  // Error states
  var inventoryError = ''.obs;
  var purchasesError = ''.obs;
  var salesError = ''.obs;
  var wholesaleProductsError = ''.obs;
  var lowStockError = ''.obs;
  var analyticsError = ''.obs;

  // Operation loading states
  var isUpdatingInventory = false.obs;
  var isRestocking = false.obs;
  var isPlacingOrder = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Don't load data automatically - wait for auth state
    debounce(authController.accessToken, (_) {
      if (authController.accessToken.value.isNotEmpty && authController.role.value == 'retailer') {
        loadInitialData();
      }
    }, time: const Duration(milliseconds: 100));
  }

  Future<void> loadInitialData() async {
    await Future.wait([
      fetchInventory(),
      fetchWholesaleProducts(),
      fetchLowStockAlerts(),
      fetchPurchaseOrders(),
      fetchSalesOrders(),
    ]);
  }

  String get accessToken => authController.accessToken.value;

  // ================= INVENTORY MANAGEMENT =================

  Future<void> fetchInventory() async {
    try {
      isLoadingInventory(true);
      inventoryError('');

      // Check authentication
      if (accessToken.isEmpty) {
        inventoryError('Authentication required. Please log in as a retailer.');
        return;
      }

      final response = await apiService.getRetailerInventory(accessToken);
      inventory.value = response;

    } catch (e) {
      inventoryError('Failed to load inventory: ${e.toString()}');
      print('Error fetching inventory: $e');
    } finally {
      isLoadingInventory(false);
      update(); // Force UI update
    }
  }

  Future<bool> updateInventoryItem(int productId, {
    int? quantityInStock,
    int? reorderLevel,
  }) async {
    try {
      isUpdatingInventory(true);

      if (accessToken.isEmpty) {
        Get.snackbar('Error', 'Authentication required. Please log in as a retailer.');
        return false;
      }

      final response = await apiService.updateRetailerInventory(
        productId: productId,
        quantityInStock: quantityInStock,
        reorderLevel: reorderLevel,
        accessToken: accessToken,
      );

      // Update local inventory item
      final index = inventory.indexWhere((item) => item.productId == productId);
      if (index != -1) {
        final updatedItem = RetailerInventoryItem.fromJson(response['inventory'] ?? response);
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

      final response = await apiService.restockRetailerInventory(
        productId: productId,
        quantity: quantity,
        accessToken: accessToken,
      );

      // Update local inventory item
      final index = inventory.indexWhere((item) => item.productId == productId);
      if (index != -1) {
        final updatedItem = RetailerInventoryItem.fromJson(response['inventory'] ?? response);
        inventory[index] = updatedItem;
      }

      Get.snackbar('Success', response['message'] ?? 'Product restocked successfully');
      return true;

    } catch (e) {
      Get.snackbar('Error', 'Failed to restock: ${e.toString()}');
      print('Error restocking: $e');
      return false;
    } finally {
      isRestocking(false);
    }
  }

  Future<bool> deleteInventoryItem(int productId) async {
    try {
      if (accessToken.isEmpty) {
        Get.snackbar('Error', 'Authentication required. Please log in as a retailer.');
        return false;
      }

      final response = await apiService.deleteRetailerInventory(
        productId: productId,
        accessToken: accessToken,
      );

      // Remove the item from local inventory
      inventory.removeWhere((item) => item.productId == productId);

      Get.snackbar('Success', response['message'] ?? 'Product removed from inventory successfully');
      return true;

    } catch (e) {
      Get.snackbar('Error', 'Failed to remove product from inventory: ${e.toString()}');
      print('Error deleting inventory item: $e');
      return false;
    }
  }

  Future<void> fetchLowStockAlerts() async {
    try {
      isLoadingLowStock(true);
      lowStockError('');

      final response = await apiService.getRetailerLowStockAlerts(accessToken);
      lowStockAlerts.value = response['low_stock_items'] ?? [];

    } catch (e) {
      lowStockError('Failed to load low stock alerts: ${e.toString()}');
      print('Error fetching low stock alerts: $e');
    } finally {
      isLoadingLowStock(false);
    }
  }

  // ================= WHOLESALE PURCHASING =================

  Future<void> fetchWholesaleProducts() async {
    try {
      isLoadingWholesaleProducts(true);
      wholesaleProductsError('');

      if (accessToken.isEmpty) {
        wholesaleProductsError('Authentication required to browse products.');
        return;
      }

      // Backend already filters products based on user role!
      // Retailers get only wholesaler products with complete inventory data
      final products = await apiService.getProducts(accessToken: accessToken);

      // Map directly to AvailableWholesaleProduct using backend-provided data
      final wholesaleProducts = products.map((product) {
        return AvailableWholesaleProduct(
          product: product,
          sellerId: product.sellerId,
          sellerName: product.sellerName ?? 'Unknown Seller', // Backend provides this
          availableStock: product.stockQuantity ?? 0, // Backend provides wholesaler stock
          minimumOrderQuantity: product.minimumOrderQuantity ?? 10, // Backend provides min qty
          reorderLevel: product.reorderLevel ?? 10,
          needsRestock: product.needsRestock ?? false,
        );
      }).toList();

      availableWholesaleProducts.value = wholesaleProducts;

    } catch (e) {
      wholesaleProductsError('Failed to load wholesale products: ${e.toString()}');
      print('Error fetching wholesale products: $e');
    } finally {
      isLoadingWholesaleProducts(false);
    }
  }

  Future<void> fetchPurchaseOrders() async {
    try {
      isLoadingPurchases(true);
      purchasesError('');

      final response = await apiService.getRetailerPurchaseOrders(accessToken);
      purchaseOrders.value = response;

      // Pre-cache product images after loading orders
      await fetchAndCacheProductsForPurchaseHistory(response);

    } catch (e) {
      purchasesError('Failed to load purchase orders: ${e.toString()}');
      print('Error fetching purchase orders: $e');
    } finally {
      isLoadingPurchases(false);
      update(); // Force UI update
    }
  }

  // Product image caching for purchase history
  Future<void> fetchAndCacheProductsForPurchaseHistory(List<RetailingPurchaseOrder> orders) async {
    try {
      // Extract unique product IDs from all orders (product_id is directly on the order object)
      final productIds = orders.map((order) => order.productId ?? 0)
                               .where((id) => id > 0)
                               .toSet();

      if (productIds.isEmpty) return;

      // Fetch all available wholesale products (retailers see only wholesaler products)
      final allProducts = await apiService.getProducts(accessToken: accessToken);

      // Create cache map for the products we've purchased
      final newCache = <int, Product>{};
      for (final product in allProducts) {
        if (productIds.contains(product.id)) {
          newCache[product.id] = product;
        }
      }

      productCache.value = newCache;

    } catch (e) {
      print('Error caching products for purchase history: $e');
      // Don't throw error - images are nice to have but not critical
    }
  }

  // Helper method to get product image URL for purchase history
  String? getProductImageUrl(int? productId) {
    if (productId == null) return null;
    return productCache[productId]?.imageUrl;
  }

  Future<bool> placeWholesaleOrder(List<Map<String, dynamic>> products) async {
    try {
      isPlacingOrder(true);

      final response = await apiService.placeRetailerWholesaleOrder(
        products: products,
        accessToken: accessToken,
      );

      Get.snackbar('Success', 'Wholesale order placed successfully!');

      // Refresh inventory and purchase orders
      await Future.wait([
        fetchInventory(),
        fetchPurchaseOrders(),
      ]);

      return true;

    } catch (e) {
      Get.snackbar('Error', 'Failed to place order: ${e.toString()}');
      print('Error placing wholesale order: $e');
      return false;
    } finally {
      isPlacingOrder(false);
    }
  }

  // ================= RETAIL SALES =================

  Future<void> fetchSalesOrders() async {
    try {
      isLoadingSales(true);
      salesError('');

      final response = await apiService.getRetailerSalesOrders(accessToken);
      salesOrders.value = response;

    } catch (e) {
      salesError('Failed to load sales orders: ${e.toString()}');
      print('Error fetching sales orders: $e');
    } finally {
      isLoadingSales(false);
      update(); // Force UI update
    }
  }

  Future<bool> updateSaleOrderStatus(int orderId, String status) async {
    try {
      // For now, use customer order update if available
      // This might need a separate retailer endpoint
      Get.snackbar('Info', 'Order status management coming soon');
      return true;

    } catch (e) {
      Get.snackbar('Error', 'Failed to update order status: ${e.toString()}');
      print('Error updating sale order status: $e');
      return false;
    }
  }

  // ================= ANALYTICS =================

  Future<void> fetchAnalytics() async {
    try {
      isLoadingAnalytics(true);
      analyticsError('');

      // Ensure we have a valid token before making the call
      if (accessToken.isEmpty) {
        throw Exception('No access token available. Please log in again.');
      }

      if (authController.role.value != 'retailer') {
        throw Exception('Access denied. Only retailers can view this data.');
      }

      // Fetch sales orders and purchase orders for analytics
      await Future.wait([
        fetchSalesOrders(),
        fetchPurchaseOrders(),
      ]);

      // Use real backend data from sales orders
      final salesData = salesOrders.value;
      final purchasesData = purchaseOrders.value;

      // Calculate analytics from real sales data
      final totalRevenue = salesData.fold<double>(0.0,
        (sum, order) => sum + (order.orderDetails.price * order.orderDetails.quantity));

      analytics.value = RetailerAnalytics(
        summary: Summary(
          totalOrders: salesData.length,
          totalRevenue: totalRevenue,
          averageOrderValue: salesData.isEmpty ? 0 : totalRevenue / salesData.length,
          totalUnitsSold: salesData.fold<int>(0, (sum, order) => sum + order.orderDetails.quantity),
          uniqueBuyers: salesData.map((order) => order.buyerId).toSet().length,
        ),
      );



    } catch (e) {
      analyticsError('Failed to load analytics: ${e.toString()}');
      analytics.value = null; // Clear on error
      print('Error fetching analytics: $e');
    } finally {
      isLoadingAnalytics(false);
    }
  }

  // ================= HELPERS =================

  RetailerInventoryItem? getInventoryItem(int productId) {
    return inventory.firstWhereOrNull((item) => item.productId == productId);
  }

  int getLowStockCount() {
    return inventory.where((item) => item.quantityInStock <= item.reorderLevel).length;
  }

  double getTotalInventoryValue() {
    return inventory.fold<double>(0.0, (sum, item) => sum + (item.price * item.quantityInStock));
  }

  double getTotalPurchaseValue() {
    return purchaseOrders.fold<double>(0.0, (sum, order) => sum + (order.orderDetails.price * order.orderDetails.quantity));
  }

  double getTotalSalesValue() {
    return salesOrders.fold<double>(0.0, (sum, order) => sum + (order.orderDetails.price * order.orderDetails.quantity));
  }
}
