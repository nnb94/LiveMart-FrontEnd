import 'package:get/get.dart';
import '../models/order.dart';
import '../services/api_service.dart';

class CustomerOrdersController extends GetxController {
  var recentOrders = <Order>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  final ApiService apiService = Get.find();
  final int customerId;
  final String accessToken;

  CustomerOrdersController({required this.customerId, required this.accessToken});

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  void fetchOrders() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final orders = await apiService.fetchRecentOrders(customerId, accessToken);
      recentOrders.value = orders;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
