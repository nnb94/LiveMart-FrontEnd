class WholesalerInventoryItem {
  final int productId;
  final String productName;
  final String description;
  final double price;
  final String category;
  final int quantityInStock;
  final int minimumOrderQuantity;
  final DateTime updatedAt;

  WholesalerInventoryItem({
    required this.productId,
    required this.productName,
    required this.description,
    required this.price,
    required this.category,
    required this.quantityInStock,
    required this.minimumOrderQuantity,
    required this.updatedAt,
  });

  factory WholesalerInventoryItem.fromJson(Map<String, dynamic> json) {
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

    String _parseString(dynamic value) {
      if (value == null) return '';
      return value.toString();
    }

    return WholesalerInventoryItem(
      productId: _parseInt(json['product_id'] ?? json['productId']),
      productName: _parseString(json['name'] ?? json['productName']),
      description: _parseString(json['description']),
      price: _parseDouble(json['price']),
      category: _parseString(json['category']),
      quantityInStock: _parseInt(
        json['quantity_in_stock'] ?? json['quantityInStock'],
      ),
      minimumOrderQuantity: _parseInt(
        json['minimum_order_quantity'] ?? json['minimumOrderQuantity'],
      ),
      updatedAt:
          DateTime.tryParse(
            json['updated_at']?.toString() ??
                json['updatedAt']?.toString() ??
                '',
          ) ??
          DateTime.now(),
    );
  }
}
