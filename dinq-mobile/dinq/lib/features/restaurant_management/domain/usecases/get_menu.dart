import 'package:dartz/dartz.dart';
import 'package:dinq/core/error/failures.dart';
import 'package:dinq/features/restaurant_management/domain/entities/menu.dart';
import 'package:dinq/features/restaurant_management/domain/repositories/restaurant_repository.dart';

class GetMenu {
  final RestaurantRepository repository;

  GetMenu(this.repository);

  Future<Either<Failure, Menu>> call(String restaurantId) async {
    return await repository.getMenu(restaurantId);
  }
}
