import 'package:dartz/dartz.dart';
import '../../../../../../core/error/failures.dart';
import '../../entities/restaurant.dart';
import '../../repositories/restaurant_repository.dart';

class GetRestaurants {
  final RestaurantRepository repository;

  GetRestaurants(this.repository);

  Future<Either<Failure, List<Restaurant>>> call({
    int page = 1,
    int pageSize = 1,
  }) async {
    // debug: log usecase invocation
    // ignore: avoid_print
    print('GetRestaurants called - page: $page, pageSize: $pageSize');
    return await repository.getRestaurants(page: page, pageSize: pageSize);
  }
}
