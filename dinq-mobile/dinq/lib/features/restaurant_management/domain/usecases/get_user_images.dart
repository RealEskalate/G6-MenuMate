import 'package:dartz/dartz.dart';
import 'package:dinq/core/error/failures.dart';
import 'package:dinq/features/restaurant_management/domain/repositories/restaurant_repository.dart';

class GetUserimages {
  final RestaurantRepository repository;

  GetUserimages(this.repository);
  Future<Either<Failure, List<String>>> call(String slug) async {
    return await repository.getUserImages(slug);
  }
}
