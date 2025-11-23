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

  @override
  void initState() {
    super.initState();
    _fetchMyReviews();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Reviews')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                  'Error: $errorMessage',
                  style: const TextStyle(color: Colors.red),
                ))
              : myReviews.isEmpty
                  ? const Center(child: Text('You have not written any reviews yet.'))
                  : RefreshIndicator(
                      onRefresh: _fetchMyReviews,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: myReviews.length,
                        itemBuilder: (context, idx) {
                          final review = myReviews[idx];
                          return Card(
                            child: ListTile(
                              leading: Icon(Icons.star,
                                  color: Colors.amber[700], size: 32),
                              title: Text(
                                review.title?.isNotEmpty == true
                                    ? review.title!
                                    : 'Review – ${review.productId}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    review.body ?? "",
                                    style: const TextStyle(fontSize: 16),
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
                                      const SizedBox(width: 8),
                                      Text(
                                        'For Product: ${review.productId}',
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'Reviewed on ${DateFormat('yyyy-MM-dd').format(review.createdAt)}',
                                    style: TextStyle(fontSize: 11, color: Colors.grey[700]),
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
