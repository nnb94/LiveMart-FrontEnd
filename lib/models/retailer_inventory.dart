import 'package:live_mart_app/models/product.dart';
import 'package:live_mart_app/models/wholesaler_sale.dart';

class RetailerInventoryItem {
  final int productId;
  final String productName;
  final String description;
  final double price;
  final String category;
  final int quantityInStock;
  final int reorderLevel;
  final bool needsRestock;
  final DateTime updatedAt;

  RetailerInventoryItem({
    required this.productId,
    required this.productName,
    required this.description,
    required this.price,
    required this.category,
    required this.quantityInStock,
    required this.reorderLevel,
    required this.needsRestock,
    required this.updatedAt,
  });

  factory RetailerInventoryItem.fromJson(Map<String, dynamic> json) {
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

    return RetailerInventoryItem(
      productId: _parseInt(json['product_id'] ?? json['productId']),
      productName: json['name'] ?? json['productName'],
      description: json['description'],
      price: _parseDouble(json['price']),
      category: json['category'],
      quantityInStock: _parseInt(json['quantity_in_stock'] ?? json['quantityInStock']),
      reorderLevel: _parseInt(json['reorder_level'] ?? json['reorderLevel']),
      needsRestock: json['needs_restock'] ?? false,
      updatedAt: DateTime.tryParse(json['updated_at'] ?? json['updatedAt']) ?? DateTime.now(),
    );
  }

  Product toProduct() {
    return Product(
      id: productId,
      sellerId: 0, // Not used in this context
      sellerName: 'Unknown',
      name: productName,
      description: description,
      price: price,
      category: category,
      createdAt: updatedAt,
      updatedAt: updatedAt,
    );
  }
}

class RetailingPurchaseOrder {
  final int orderId;
  final int buyerId;
  final int sellerId;
  final String wholesalerName;
  final ProductInfo productInfo;
  final OrderDetails orderDetails;
  final String orderDate;
  final String status;

  RetailingPurchaseOrder({
    required this.orderId,
    required this.buyerId,
    required this.sellerId,
    required this.wholesalerName,
    required this.productInfo,
    required this.orderDetails,
    required this.orderDate,
    required this.status,
  });

  factory RetailingPurchaseOrder.fromJson(Map<String, dynamic> json) {
    return RetailingPurchaseOrder(
      orderId: json['id'] ?? json['orderId'],
      buyerId: json['buyer_id'] ?? json['buyerId'],
      sellerId: json['seller_id'] ?? json['sellerId'],
      wholesalerName: json['wholesaler_name'] ?? json['wholesalerName'],
      productInfo: ProductInfo.fromJson(json),
      orderDetails: OrderDetails.fromJson(json),
      orderDate: json['order_date'] ?? json['orderDate'],
      status: json['status'],
    );
  }
}

class RetailingSaleOrder {
  final int orderId;
  final int buyerId;
  final int sellerId;
  final String customerName;
  final ProductInfo productInfo;
  final OrderDetails orderDetails;
  final String orderDate;
  final String status;
  final bool offlineOrder;
  final String? deliveryDetails;
  final String? expectedDeliveryDate;

  RetailingSaleOrder({
    required this.orderId,
    required this.buyerId,
    required this.sellerId,
    required this.customerName,
    required this.productInfo,
    required this.orderDetails,
    required this.orderDate,
    required this.status,
    required this.offlineOrder,
    this.deliveryDetails,
    this.expectedDeliveryDate,
  });

  factory RetailingSaleOrder.fromJson(Map<String, dynamic> json) {
    return RetailingSaleOrder(
      orderId: json['id'] ?? json['orderId'],
      buyerId: json['buyer_id'] ?? json['buyerId'],
      sellerId: json['seller_id'] ?? json['sellerId'],
      customerName: json['customer_name'] ?? json['customerName'],
      productInfo: ProductInfo.fromJson(json),
      orderDetails: OrderDetails.fromJson(json),
      orderDate: json['order_date'] ?? json['orderDate'],
      status: json['status'],
      offlineOrder: json['offline_order'] ?? json['offlineOrder'] ?? false,
      deliveryDetails: json['delivery_details'] ?? json['deliveryDetails'],
      expectedDeliveryDate: json['expected_delivery_date'] ?? json['expectedDeliveryDate'],
    );
  }
}

class AvailableWholesaleProduct {
  final Product product;
  final int sellerId;
  final String sellerName;
  final int availableStock;
  final int minimumOrderQuantity;
  final int reorderLevel;
  final bool needsRestock;

  AvailableWholesaleProduct({
    required this.product,
    required this.sellerId,
    required this.sellerName,
    required this.availableStock,
    required this.minimumOrderQuantity,
    required this.reorderLevel,
    required this.needsRestock,
  });

  factory AvailableWholesaleProduct.fromJson(Map<String, dynamic> json) {
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

    return AvailableWholesaleProduct(
      product: Product.fromJson(json),
      sellerId: _parseInt(json['seller_id'] ?? json['sellerId']),
      sellerName: json['seller_name'] ?? json['sellerName'],
      availableStock: _parseInt(json['stock_quantity'] ?? json['quantity_in_stock'] ?? json['availableStock']),
      minimumOrderQuantity: _parseInt(json['minimum_order_quantity'] ?? json['minimumOrderQuantity']),
      reorderLevel: _parseInt(json['reorder_level'] ?? json['reorderLevel']),
      needsRestock: json['needs_restock'] ?? false,
    );
  }
}

class LowStockAlert {
  final int productId;
  final String productName;
  final String category;
  final double price;
  final int currentStock;
  final int reorderLevel;
  final String description;

  LowStockAlert({
    required this.productId,
    required this.productName,
    required this.category,
    required this.price,
    required this.currentStock,
    required this.reorderLevel,
    required this.description,
  });

  factory LowStockAlert.fromJson(Map<String, dynamic> json) {
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

    return LowStockAlert(
      productId: _parseInt(json['product_id'] ?? json['productId']),
      productName: json['name'],
      category: json['category'],
      price: _parseDouble(json['price']),
      currentStock: _parseInt(json['quantity_in_stock']),
      reorderLevel: _parseInt(json['reorder_level']),
      description: json['description'],
    );
  }
}

class RetailerAnalytics {
  final Summary summary;

  RetailerAnalytics({
    required this.summary,
  });

  factory RetailerAnalytics.fromJson(Map<String, dynamic> json) {
    return RetailerAnalytics(
      summary: Summary.fromJson(json['summary']),
    );
  }
}
