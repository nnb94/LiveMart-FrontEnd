class Product {
  final int id;
  final int sellerId;
  final String name;
  final String description;
  final double price;
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;

  // For existing products with inventory tracking
  final int? stockQuantity;
  final int? minimumOrderQuantity;
  final int? reorderLevel;
  final bool? needsRestock;

  Product({
    required this.id,
    required this.sellerId,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
    this.stockQuantity,
    this.minimumOrderQuantity,
    this.reorderLevel,
    this.needsRestock,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
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

    return Product(
      id: json['id'],
      sellerId: json['seller_id'] ?? json['sellerId'],
      name: json['name'],
      description: json['description'],
      price: _parseDouble(json['price']),
      category: json['category'],
      createdAt: DateTime.tryParse(json['created_at'] ?? json['createdAt']) ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? json['updatedAt']) ?? DateTime.now(),
      stockQuantity: _parseInt(json['stock_quantity'] ?? json['stockQuantity']),
      minimumOrderQuantity: _parseInt(json['minimum_order_quantity'] ?? json['minimumOrderQuantity']),
      reorderLevel: _parseInt(json['reorder_level'] ?? json['reorderLevel']),
      needsRestock: json['needs_restock'] ?? json['needsRestock'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sellerId': sellerId,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (stockQuantity != null) 'stockQuantity': stockQuantity,
      if (minimumOrderQuantity != null) 'minimumOrderQuantity': minimumOrderQuantity,
      if (reorderLevel != null) 'reorderLevel': reorderLevel,
      if (needsRestock != null) 'needsRestock': needsRestock,
    };
  }
}
