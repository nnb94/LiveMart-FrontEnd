
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'screens/email_screen.dart';
import 'screens/otp_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'package:live_mart_app/screens/customer/dashboard.dart';
import 'package:live_mart_app/screens/customer/profile.dart';
import 'package:live_mart_app/screens/customer/wishlist.dart';
import 'package:live_mart_app/screens/customer/cart.dart';
import 'package:live_mart_app/screens/customer/placeorder.dart';
import 'package:live_mart_app/screens/customer/orders.dart';
import 'package:live_mart_app/screens/customer/notifications.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/reset_password_screen.dart';


// Role-based dashboards
import 'screens/retailer/dashboard.dart';
import 'screens/retailer/inventory.dart';
import 'screens/retailer/purchasing.dart';
import 'screens/retailer/sales.dart';
import 'screens/retailer/analytics.dart';
import 'screens/retailer/purchase_history.dart';
import 'screens/retailer/review_management.dart';
import 'screens/wholesaler/dashboard.dart';
import 'screens/wholesaler/inventory.dart';
import 'screens/wholesaler/sales.dart';
import 'screens/wholesaler/products.dart';
import 'screens/wholesaler/analytics.dart';
import 'screens/wholesaler/review_management.dart';

import 'screens/customer/editprofile.dart';

// Role-based dashboards
import 'screens/customer/dashboard.dart';
import 'screens/retailer/dashboard.dart';
import 'screens/wholesaler/dashboard.dart';

class AppRoutes {
  static const String email = '/email';
  static const String otp = '/otp';
  static const String dashboard = '/dashboard';
  static const String login = '/login';
  static const String register = '/register';
  static const String initial = email;

  static const String customerDashboard = '/customer/dashboard';
  static const String customerProfile = '/customer/profile';
  static const String customerWishlist = '/customer/wishlist';
  static const String customerCart = '/customer/cart';
  static const String customerPlaceOrder = '/customer/placeorder';
  static const String customerOrders = '/customer/orders';
  static const String customerNotifications = '/customer/notifications';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String retailerDashboard = '/retailer/dashboard';

  static const String retailerInventory = '/retailer/inventory';
  static const String retailerPurchasing = '/retailer/purchasing';
  static const String retailerSales = '/retailer/sales';
  static const String retailerAnalytics = '/retailer/analytics';
  static const String retailerPurchaseHistory = '/retailer/purchase-history';
  static const String retailerReviews = '/retailer/reviews';
  static const String wholesalerDashboard = '/wholesaler/dashboard';
  static const String wholesalerInventory = '/wholesaler/inventory';
  static const String wholesalerSales = '/wholesaler/sales';
  static const String wholesalerProducts = '/wholesaler/products';
  static const String wholesalerAnalytics = '/wholesaler/analytics';
  static const String customerEditProfile = '/customer/editprofile';


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
      name: AppRoutes.customerDashboard,
      page: () => const CustomerDashboard(), // or import the correct dashboard from customers folder here
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(

      name: AppRoutes.customerProfile,
      page: () => const CustomerProfile(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.customerWishlist,
      page: () => const CustomerWishlist(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.customerCart,
      page: () => const CustomerCart(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.customerPlaceOrder,
      page: () => const PlaceOrder(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.customerOrders,
      page: () => const CustomerOrders(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.customerNotifications,
      page: () => const CustomerNotifications(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.retailerDashboard,
      page: () => const RetailerDashboard(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: AppRoutes.wholesalerDashboard,
      page: () => const WholesalerDashboard(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: AppRoutes.wholesalerInventory,
      page: () => const WholesalerInventoryScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.wholesalerSales,
      page: () => const WholesalerSalesScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.wholesalerProducts,
      page: () => const WholesalerProductsScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.wholesalerAnalytics,
      page: () => const WholesalerAnalyticsScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: '/wholesaler/reviews',
      page: () => const WholesalerReviewManagementScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.retailerInventory,
      page: () => const RetailerInventoryScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.retailerPurchasing,
      page: () => const RetailerPurchasingScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.retailerSales,
      page: () => const RetailerSalesScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.customerEditProfile,
      page: () => const EditProfileScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.retailerAnalytics,
      page: () => const RetailerAnalyticsScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.retailerPurchaseHistory,
      page: () => const RetailerPurchaseHistoryScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.retailerReviews,
      page: () => const RetailerReviewManagementScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),

  ];
}
