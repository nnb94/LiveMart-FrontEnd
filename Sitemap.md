## 1. Public Routes (Unauthenticated)

* `/` → Landing Page
* `/about` → About the Platform
* `/contact` → Contact Us / Support
* `/login` → Login Page
* `/signup` → Signup Page
* `/verify-otp` → OTP Verification Page
* `/forgot-password` → Forgot Password Page
* `/forgot-password/verify` → Password Reset Verification Page
* `/products/all` → View All Products (role-based filtering)

## 2. Customer Dashboard

> Base route: /customers

* `/customers/dashboard` → Customer Dashboard (overview, recommendations)
* `/customers/profile` → View / Edit Profile
* `/customers/wishlist` → Wishlist / Favorites
* `/customers/cart` → Shopping Cart
* `/customers/placeorder` → Place an Order (online/offline toggle)
* `/customers/orders` → Order History
* `/customers/orders/:orderId` → Order Details
* `/customers/reviews/myreviews` → Manage My Reviews
* `/customers/notifications` → Order & Delivery Notifications

## 3. Retailer Dashboard

> Base route: /retailers

* `/retailers/dashboard` → Retailer Dashboard (overview, analytics, alerts)
* `/retailers/profile` → View / Edit Profile
* `/retailers/inventory` → Manage Retail Inventory (CRUD + restock alerts)
* `/retailers/products/add` → Add New Retail Product
* `/retailers/products/myproducts` → My Listed Products
* `/retailers/orders/sales` → Retail Sales Orders (to customers)
* `/retailers/orders/purchases` → Wholesale Purchases (from wholesalers)
* `/retailers/order/wholesale` → Place Wholesale Order
* `/retailers/analytics` → Sales & Inventory Analytics
* `/retailers/notifications` → Order & Stock Alerts

## 4. Wholesaler Dashboard

> Base route: /wholesalers

* `/wholesalers/dashboard` → Wholesaler Dashboard (overview, metrics)
* `/wholesalers/profile` → View / Edit Profile
* `/wholesalers/inventory` → Manage Wholesale Inventory (CRUD)
* `/wholesalers/products/add` → Add New Wholesale Product
* `/wholesalers/products/myproducts` → My Listed Products
* `/wholesalers/orders/sales` → Sales Orders (to retailers)
* `/wholesalers/analytics/sales` → Sales Analytics (charts, volume, trends)
* `/wholesalers/notifications` → Order Notifications

## 5. Admin Panel (if applicable)

> Base route: /admin

* `/admin/dashboard` → Overview of users, sales, and performance
* `/admin/users` → Manage Users (CRUD)
* `/admin/products` → Monitor all products
* `/admin/orders` → View All Orders
* `/admin/reports` → Generate and download reports

## 6. Shared Functional Routes (Backend APIs)

* `/api/auth/signup`
* `/api/auth/verify-otp`
* `/api/auth/login`
* `/api/auth/refresh-token`
* `/api/auth/forgot-password`
* `/api/auth/forgot-password/verify`
* `/api/products/all`
* `/api/products/add`
* `/api/products/myproducts`
* `/api/reviews/add`
* `/api/reviews/product/:productId`
* `/api/reviews/myreviews`
* `/api/reviews/update`
* `/api/reviews/delete`
* `/api/customers/placeorder`
* `/api/customers/orders/:customerId`
* `/api/retailers/inventory`
* `/api/retailers/order/wholesale`
* `/api/retailers/orders/purchases`
* `/api/retailers/orders/sales`
* `/api/wholesalers/inventory`
* `/api/wholesalers/orders/sales`
* `/api/wholesalers/analytics/sales`
* `/api/notifications/send`

## Upcoming / To-Do Integrations

* `/oauth/google` → Google Sign-In (OAuth 2.0)
* `/upload/product-images` → Product Image Uploads (Cloud/Local)
* `/payments/checkout` → Payment Gateway Integration
* `/location/nearby` → Fetch Nearest Retailers / Wholesalers
* `/calendar/integration` → Wholesaler Calendar Integration (deliveries/restocks)

## 8. Error & Utility Pages

* `/error/404` → Page Not Found
* `/error/500` → Server Error
* `/maintenance` → Maintenance Mode
