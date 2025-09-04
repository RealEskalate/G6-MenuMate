import 'package:dartz/dartz.dart';
import '../../../../../../core/error/failures.dart';
import '../../repositories/restaurant_repository.dart';

class DeleteReview {
  final RestaurantRepository repository;

  DeleteReview(this.repository);

  Future<Either<Failure, void>> call(String reviewId) async {
    return await repository.deleteReview(reviewId);
  }
}
