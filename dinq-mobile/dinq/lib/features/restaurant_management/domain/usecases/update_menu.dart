import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/menu.dart';
import '../repositories/restaurant_repository.dart';

class UpdateMenu {
  final RestaurantRepository repository;

  UpdateMenu(this.repository);

  Future<Either<Failure, void>> call(Menu menu) async {
    return await repository.updateMenu(menu);
  }
}
