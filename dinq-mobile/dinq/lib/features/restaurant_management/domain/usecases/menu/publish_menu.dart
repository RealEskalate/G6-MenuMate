import 'package:dartz/dartz.dart';
import '../../../../../../core/error/failures.dart';
import '../../entities/menu.dart';
import '../../repositories/menu_repository.dart';

class PublishMenu {
  final MenuRepository repository;

  PublishMenu(this.repository);

  Future<Either<Failure, Menu>> call(
      {required String restaurantSlug, required String menuId}) async {
    return await repository.publishMenu(
        restaurantSlug: restaurantSlug, menuId: menuId);
  }
}
