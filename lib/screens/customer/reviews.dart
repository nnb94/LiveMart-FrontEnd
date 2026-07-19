import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../controllers/auth_controller.dart';
import '../../services/api_service.dart';
import '../../models/review.dart';
import '../../models/product.dart';
import 'package:intl/intl.dart';

class ProductReviewsPage extends StatefulWidget {
  final Product product;

  const ProductReviewsPage({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductReviewsPage> createState() => _ProductReviewsPageState();
}

class _ProductReviewsPageState extends State<ProductReviewsPage> {
  final _formKey = GlobalKey<FormState>();
  double _rating = 5.0;
  String _title = '';
  String _body = '';
  bool _submitting = false;

  List<Review> reviews = [];
  Review? myReview;

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    // DUMMY REVIEWS FOR "Ireland Premium Tea"
    if (true) {
      // Make some dummy reviews. Normally you'd fetch from API.
      setState(() {
        reviews = [
          Review(
            id: 1,
            productId: widget.product.id,
            customerId: 1,
            customerName: "Satvik Sharma",
            rating: 5,
            title: "Amazing flavor!",
            body: "Felt fresh and rich, genuinely premium taste.",
            createdAt: DateTime.now().subtract(const Duration(days: 2)),
          ),
          Review(
            id: 2,
            customerId: 2,
            productId: widget.product.id,
            customerName: "Shaurya Kumar",
            rating: 4,
            title: "Pretty good",
            body: "Very good quality—would buy again. Slightly high priced.",
            createdAt: DateTime.now().subtract(const Duration(days: 5)),
          ),
          Review(
            id: 3,
            customerId: 3,
            productId: widget.product.id,
            customerName: "Nirvan Bhagabati",
            rating: 5,
            title: "Best almonds I've tried",
            body: "Perfect. Taste is fantastic, packaging is also lovely.",
            createdAt: DateTime.now().subtract(const Duration(days: 8)),
          ),
          Review(
            id: 4,
            customerId: 4,
            productId: widget.product.id,
            customerName: "Vedansh Raj",
            rating: 3,
            title: "Average",
            body: "Not as flavourful as I expected, but still decent for everyday use.",
            createdAt: DateTime.now().subtract(const Duration(days: 12)),
          ),
        ];
      });
      return;
    }

    // Default: fetch from backend for other products
    final api = Get.find<ApiService>();
    final response = await api.getProductReviews(widget.product.id.toString());

    setState(() {
      reviews = response;
      if (myReview != null) {
        _rating = myReview!.rating.toDouble();
        _title = myReview!.title ?? "";
        _body = myReview!.body ?? "";
      }
    });
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      final api = Get.find<ApiService>();
      final authController = Get.find<AuthController>();
      final accessToken = authController.accessToken.value;

      await api.submitReview(
        productId: widget.product.id,
        rating: _rating.round(),
        title: _title,
        body: _body,
        accessToken: accessToken,
      );

      await _fetchReviews();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review saved!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
    setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final hasPurchased = widget.product.hasPurchased;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1729),
        elevation: 0,
        title: Text(
          'Reviews — ${widget.product.name}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF0F1729),
                const Color(0xFF0F1729).withOpacity(0.8),
              ],
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          if (hasPurchased)
            Card(
              color: const Color(0xFF1A2332),
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text(
                        myReview == null ? 'Add a Review' : 'Update Your Review',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
                      ),
                      const SizedBox(height: 12),
                      RatingBar.builder(
                        initialRating: _rating,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: false,
                        itemCount: 5,
                        itemSize: 28,
                        unratedColor: Colors.white24,
                        itemBuilder: (context, _) =>
                            const Icon(Icons.star, color: Colors.amber),
                        onRatingUpdate: (v) => setState(() => _rating = v),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: _title,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Title (optional)',
                          labelStyle: const TextStyle(color: Colors.teal),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.teal),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.teal, width: 2),
                          ),
                          fillColor: const Color(0xFF0F1729),
                          filled: true,
                        ),
                        onChanged: (v) => _title = v,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: _body,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Review',
                          labelStyle: const TextStyle(color: Colors.teal),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.teal),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.teal, width: 2),
                          ),
                          fillColor: const Color(0xFF0F1729),
                          filled: true,
                        ),
                        minLines: 2,
                        maxLines: 5,
                        onChanged: (v) => _body = v,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Please enter your review' : null,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF17A2B8),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        onPressed: _submitting ? null : _submitReview,
                        child: Text(myReview == null ? 'Submit Review' : 'Update Review'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const Divider(color: Colors.white38),
          Expanded(
            child: reviews.isEmpty
                ? Center(
                    child: Text(
                      'No reviews yet.',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reviews.length,
              itemBuilder: (context, idx) {
                final review = reviews[idx];
                return Card(
                  color: const Color(0xFF1A2332),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: const Icon(Icons.account_circle, color: Colors.blue, size: 32),
                    title: Row(
                      children: [
                        Text('${review.customerName}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(width: 6),
                        RatingBarIndicator(
                          rating: review.rating.toDouble(),
                          itemBuilder: (context, index) =>
                              const Icon(Icons.star, color: Colors.amber),
                          itemCount: 5,
                          itemSize: 18.0,
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (review.title != null && review.title!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Text(review.title!,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white70)),
                          ),
                        if (review.body != null && review.body!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(review.body!, style: const TextStyle(color: Colors.white70)),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            'Reviewed on ${DateFormat('yyyy-MM-dd').format(review.createdAt)}',
                            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                          ),
                        ),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
