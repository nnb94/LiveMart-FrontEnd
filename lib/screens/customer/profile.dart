import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';
import 'package:get/get.dart';
import '../../approutes.dart';

class CustomerProfile extends StatelessWidget {
  const CustomerProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(AuthController());
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 38,
              child: Icon(Icons.person, size: 44),
            ),
            const SizedBox(height: 24),

            Obx(() => Text(
              'Name: ${authController.name.value}',
              style: Theme.of(context).textTheme.titleMedium,
            )),

            Obx(() => Text(
              'Email: ${authController.email.value.isNotEmpty ? authController.email.value : "user@example.com"}',
              style: Theme.of(context).textTheme.titleMedium,
            )),

            Obx(() => Text(
              'Address: ${authController.address.value.isNotEmpty ? authController.address.value : "Not provided"}',
              style: Theme.of(context).textTheme.titleMedium,
            )),

            const Spacer(),

            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text('Edit Profile'),
                onPressed: () {
                  Get.toNamed(AppRoutes.customerEditProfile);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
