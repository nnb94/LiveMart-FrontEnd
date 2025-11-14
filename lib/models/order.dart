class Order {
  final int orderId;
  final ProductInfo productInfo;
  final OrderDetails orderDetails;
  final SellerInfo sellerInfo;

  Order({
    required this.orderId,
    required this.productInfo,
    required this.orderDetails,
    required this.sellerInfo,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['orderId'],
      productInfo: ProductInfo.fromJson(json['productInfo']),
      orderDetails: OrderDetails.fromJson(json['orderDetails']),
      sellerInfo: SellerInfo.fromJson(json['sellerInfo']),
    );
  }
}

class ProductInfo {
  final int id;
  final String name;
  final String description;

  ProductInfo({
    required this.id,
    required this.name,
    required this.description,
  });

  factory ProductInfo.fromJson(Map<String, dynamic> json) {
    return ProductInfo(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }
}

class OrderDetails {
  final int quantity;
  final double price;
  final double totalAmount;
  final String status;
  final String orderDate;
  final bool isOfflineOrder;
  final String? deliveryDetails;
  final String? expectedDeliveryDate;

  OrderDetails({
    required this.quantity,
    required this.price,
    required this.totalAmount,
    required this.status,
    required this.orderDate,
    required this.isOfflineOrder,
    this.deliveryDetails,
    this.expectedDeliveryDate,
  });

  factory OrderDetails.fromJson(Map<String, dynamic> json) {
    return OrderDetails(
      quantity: json['quantity'],
      price: json['price'].toDouble(),
      totalAmount: json['totalAmount'].toDouble(),
      status: json['status'],
      orderDate: json['orderDate'],
      isOfflineOrder: json['isOfflineOrder'],
      deliveryDetails: json['deliveryDetails'],
      expectedDeliveryDate: json['expectedDeliveryDate'],
    );
  }
}

class SellerInfo {
  final int id;
  final String name;
  final String email;

  SellerInfo({
    required this.id,
    required this.name,
    required this.email,
  });

  factory SellerInfo.fromJson(Map<String, dynamic> json) {
    return SellerInfo(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }
}
