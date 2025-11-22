import 'package:get/get.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import 'auth_controller.dart';


class WishlistController extends GetxController {
  final ApiService apiService;
  final AuthController authController;
  final ProductService productService;  // Add ProductService field

  WishlistController({
    required this.apiService,
    required this.authController,
    required this.productService,
  });

  var wishlist = <Product>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

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
      final fetchedProducts = await apiService.fetchWishlist(token);
      wishlist.value = fetchedProducts;
    } catch (e) {
      errorMessage.value = 'Failed to load wishlist: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeFromWishlist(int productId) async {
    if (!authController.isLoggedIn) {
      errorMessage.value = 'User not logged in';
      return;
    }

    try {
      final token = authController.accessToken.value;
      final success = await apiService.removeFromWishlist(token, productId);
      if (success) {
        wishlist.removeWhere((product) => product.id == productId);
      } else {
        errorMessage.value = 'Failed to remove item from wishlist';
      }
    } catch (e) {
      errorMessage.value = 'Error removing item: $e';
    }
  }

  Future<void> addToWishlist(int productId) async {
    if (!authController.isLoggedIn) {
      errorMessage.value = 'User not logged in';
      return;
    }
    try {
      final token = authController.accessToken.value;
      final success = await apiService.addToWishlist(token, productId);
      if (success) {
        final product = productService.products.firstWhere((p) => p.id == productId);
        wishlist.add(product);
      } else {
        errorMessage.value = 'Failed to add item to wishlist';
      }
    } catch (e) {
      errorMessage.value = 'Error adding item: $e';
    }
  }
}
