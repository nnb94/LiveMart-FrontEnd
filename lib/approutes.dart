import 'package:get/get.dart';
import 'screens/email_screen.dart';
import 'screens/otp_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
<<<<<<< HEAD
import 'package:live_mart_app/screens/customers/dashboard.dart';
import 'package:live_mart_app/screens/customers/profile.dart';
import 'package:live_mart_app/screens/customers/wishlist.dart';
import 'package:live_mart_app/screens/customers/cart.dart';
import 'package:live_mart_app/screens/customers/placeorder.dart';
import 'package:live_mart_app/screens/customers/orders.dart';
import 'package:live_mart_app/screens/customers/notifications.dart';
=======
import 'screens/forgot_password_screen.dart';
import 'screens/reset_password_screen.dart';

// Role-based dashboards
import 'screens/customer/dashboard.dart';
import 'screens/retailer/dashboard.dart';
import 'screens/wholesaler/dashboard.dart';

>>>>>>> 0bb10425825846f14adf649e36ea33dd7be99916

class AppRoutes {
  static const String email = '/email';
  static const String otp = '/otp';
  static const String dashboard = '/dashboard';
  static const String login = '/login';
  static const String register = '/register';
  static const String initial = email;
<<<<<<< HEAD
  static const String customersDashboard = '/customers/dashboard';
  static const String customersProfile = '/customers/profile';
  static const String customersWishlist = '/customers/wishlist';
  static const String customersCart = '/customers/cart';
  static const String customersPlaceOrder = '/customers/placeorder';
  static const String customersOrders = '/customers/orders';
  static const String customersNotifications = '/customers/notifications';
=======
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';


  static const String customerDashboard = '/customer/dashboard';
  static const String retailerDashboard = '/retailer/dashboard';
  static const String wholesalerDashboard = '/wholesaler/dashboard';

>>>>>>> 0bb10425825846f14adf649e36ea33dd7be99916

  static List<GetPage> routes = [
    GetPage(
      name: email,
      page: () => const EmailScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: otp,
      page: () => const OtpScreen(email: ''),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: dashboard,
      page: () => const DashboardScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: login,
      page: () => const LoginScreen(),
      transition: Transition.leftToRight,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: register,
      page: () => const RegisterScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: forgotPassword,
      page: () => const ForgotPasswordScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: resetPassword,
      page: () => const ResetPasswordScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: customerDashboard,
      page: () => const CustomerDashboard(), // or import the correct dashboard from customers folder here
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
<<<<<<< HEAD
      name: customersProfile,
      page: () => const CustomerProfile(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: customersWishlist,
      page: () => const CustomerWishlist(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: customersCart,
      page: () => const CustomerCart(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: customersPlaceOrder,
      page: () => const PlaceOrder(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: customersOrders,
      page: () => const CustomerOrders(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: customersNotifications,
      page: () => const CustomerNotifications(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
=======
      name: retailerDashboard,
      page: () => const RetailerDashboard(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: wholesalerDashboard,
      page: () => const WholesalerDashboard(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
    ),

>>>>>>> 0bb10425825846f14adf649e36ea33dd7be99916
  ];
}
