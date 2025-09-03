import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../repositories/restaurant_repository.dart';

class GetUserimages {
  final RestaurantRepository repository;

  GetUserimages(this.repository);
  Future<Either<Failure, List<String>>> call(String slug) async {
    return await repository.getUserImages(slug);
  }
}
