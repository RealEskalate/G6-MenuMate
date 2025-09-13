import 'package:dartz/dartz.dart';
import '../../../../../../core/error/failures.dart';
import '../repositories/user_repository.dart';


class DeleteFavoriteId {
  final UserRepository repository;

  DeleteFavoriteId(this.repository);

  Future<Either<Failure, Unit>> call(String id) async {
    return await repository.deleteFavoriteRestaurantId(id);
  }
}