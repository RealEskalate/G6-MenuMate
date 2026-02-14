
import 'package:fpdart/fpdart.dart';

import '../../../../../core/error/failures.dart';
import '../repositories/restaurant_repository.dart';

class GetUserImages {
  final RestaurantRepository repository;

  GetUserImages(this.repository);
  Future<Either<Failure, List<String>>> call(String slug) async {
    return await repository.getUserImages(slug);
  }
}
