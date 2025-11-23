import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../controllers/auth_controller.dart';
import '../../services/api_service.dart'; // You will need functions to call your review endpoints
import '../../models/review.dart'; // Create a Review model matching your JSON
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

  // You should replace this with a GetX Controller or ApiService call in real app
  List<Review> reviews = [];
  Review? myReview;

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    // Replace with your API call using ApiService
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
      final api = Get.find<ApiService>(); // Or ApiService() if you don't use GetX DI
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Review saved!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
    setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final hasPurchased = widget.product.hasPurchased; // Add this bool or check via API
    return Scaffold(
      appBar: AppBar(title: Text('Reviews')),
      body: Column(
        children: [
          if (hasPurchased)
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text(myReview == null ? 'Add a Review' : 'Update Your Review',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      RatingBar.builder(
                        initialRating: _rating,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: false,
                        itemCount: 5,
                        itemSize: 28,
                        itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                        onRatingUpdate: (v) => setState(() => _rating = v),
                      ),
                      TextFormField(
                        initialValue: _title,
                        decoration: const InputDecoration(labelText: 'Title (optional)'),
                        onChanged: (v) => _title = v,
                      ),
                      TextFormField(
                        initialValue: _body,
                        decoration: const InputDecoration(labelText: 'Review'),
                        minLines: 2,
                        maxLines: 5,
                        onChanged: (v) => _body = v,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your review' : null,
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _submitting ? null : _submitReview,
                        child: Text(myReview == null ? 'Submit Review' : 'Update Review'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reviews.length,
              itemBuilder: (context, idx) {
                final review = reviews[idx];
                return Card(
                  child: ListTile(
                    leading: Icon(Icons.account_circle, color: Colors.blue, size: 32),
                    title: Row(
                      children: [
                        Text('${review.customerName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 6),
                        RatingBarIndicator(
                          rating: review.rating.toDouble(),
                          itemBuilder: (context, index) => const Icon(Icons.star, color: Colors.amber),
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
                            child: Text(review.title!, style: TextStyle(fontWeight: FontWeight.w500)),
                          ),
                        if (review.body != null && review.body!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(review.body!),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text('Reviewed on ${DateFormat('yyyy-MM-dd').format(review.createdAt)}',
                              style: TextStyle(fontSize: 12, color: Colors.grey)),
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
