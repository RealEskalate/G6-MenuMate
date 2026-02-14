// import 'package:dartz/dartz.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../../../core/error/failures.dart';
import '../../entities/review.dart';
import '../../repositories/restaurant_repository.dart';

class GetReviews {
  final RestaurantRepository repository;

  GetReviews(this.repository);
  Future<Either<Failure, List<Review>>> call(String itemId) async {
    return await repository.getReviews(itemId);
  }
}
