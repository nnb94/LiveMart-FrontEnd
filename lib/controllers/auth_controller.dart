import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  // Observable user data
  final RxInt userId = 0.obs;
  final RxString accessToken = ''.obs;
  final RxString email = ''.obs;
  final RxString role = ''.obs;
  final RxString name = ''.obs;

  // New reactive variables for phone and address with default values
  final RxString phone = '+91 XXXXX XXXXX'.obs;
  final RxString address = 'Home'.obs;

  // Check if user is logged in
  bool get isLoggedIn => accessToken.value.isNotEmpty && userId.value > 0;

  // Save user data after login/signup
  Future<void> saveUser({
    required int userId,
    required String token,
    required String email,
    required String role,
    String? name,
    String? phone,
    String? address,
  }) async {
    this.userId.value = userId;
    this.accessToken.value = token;
    this.email.value = email;
    this.role.value = role;
    if (name != null) this.name.value = name;
    if (phone != null) this.phone.value = phone;
    if (address != null) this.address.value = address;

    // Persist to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', userId);
    await prefs.setString('access_token', token);
    await prefs.setString('email', email);
    await prefs.setString('role', role);
    if (name != null) await prefs.setString('name', name);
    if (phone != null) await prefs.setString('phone', phone);
    if (address != null) await prefs.setString('address', address);
  }

  // Load user data on app start
  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUserId = prefs.getInt('user_id');
    final savedToken = prefs.getString('access_token');
    final savedEmail = prefs.getString('email');
    final savedRole = prefs.getString('role');
    final savedName = prefs.getString('name');
    final savedPhone = prefs.getString('phone');
    final savedAddress = prefs.getString('address');

    if (savedUserId != null && savedToken != null) {
      userId.value = savedUserId;
      accessToken.value = savedToken;
      email.value = savedEmail ?? '';
      role.value = savedRole ?? '';
      name.value = savedName ?? '';
      phone.value = savedPhone ?? '+91 XXXXX XXXXX';
      address.value = savedAddress ?? 'Home';
    }
  }

  // Clear user data on logout
  Future<void> clearUser() async {
    userId.value = 0;
    accessToken.value = '';
    email.value = '';
    role.value = '';
    name.value = '';
    phone.value = '+91 XXXXX XXXXX';
    address.value = 'Home';

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
