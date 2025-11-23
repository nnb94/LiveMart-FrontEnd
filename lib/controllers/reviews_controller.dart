import 'package:get/get.dart';
import '../../models/review.dart';
import '../../services/api_service.dart';

class ReviewController extends GetxController {
  final String productId;
  final String? accessToken; // null means "view only" (not logged in)

  ReviewController({required this.productId, this.accessToken});

  // Observable reactive variables
  final reviews = <Review>[].obs;
  final myReview = Rxn<Review>(); // current user's review, if it exists
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchReviews();
  }

  /// Fetch all reviews for this product, and user's own review if authenticated.
  Future<void> fetchReviews() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final allReviews = await ApiService().getProductReviews(productId);
      reviews.value = allReviews;
      if (accessToken != null) {
        // Try to get user's own review from all reviews (if included)
        // Or, more reliably, fetch all my reviews and filter here:
        final myReviews = await ApiService().getMyReviews(accessToken!);
        final Review? found = myReviews.firstWhereOrNull((r) => r.productId.toString() == productId);
        myReview.value = found;
      } else {
        myReview.value = null;
      }
    } catch (e) {
      errorMessage.value = e.toString();
      reviews.clear();
      myReview.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  /// Submit (add or update) a review for this product.
  Future<void> submitReview({
    required int rating,
    String? title,
    String? body,
  }) async {
    if (accessToken == null) {
      errorMessage.value = "Not authenticated.";
      return;
    }
    try {
      isLoading.value = true;
      errorMessage.value = '';
      await ApiService().submitReview(
        productId: int.parse(productId),
        rating: rating,
        title: title,
        body: body,
        accessToken: accessToken!,
      );
      await fetchReviews(); // To refresh reviews after submitting
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Update an existing review by ID (usually you don't need this unless having owner-only separate update page)
  Future<void> updateReview({
    required int reviewId,
    int? rating,
    String? title,
    String? body,
  }) async {
    if (accessToken == null) {
      errorMessage.value = "Not authenticated.";
      return;
    }
    try {
      isLoading.value = true;
      errorMessage.value = '';
      await ApiService().updateReview(
        id: reviewId,
        rating: rating,
        title: title,
        body: body,
        accessToken: accessToken!,
      );
      await fetchReviews();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete a review by ID (only if you allow users to delete their review completely)
  Future<void> deleteReview({required int reviewId}) async {
    if (accessToken == null) {
      errorMessage.value = "Not authenticated.";
      return;
    }
    try {
      isLoading.value = true;
      errorMessage.value = '';
      await ApiService().deleteReview(
        id: reviewId,
        accessToken: accessToken!,
      );
      await fetchReviews();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
