import 'package:get/get.dart';
import '../models/product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class CartController extends GetxController {
  var cart = <CartItem>[].obs;

  void addToCart(Product product) {
    final index = cart.indexWhere((item) => item.product.id == product.id);
    if (index != -1) {
      cart[index].quantity++;
      cart.refresh();
    } else {
      cart.add(CartItem(product: product, quantity: 1));
    }
  }

  void removeFromCart(Product product) {
    cart.removeWhere((item) => item.product.id == product.id);
  }

  void decreaseQuantity(Product product) {
    final index = cart.indexWhere((item) => item.product.id == product.id);
    if (index != -1 && cart[index].quantity > 1) {
      cart[index].quantity--;
      cart.refresh();
    } else {
      removeFromCart(product);
    }
  }

  void clearCart() {
    cart.clear();
  }

  int get totalItems => cart.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice =>
      cart.fold(0.0, (sum, item) => sum + item.product.price * item.quantity);
}
