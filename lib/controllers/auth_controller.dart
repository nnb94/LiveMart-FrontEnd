import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  // Observable user data
  final RxInt userId = 0.obs;
  final RxString accessToken = ''.obs;
  final RxString email = ''.obs;
  final RxString role = ''.obs;
  final RxString name = ''.obs;
  
  // Check if user is logged in
  bool get isLoggedIn => accessToken.value.isNotEmpty && userId.value > 0;
  
  // Save user data after login/signup
  Future<void> saveUser({
    required int userId,
    required String token,
    required String email,
    required String role,
    String? name,
  }) async {
    this.userId.value = userId;
    this.accessToken.value = token;
    this.email.value = email;
    this.role.value = role;
    if (name != null) this.name.value = name;
    
    // Persist to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', userId);
    await prefs.setString('access_token', token);
    await prefs.setString('email', email);
    await prefs.setString('role', role);
    if (name != null) await prefs.setString('name', name);
  }
  
  // Load user data on app start
  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUserId = prefs.getInt('user_id');
    final savedToken = prefs.getString('access_token');
    final savedEmail = prefs.getString('email');
    final savedRole = prefs.getString('role');
    final savedName = prefs.getString('name');
    
    if (savedUserId != null && savedToken != null) {
      userId.value = savedUserId;
      accessToken.value = savedToken;
      email.value = savedEmail ?? '';
      role.value = savedRole ?? '';
      name.value = savedName ?? '';
    }
  }
  
  // Clear user data on logout
  Future<void> clearUser() async {
    userId.value = 0;
    accessToken.value = '';
    email.value = '';
    role.value = '';
    name.value = '';
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
