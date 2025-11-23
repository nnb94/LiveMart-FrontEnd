import 'package:get/get.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import 'auth_controller.dart';

class WishlistController extends GetxController {
  final ApiService apiService;
  final AuthController authController;
  final ProductService productService;

  // Map<Product, quantity> to track quantity per product in wishlist
  var wishlist = <Product, int>{}.obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  WishlistController({
    required this.apiService,
    required this.authController,
    required this.productService,
  });

  @override
  void onInit() {
    super.onInit();
    fetchWishlist();
  }

  Future<void> fetchWishlist() async {
    if (!authController.isLoggedIn) {
      errorMessage.value = 'User not logged in';
      wishlist.clear();
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final token = authController.accessToken.value;
      // API should return list of objects with Product and quantity fields
      final fetchedProductsWithQuantities = await apiService.fetchWishlistWithQuantities(token);

      wishlist.clear();
      for (var item in fetchedProductsWithQuantities) {
        wishlist[item.product] = item.quantity;
      }
    } catch (e) {
      errorMessage.value = 'Failed to load wishlist: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeFromWishlist(int productId, {int? quantity}) async {
    if (!authController.isLoggedIn) {
      errorMessage.value = 'User not logged in';
      return;
    }

    try {
      final token = authController.accessToken.value;
      final currentQuantity = wishlist.entries.firstWhere((e) => e.key.id == productId).value;

      bool success;
      if (quantity == null || quantity >= currentQuantity) {
        // Remove entire product from wishlist
        success = await apiService.removeFromWishlist(token, productId);
        if (success) {
          wishlist.removeWhere((product, _) => product.id == productId);
        }
      } else {
        // Update quantity in wishlist and backend
        success = await apiService.updateWishlistQuantity(token, productId, currentQuantity - quantity);
        if (success) {
          wishlist.update(
            wishlist.keys.firstWhere((p) => p.id == productId),
            (q) => q - quantity,
          );
        }
      }

      if (!success) {
        errorMessage.value = 'Failed to remove item from wishlist';
      }
    } catch (e) {
      errorMessage.value = 'Error removing item: $e';
    }
  }

  Future<void> addToWishlist(int productId, {int quantity = 1}) async {
    if (!authController.isLoggedIn) {
      errorMessage.value = 'User not logged in';
      return;
    }
    try {
      final token = authController.accessToken.value;
      final success = await apiService.addToWishlistWithQuantity(token, productId, quantity);
      if (success) {
        final product = productService.products.firstWhere((p) => p.id == productId);
        if (wishlist.containsKey(product)) {
          wishlist.update(product, (existingQty) => existingQty + quantity);
        } else {
          wishlist[product] = quantity;
        }
      } else {
        errorMessage.value = 'Failed to add item to wishlist';
      }
    } catch (e) {
      errorMessage.value = 'Error adding item: $e';
    }
  }
}
