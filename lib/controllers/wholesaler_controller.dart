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

  final String accessToken = Get.find<AuthController>().accessToken.value;

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    await Future.wait([
      fetchInventory(),
      fetchProducts(),
    ]);
  }

  // ================= INVENTORY MANAGEMENT =================

  Future<void> fetchInventory() async {
    try {
      isLoadingInventory(true);
      inventoryError('');

      final response = await apiService.getWholesalerInventory(accessToken);
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
        final updatedItem = WholesalerInventoryItem.fromJson(response['inventory']);
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

    } catch (e) {
      productsError('Failed to load products: ${e.toString()}');
      print('Error fetching products: $e');
    } finally {
      isLoadingProducts(false);
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

      final response = await apiService.addProduct(
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
      return true;

    } catch (e) {
      Get.snackbar('Error', 'Failed to add product: ${e.toString()}');
      print('Error adding product: $e');
      return false;
    } finally {
      isAddingProduct(false);
    }
  }

  Future<bool> updateProduct(int productId, {
    String? name,
    String? description,
    double? price,
    String? category,
  }) async {
    try {
      isUpdatingProduct(true);

      final response = await apiService.updateProduct(
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

      // Update local orders list
      final index = salesOrders.indexWhere((order) => order.orderId == orderId);
      if (index != -1) {
        final updatedOrder = WholesalerSale.fromJson(response);
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

  int getLowStockCount() {
    return inventory.where((item) => item.quantityInStock < (item.minimumOrderQuantity ~/ 2)).length;
  }

  double getTotalInventoryValue() {
    return inventory.fold(0.0, (sum, item) => sum + (item.price * item.quantityInStock));
  }
}
