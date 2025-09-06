import 'package:dartz/dartz.dart';
import '../../../../../../core/error/failures.dart';
import '../../entities/menu.dart';
import '../../repositories/menu_repository.dart';

class UpdateMenu {
  final MenuRepository repository;

  UpdateMenu(this.repository);

  Future<Either<Failure, Menu>> call({
    required String restaurantSlug,
    required String menuId,
    String? title,
    String? description,
  }) async {
    return await repository.updateMenu(
      restaurantSlug: restaurantSlug,
      menuId: menuId,
      title: title,
      description: description,
    );
  }
}
