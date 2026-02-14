
import 'package:fpdart/fpdart.dart';

import '../../../../../../core/error/failures.dart';
import '../../entities/menu.dart';
import '../../repositories/restaurant_repository.dart';

class GetMenu {
  final RestaurantRepository repository;

  GetMenu(this.repository);

  Future<Either<Failure, Menu>> call(String restaurantId) async {
    return await repository.getMenu(restaurantId);
  }
}
