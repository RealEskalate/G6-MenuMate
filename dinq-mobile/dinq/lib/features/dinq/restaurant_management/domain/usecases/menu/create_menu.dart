import 'package:dartz/dartz.dart';
import '../../../../../../core/error/failures.dart';
import '../../entities/menu.dart';
import '../../repositories/menu_repository.dart';

class CreateMenu {
  final MenuRepository repository;

  CreateMenu(this.repository);

  Future<Either<Failure, Menu>> call(Menu menu) async {
    return await repository.createMenu(menu);
  }
}
