import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../repositories/restaurant_repository.dart';

class UpdateItem {
  final RestaurantRepository repository;

  UpdateItem(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.updateItem();
  }
}
