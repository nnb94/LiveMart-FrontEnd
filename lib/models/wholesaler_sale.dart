class WholesalerSale {
  final int orderId;
  final int buyerId;
  final String retailerName;
  final String retailerEmail;
  final ProductInfo productInfo;
  final OrderDetails orderDetails;
  final String orderDate;
  final String status;

  WholesalerSale({
    required this.orderId,
    required this.buyerId,
    required this.retailerName,
    required this.retailerEmail,
    required this.productInfo,
    required this.orderDetails,
    required this.orderDate,
    required this.status,
  });

  factory WholesalerSale.fromJson(Map<String, dynamic> json) {
    return WholesalerSale(
      orderId: json['id'] ?? json['orderId'],
      buyerId: json['buyer_id'] ?? json['buyerId'],
      retailerName: json['retailer_name'] ?? json['retailerName'],
      retailerEmail: json['retailer_email'] ?? json['retailerEmail'],
      productInfo: ProductInfo.fromJson(json),
      orderDetails: OrderDetails.fromJson(json),
      orderDate: json['order_date'] ?? json['orderDate'],
      status: json['status'],
    );
  }
}

class ProductInfo {
  final String productName;
  final String productDescription;

  ProductInfo({
    required this.productName,
    required this.productDescription,
  });

  factory ProductInfo.fromJson(Map<String, dynamic> json) {
    return ProductInfo(
      productName: json['product_name'] ?? json['productName'],
      productDescription: json['product_description'] ?? json['productDescription'],
    );
  }
}

class OrderDetails {
  final int quantity;
  final double price;
  final double totalAmount;

  OrderDetails({
    required this.quantity,
    required this.price,
    required this.totalAmount,
  });

  factory OrderDetails.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse numbers from strings or numbers
    double _parseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    int _parseInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      if (value is num) return value.toInt();
      return 0;
    }

    return OrderDetails(
      quantity: _parseInt(json['quantity']),
      price: _parseDouble(json['price']),
      totalAmount: _parseDouble(json['total_amount'] ?? json['totalAmount']),
    );
  }
}

class TopProduct {
  final String name;
  final int productId;
  final int orderCount;
  final int totalQuantitySold;
  final double totalRevenue;

  TopProduct({
    required this.name,
    required this.productId,
    required this.orderCount,
    required this.totalQuantitySold,
    required this.totalRevenue,
  });

  factory TopProduct.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse numbers from strings or numbers
    double _parseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    int _parseInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      if (value is num) return value.toInt();
      return 0;
    }

    return TopProduct(
      name: json['name'],
      productId: _parseInt(json['product_id'] ?? json['productId']),
      orderCount: _parseInt(json['order_count'] ?? json['orderCount']),
      totalQuantitySold: _parseInt(json['total_quantity_sold'] ?? json['totalQuantitySold']),
      totalRevenue: _parseDouble(json['total_revenue'] ?? json['totalRevenue']),
    );
  }
}

class WholesalerAnalytics {
  final Summary summary;
  final List<TopProduct> topProducts;

  WholesalerAnalytics({
    required this.summary,
    required this.topProducts,
  });

  factory WholesalerAnalytics.fromJson(Map<String, dynamic> json) {
    final topProductsJson = json['top_products'] ?? json['topProducts'];
    List<TopProduct> topProducts = [];

    if (topProductsJson is List) {
      try {
        topProducts = topProductsJson.map((item) {
          if (item is Map<String, dynamic>) {
            return TopProduct.fromJson(item);
          } else {
            return TopProduct(
              name: 'Unknown',
              productId: 0,
              orderCount: 0,
              totalQuantitySold: 0,
              totalRevenue: 0.0,
            );
          }
        }).toList();
      } catch (e) {
        print('Error parsing top products: $e');
      }
    }

    return WholesalerAnalytics(
      summary: Summary.fromJson(json['summary']),
      topProducts: topProducts,
    );
  }
}

class Summary {
  final int totalOrders;
  final double totalRevenue;
  final double averageOrderValue;
  final int totalUnitsSold;
  final int uniqueBuyers;

  Summary({
    required this.totalOrders,
    required this.totalRevenue,
    required this.averageOrderValue,
    required this.totalUnitsSold,
    required this.uniqueBuyers,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse numbers from strings or numbers
    double _parseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    int _parseInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      if (value is num) return value.toInt();
      return 0;
    }

    return Summary(
      totalOrders: _parseInt(json['total_orders'] ?? json['totalOrders']),
      totalRevenue: _parseDouble(json['total_revenue'] ?? json['totalRevenue']),
      averageOrderValue: _parseDouble(json['average_order_value'] ?? json['averageOrderValue']),
      totalUnitsSold: _parseInt(json['total_units_sold'] ?? json['totalUnitsSold']),
      uniqueBuyers: _parseInt(json['unique_buyers'] ?? json['uniqueBuyers']),
    );
  }
}
