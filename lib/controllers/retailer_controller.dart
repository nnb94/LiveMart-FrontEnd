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

      // Get products route returns all products but we filter for wholesalers
      final allProducts = await apiService.getProducts(accessToken: accessToken);

      // Filter for products from wholesalers only
      final wholesaleProducts = allProducts.where((product) {
        // This filtering might need backend support, for now we'll get all
        return true; // Backend should handle role-based filtering
      }).map((product) {
        // Ensure product has valid values to prevent null errors
        return AvailableWholesaleProduct(
          product: product,
          sellerId: product.sellerId,
          sellerName: '', // Need to get from backend
          availableStock: product.stockQuantity ?? 0,
          minimumOrderQuantity: product.minimumOrderQuantity ?? 10,
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

    } catch (e) {
      purchasesError('Failed to load purchase orders: ${e.toString()}');
      print('Error fetching purchase orders: $e');
    } finally {
      isLoadingPurchases(false);
    }
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

      // For now, use a basic analytics structure
      // This might need a separate retailer analytics endpoint
      analytics.value = RetailerAnalytics(
        summary: Summary(
          totalOrders: salesOrders.length,
          totalRevenue: salesOrders.fold<double>(0, (sum, order) => sum + (order.orderDetails.price * order.orderDetails.quantity)),
          averageOrderValue: salesOrders.isEmpty ? 0 : salesOrders.fold<double>(0, (sum, order) => sum + (order.orderDetails.price * order.orderDetails.quantity)) / salesOrders.length,
          totalUnitsSold: salesOrders.fold<int>(0, (sum, order) => sum + order.orderDetails.quantity),
          uniqueBuyers: salesOrders.map((order) => order.buyerId).toSet().length,
        ),
      );

    } catch (e) {
      analyticsError('Failed to load analytics: ${e.toString()}');
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
