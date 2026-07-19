# LiveMart Frontend

LiveMart Frontend is the Flutter-based client application for the LiveMart marketplace platform. It provides a polished, role-based experience for customers, retailers, and wholesalers, with authentication, product browsing, cart/order handling, reviews, and analytics.

## Overview

This frontend connects to the LiveMart backend API and delivers a modern mobile experience with:

- Secure login and signup flow
- OTP-based authentication and password reset
- Customer dashboards for browsing, cart, orders, and reviews
- Retailer dashboards for inventory, purchasing, sales, and analytics
- Wholesaler dashboards for inventory, sales, products, and review management
- Persistent user state and smooth navigation using GetX

## Tech Stack

- Flutter
- Dart
- GetX for state management and routing
- http for API communication
- shared_preferences for local persistence
- google_sign_in for Google authentication
- flutter_rating_bar, fl_chart, image_picker, and more

## Project Structure

- lib/main.dart - App entry point
- lib/approutes.dart - Application routes
- lib/screens/ - UI screens for authentication, customer, retailer, and wholesaler flows
- lib/controllers/ - Business logic and app state controllers
- lib/services/ - API integration and backend communication
- lib/models/ - Data models
- lib/widgets/ - Reusable UI components

## Prerequisites

Make sure you have the following installed:

- Flutter SDK
- Dart SDK
- Android Studio / Xcode / VS Code with Flutter extensions
- A running LiveMart backend server

## Getting Started

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd LiveMart-FrontEnd-main
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Backend Configuration

This frontend expects the backend to be running locally on:

- http://localhost:3000

If your backend uses a different host or port, update the base URL in the API service file:

- lib/services/api_service.dart

## Useful Commands

- Run on an emulator or connected device:
  ```bash
  flutter run
  ```

- Check for issues:
  ```bash
  flutter analyze
  ```

- Build an Android APK:
  ```bash
  flutter build apk
  ```

## Notes

- The app uses Google Sign-In, so ensure your Google configuration is set up correctly for your environment.
- Assets such as the app logo are stored in the assets directory.
- The app is currently designed as a frontend client for the LiveMart backend ecosystem.

## License

This project is for educational and development purposes.
