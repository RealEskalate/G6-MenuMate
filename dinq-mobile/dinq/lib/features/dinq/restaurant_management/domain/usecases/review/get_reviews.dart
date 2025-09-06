import 'package:dartz/dartz.dart';
import '../../../../../../core/error/failures.dart';
import '../../entities/review.dart';
import '../../repositories/review_repository.dart';

class GetReviews {
  final ReviewRepository repository;

  GetReviews(this.repository);
  Future<Either<Failure, List<Review>>> call(String itemId) async {
    return await repository.getReviews(itemId);
  }
}
