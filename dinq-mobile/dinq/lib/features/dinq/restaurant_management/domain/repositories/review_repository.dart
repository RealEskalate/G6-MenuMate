import 'package:dartz/dartz.dart';

import '../../../../../../core/error/failures.dart';
import '../entities/review.dart';

abstract class ReviewRepository {
  Future<Either<Failure, List<Review>>> getReviews(String itemId);
  Future<Either<Failure, void>> deleteReview(String reviewId);
  Future<Either<Failure, List<String>>> getUserImages(String slug);
}
