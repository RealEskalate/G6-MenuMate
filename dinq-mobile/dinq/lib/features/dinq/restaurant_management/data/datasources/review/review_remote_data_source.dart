import '../../model/review_model.dart';

abstract class ReviewRemoteDataSource {
  Future<List<ReviewModel>> getReviews(String itemId);
  Future<void> deleteReview(String reviewId);
  Future<List<String>> getUserImages(String slug);
}
