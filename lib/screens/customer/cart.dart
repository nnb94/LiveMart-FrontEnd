import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/cart_controller.dart';

class CustomerCart extends StatelessWidget {
  const CustomerCart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: Obx(() {
        if (cartController.cart.isEmpty) {
          return const Center(child: Text('Cart is empty'));
        }
        return ListView.builder(
          itemCount: cartController.cart.length,
          itemBuilder: (context, index) {
            final cartItem = cartController.cart[index];
            return ListTile(
              title: Text(cartItem.product.name),
              subtitle: Text(
                '₹${cartItem.product.price} x ${cartItem.quantity}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () {
                      cartController.decreaseQuantity(cartItem.product);
                    },
                  ),
                  Text('${cartItem.quantity}'),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () {
                      cartController.addToCart(cartItem.product);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      cartController.removeFromCart(cartItem.product);
                    },
                  ),
                ],
              ),
            );
          },
        );
      }),
      bottomNavigationBar: Obx(() => Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Total: ₹${cartController.totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          )),
    );
  }
}
