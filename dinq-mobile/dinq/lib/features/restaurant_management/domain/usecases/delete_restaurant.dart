import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/restaurant_repository.dart';

class DeleteRestaurant {
  final RestaurantRepository repository;

  DeleteRestaurant(this.repository);

  Future<Either<Failure, void>> call(String restaurantId) async {
    return await repository.deleteRestaurant(restaurantId);
  }
}
