class Product {
  final int id;
  final int sellerId;
  final String sellerName;
  final String name;
  final String description;
  final double price;
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Image fields for product images
  final String? imageUrl;
  final String? imagePublicId;

  // Additional seller info
  final String? sellerEmail;
  final String? sellerRole;

  // For existing products with inventory tracking
  final int? stockQuantity;
  final int? minimumOrderQuantity;
  final int? reorderLevel;
  final bool? needsRestock;

  // NEW: Has this product been purchased by the user?
  final bool hasPurchased;

  Product({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
    this.imageUrl,
    this.imagePublicId,
    this.sellerEmail,
    this.sellerRole,
    this.stockQuantity,
    this.minimumOrderQuantity,
    this.reorderLevel,
    this.needsRestock,
    this.hasPurchased = false, // default: not purchased
  });

  factory Product.fromJson(Map<String, dynamic> json) {
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

    String _parseString(dynamic value) {
      if (value == null) return '';
      return value.toString();
    }

    int? _parseNullableInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      if (value is num) return value.toInt();
      return null;
    }

    bool? _parseNullableBool(dynamic value) {
      if (value == null) return null;
      if (value is bool) return value;
      if (value is String) {
        if (value.toLowerCase() == 'true' || value == '1') return true;
        if (value.toLowerCase() == 'false' || value == '0') return false;
      }
      if (value is int) return value != 0;
      return null;
    }

    String? _parseNullableString(dynamic value) {
      if (value == null) return null;
      return value.toString();
    }

    bool _parseBool(dynamic value) {
      if (value is bool) return value;
      if (value is String) {
        if (value.toLowerCase() == 'true' || value == '1') return true;
        if (value.toLowerCase() == 'false' || value == '0') return false;
      }
      if (value is int) return value != 0;
      return false;
    }

    return Product(
      id: _parseInt(json['id']),
      sellerId: _parseInt(json['seller_id'] ?? json['sellerId']),
      sellerName: _parseString(json['seller_name'] ?? json['sellerName']),
      name: _parseString(json['name']),
      description: _parseString(json['description']),
      price: _parseDouble(json['price']),
      category: _parseString(json['category']),
      imageUrl: _parseNullableString(json['image_url'] ?? json['imageUrl']),
      imagePublicId: _parseNullableString(json['image_public_id'] ?? json['imagePublicId']),
      sellerEmail: _parseNullableString(json['seller_email'] ?? json['sellerEmail']),
      sellerRole: _parseNullableString(json['seller_role'] ?? json['sellerRole']),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
      stockQuantity: _parseNullableInt(json['stock_quantity'] ?? json['stockQuantity']),
      minimumOrderQuantity: _parseNullableInt(json['minimum_order_quantity'] ?? json['minimumOrderQuantity']),
      reorderLevel: _parseNullableInt(json['reorder_level'] ?? json['reorderLevel']),
      needsRestock: _parseNullableBool(json['needs_restock'] ?? json['needsRestock']),
      hasPurchased: json['hasPurchased'] != null ? _parseBool(json['hasPurchased']) : false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (imagePublicId != null) 'imagePublicId': imagePublicId,
      if (stockQuantity != null) 'stockQuantity': stockQuantity,
      if (minimumOrderQuantity != null) 'minimumOrderQuantity': minimumOrderQuantity,
      if (reorderLevel != null) 'reorderLevel': reorderLevel,
      if (needsRestock != null) 'needsRestock': needsRestock,
      'hasPurchased': hasPurchased,
    };
  }
}
