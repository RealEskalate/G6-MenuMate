import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/category.dart';
import '../repositories/restaurant_repository.dart';

class GetCategories {
  final RestaurantRepository repository;

  GetCategories(this.repository);

  Future<Either<Failure, List<Category>>> call(String tabId) async {
    return await repository.getCategories(tabId);
  }
}