import 'package:fpdart/fpdart.dart';

import '../../../../../../core/error/failures.dart';
import '../../../../../../core/usecase/usecase.dart';
import '../../entities/restaurant.dart';
import '../../repositories/restaurant_repository.dart';

class SearchRestaurants implements UseCase<List<Restaurant>, SearchRestaurantsParams> {
  final RestaurantRepository restaurantRepository;
  const SearchRestaurants(this.restaurantRepository);
  @override
  Future<Either<Failure, List<Restaurant>>> call(
      SearchRestaurantsParams params) async {
    return await restaurantRepository.searchRestaurants(params.name);
  }
}

class SearchRestaurantsParams {
  final String name;
  SearchRestaurantsParams({required this.name});
}
