import 'package:dartz/dartz.dart';

import '../../../../../../core/error/failures.dart';
import '../../repositories/restaurant_repository.dart';

class DeleteMenu {
  final RestaurantRepository repository;
  DeleteMenu(this.repository);

  Future<Either<Failure, void>> call(String menuId) async {
    return await repository.deleteMenu(menuId);
  }
}
