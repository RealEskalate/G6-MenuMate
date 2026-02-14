// import 'package:dartz/dartz.dart';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../../../core/error/failures.dart';
import '../../entities/restaurant.dart';
import '../../repositories/restaurant_repository.dart';

class CreateRestaurant {
  final RestaurantRepository repository;

  CreateRestaurant(this.repository);

  Future<Either<Failure, Restaurant>> call(FormData restaurant) async {
    return await repository.createRestaurant(restaurant);
  }
}
