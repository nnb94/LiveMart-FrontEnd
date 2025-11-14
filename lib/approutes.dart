import 'package:get/get.dart';
import 'screens/email_screen.dart';
import 'screens/otp_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'package:live_mart_app/screens/customers/dashboard.dart';
import 'package:live_mart_app/screens/customers/profile.dart';
import 'package:live_mart_app/screens/customers/wishlist.dart';
import 'package:live_mart_app/screens/customers/cart.dart';
import 'package:live_mart_app/screens/customers/placeorder.dart';
import 'package:live_mart_app/screens/customers/orders.dart';
import 'package:live_mart_app/screens/customers/notifications.dart';

class AppRoutes {
  static const String email = '/email';
  static const String otp = '/otp';
  static const String dashboard = '/dashboard';
  static const String login = '/login';
  static const String register = '/register';
  static const String initial = email;
  static const String customersDashboard = '/customers/dashboard';
  static const String customersProfile = '/customers/profile';
  static const String customersWishlist = '/customers/wishlist';
  static const String customersCart = '/customers/cart';
  static const String customersPlaceOrder = '/customers/placeorder';
  static const String customersOrders = '/customers/orders';
  static const String customersNotifications = '/customers/notifications';

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
      name: customersDashboard,
      page: () => const CustomerDashboard(), // or import the correct dashboard from customers folder here
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
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
  ];
}
