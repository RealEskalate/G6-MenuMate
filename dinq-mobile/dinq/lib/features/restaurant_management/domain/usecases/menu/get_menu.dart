import 'package:dartz/dartz.dart';
import '../../../../../../core/error/failures.dart';
import '../../entities/menu.dart';
import '../../repositories/menu_repository.dart';

class GetMenu {
  final MenuRepository repository;

  GetMenu(this.repository);

  Future<Either<Failure, Menu>> call(String restaurantSlug) async {
    return await repository.getMenu(restaurantSlug);
  }
}
