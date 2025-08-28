import 'package:dartz/dartz.dart';
import 'package:dinq/core/error/failures.dart';
import 'package:dinq/features/restaurant_management/domain/entities/category.dart';
import 'package:dinq/features/restaurant_management/domain/repositories/restaurant_repository.dart';

class GetCategories {
  final RestaurantRepository repository;

  GetCategories(this.repository);

  Future<Either<Failure, List<Category>>> call(String tabId) async {
    return await repository.getCategories(tabId);
  }
}
