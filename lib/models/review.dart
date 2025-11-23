class Review {
  final int id;
  final int customerId;
  final String customerName;
  final int productId;
  final int rating;
  final String? title;
  final String? body;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.productId,
    required this.rating,
    this.title,
    this.body,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json, {int? productId}) {
    return Review(
      id: json['id'],
      customerId: json['user_id'],
      customerName: json['user_name'] ?? 'Anonymous',
      productId:
          productId ??
          json['product_id'], // Use provided productId if available
      rating: json['rating'],
      title: json['title'],
      body: json['body'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': customerId,
      'user_name': customerName,
      'product_id': productId,
      'rating': rating,
      'title': title,
      'body': body,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Calculate average rating for a list of reviews
  static double calculateAverageRating(List<Review> reviews) {
    if (reviews.isEmpty) return 0.0;
    final sum = reviews.fold<double>(0, (sum, review) => sum + review.rating);
    return sum / reviews.length;
  }

  /// Get rating distribution (1-5 stars)
  static Map<int, int> getRatingDistribution(List<Review> reviews) {
    Map<int, int> distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (final review in reviews) {
      distribution[review.rating] = (distribution[review.rating] ?? 0) + 1;
    }
    return distribution;
  }

  /// Get rating breakdown (excellent, good, average, poor, terrible)
  static Map<String, int> getRatingBreakdown(List<Review> reviews) {
    Map<String, int> breakdown = {
      'excellent': 0, // 5 stars
      'good': 0, // 4 stars
      'average': 0, // 3 stars
      'poor': 0, // 2 stars
      'terrible': 0, // 1 star
    };

    for (final review in reviews) {
      switch (review.rating) {
        case 5:
          breakdown['excellent'] = breakdown['excellent']! + 1;
          break;
        case 4:
          breakdown['good'] = breakdown['good']! + 1;
          break;
        case 3:
          breakdown['average'] = breakdown['average']! + 1;
          break;
        case 2:
          breakdown['poor'] = breakdown['poor']! + 1;
          break;
        case 1:
          breakdown['terrible'] = breakdown['terrible']! + 1;
          break;
      }
    }

    return breakdown;
  }
}
