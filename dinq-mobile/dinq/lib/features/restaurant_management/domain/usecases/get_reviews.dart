import 'package:dartz/dartz.dart';
import 'package:dinq/core/error/failures.dart';
import 'package:dinq/features/restaurant_management/domain/entities/review.dart';
import 'package:dinq/features/restaurant_management/domain/repositories/restaurant_repository.dart';

class GetReviews {
  final RestaurantRepository repository;

  GetReviews(this.repository);
  Future<Either<Failure, List<Review>>> call(String itemId) async {
    return await repository.getReviews(itemId);
  }
}
