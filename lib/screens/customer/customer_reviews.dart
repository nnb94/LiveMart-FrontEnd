import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_mart_app/models/review.dart';
import 'package:live_mart_app/services/api_service.dart';
import 'package:intl/intl.dart';
import '../../controllers/auth_controller.dart';

class CustomerReviewsPage extends StatefulWidget {
  const CustomerReviewsPage({Key? key}) : super(key: key);

  @override
  State<CustomerReviewsPage> createState() => _CustomerReviewsPageState();
}

class _CustomerReviewsPageState extends State<CustomerReviewsPage> {
  List<Review> myReviews = [];
  bool isLoading = false;
  String errorMessage = '';

  // For adding/editing a review
  final _formKey = GlobalKey<FormState>();
  double _rating = 5;
  String _body = '';
  String _title = '';
  String? _selectedProductId;
  bool _submitting = false;
  List<Map<String, dynamic>> orderedProducts = []; // For selection

  @override
  void initState() {
    super.initState();
    _fetchMyReviews();
    _fetchOrderedProducts();
  }

  Future<void> _fetchMyReviews() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final authController = Get.find<AuthController>();
      final token = authController.accessToken.value;
      final api = Get.find<ApiService>();
      final reviews = await api.getMyReviews(token);
      setState(() {
        myReviews = reviews;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchOrderedProducts() async {
    try {
      final authController = Get.find<AuthController>();
      final token = authController.accessToken.value;
      final api = Get.find<ApiService>();
      final products = await api.getOrderedProducts(token);
      setState(() {
        orderedProducts = products; // [{id: "1", name: "Tea"}, ...]
      });
    } catch (_) {
      // Ignore errors, keep empty
    }
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProductId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please select a product to review.')));
      return;
    }
    setState(() => _submitting = true);
    try {
      final api = Get.find<ApiService>();
      final authController = Get.find<AuthController>();
      final accessToken = authController.accessToken.value;

      await api.submitProdReview(
        productId: _selectedProductId,
        rating: _rating.round(),
        title: _title,
        body: _body,
        accessToken: accessToken,
      );

      _body = '';
      _title = '';
      setState(() => _selectedProductId = null);

      await _fetchMyReviews();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Review submitted!')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
    setState(() => _submitting = false);
  }

  void _showAddReviewDialog(BuildContext context) {
    _title = '';
    _body = '';
    _rating = 5;
    _selectedProductId = null;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A2332),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        content: StatefulBuilder(
          builder: (context, setStateDialog) => Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Write a Review',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedProductId,
                    dropdownColor: const Color(0xFF1A2332),
                    items: orderedProducts
                        .map((prod) => DropdownMenuItem(
                              value: prod['id'].toString(),
                              child: Text(prod['name'] ?? ''),
                            ))
                        .toList(),
                    onChanged: (val) {
                      setStateDialog(() {
                        _selectedProductId = val;
                      });
                    },
                    validator: (val) =>
                        val == null ? 'Select a product to review' : null,
                    decoration: const InputDecoration(
                        labelText: 'Select Product',
                        labelStyle: TextStyle(color: Colors.teal)),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Rating:', style: TextStyle(color: Colors.teal)),
                      Slider(
                        value: _rating,
                        min: 1,
                        max: 5,
                        divisions: 4,
                        label: _rating.toString(),
                        activeColor: Colors.amber,
                        onChanged: (value) {
                          setStateDialog(() => _rating = value);
                        },
                      ),
                    ],
                  ),
                  TextFormField(
                    initialValue: _title,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Title (optional)',
                      labelStyle: TextStyle(color: Colors.teal),
                    ),
                    onChanged: (v) => _title = v,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: _body,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Your Review',
                      labelStyle: TextStyle(color: Colors.teal),
                    ),
                    minLines: 2,
                    maxLines: 5,
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'Review required'
                        : null,
                    onChanged: (v) => _body = v,
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    onPressed: _submitting
                        ? null
                        : () {
                            Navigator.of(context).pop();
                            _submitReview();
                          },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF17A2B8),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    child: Text(_submitting ? 'Submitting...' : 'Submit',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showEditReviewDialog(Review review) {
    _selectedProductId = review.productId?.toString();
    _rating = review.rating.toDouble();
    _title = review.title ?? '';
    _body = review.body ?? '';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A2332),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        content: StatefulBuilder(
          builder: (context, setStateDialog) => Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Edit Review',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedProductId,
                    dropdownColor: const Color(0xFF1A2332),
                    items: orderedProducts
                        .map((prod) => DropdownMenuItem(
                              value: prod['id'].toString(),
                              child: Text(prod['name'] ?? ''),
                            ))
                        .toList(),
                    onChanged: (val) {
                      setStateDialog(() {
                        _selectedProductId = val;
                      });
                    },
                    validator: (val) =>
                        val == null ? 'Select a product to review' : null,
                    decoration: const InputDecoration(
                        labelText: 'Select Product',
                        labelStyle: TextStyle(color: Colors.teal)),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Rating:', style: TextStyle(color: Colors.teal)),
                      Slider(
                        value: _rating,
                        min: 1,
                        max: 5,
                        divisions: 4,
                        label: _rating.toString(),
                        activeColor: Colors.amber,
                        onChanged: (value) {
                          setStateDialog(() => _rating = value);
                        },
                      ),
                    ],
                  ),
                  TextFormField(
                    initialValue: _title,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Title (optional)',
                      labelStyle: TextStyle(color: Colors.teal),
                    ),
                    onChanged: (v) => _title = v,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: _body,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Your Review',
                      labelStyle: TextStyle(color: Colors.teal),
                    ),
                    minLines: 2,
                    maxLines: 5,
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'Review required'
                        : null,
                    onChanged: (v) => _body = v,
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    onPressed: _submitting
                        ? null
                        : () {
                            Navigator.of(context).pop();
                            _updateReview(review);
                          },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF17A2B8),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    child: Text(_submitting ? 'Updating...' : 'Update Review',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _updateReview(Review review) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      final api = Get.find<ApiService>();
      final authController = Get.find<AuthController>();
      final accessToken = authController.accessToken.value;

      await api.updateReview(
        id: review.id,
        rating: _rating.round(),
        title: _title,
        body: _body,
        accessToken: accessToken,
      );


      _body = '';
      _title = '';
      setState(() => _selectedProductId = null);

      await _fetchMyReviews();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Review updated!')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
    setState(() => _submitting = false);
  }

  Future<void> _deleteReview(Review review) async {
    setState(() => isLoading = true);
    try {
      final api = Get.find<ApiService>();
      final authController = Get.find<AuthController>();
      final accessToken = authController.accessToken.value;

      await api.deleteReview(
        id: review.id,
        accessToken: accessToken,
      );


      await _fetchMyReviews();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Review deleted!')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1729),
        elevation: 0,
        title: const Text(
          'My Reviews',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showAddReviewDialog(context),
            icon: const Icon(Icons.add_comment, color: Colors.teal, size: 28),
            tooltip: 'Add Review',
          )
        ],
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
      backgroundColor: const Color(0xFF0A0E27),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF17A2B8)),
              ),
            )
          : errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    'Error: $errorMessage',
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : myReviews.isEmpty
                  ? Center(
                      child: Text(
                        'You have not written any reviews yet.',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchMyReviews,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: myReviews.length,
                        itemBuilder: (context, idx) {
                          final review = myReviews[idx];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(0xFF0F1729),
                                  const Color(0xFF1A2332).withOpacity(0.5),
                                ],
                              ),
                              border: Border.all(
                                color: const Color(0xFF17A2B8).withOpacity(0.3),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF17A2B8)
                                      .withOpacity(0.1),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: Icon(
                                Icons.star,
                                color: Colors.amber[700],
                                size: 32,
                              ),
                              title: Text(
                                review.title?.isNotEmpty == true
                                    ? review.title!
                                    : (review.productId != null
                                        ? 'Review – ${review.productId}'
                                        : 'General Review'),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    review.body ?? "",
                                    style: const TextStyle(
                                        fontSize: 16, color: Colors.white70),
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Text(
                                        'Rating: ${review.rating}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.teal),
                                      ),
                                      if (review.productId != null)
                                        Row(
                                          children: [
                                            const SizedBox(width: 8),
                                            Text(
                                              'For Product: ${review.productId}',
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey[400]),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                  Text(
                                    'Reviewed on ${DateFormat('yyyy-MM-dd').format(review.createdAt)}',
                                    style: TextStyle(
                                        fontSize: 11, color: Colors.grey[500]),
                                  ),
                                  Row(
                                    children: [
                                      TextButton(
                                        child: const Text(
                                          'Edit',
                                          style:
                                              TextStyle(color: Colors.teal),
                                        ),
                                        onPressed: () =>
                                            _showEditReviewDialog(review),
                                      ),
                                      TextButton(
                                        child: const Text(
                                          'Delete',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                        onPressed: () =>
                                            _deleteReview(review),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              isThreeLine: true,
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
