import 'package:fpdart/fpdart.dart';

import '../../../../../../core/error/failures.dart';
import '../../../../../../core/usecase/usecase.dart';
import '../../entities/restaurant.dart';
import '../../repositories/restaurant_repository.dart';

class GetRestaurants implements UseCase<List<Restaurant>, GetRestaurantsParams> {
  final RestaurantRepository repository;

  const GetRestaurants(this.repository);

  @override
  Future<Either<Failure, List<Restaurant>>> call(GetRestaurantsParams params) async {
    return await repository.getRestaurants(
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}

class GetRestaurantsParams {
  final int page;
  final int pageSize;

  const GetRestaurantsParams({this.page = 1, this.pageSize = 20});
}
