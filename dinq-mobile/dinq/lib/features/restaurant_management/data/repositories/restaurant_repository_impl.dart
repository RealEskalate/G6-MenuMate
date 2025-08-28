import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/menu.dart';
import '../../domain/entities/restaurant.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/restaurant_repository.dart';
import '../datasources/restaurant_remote_data_source.dart';

class RestaurantRepositoryImpl implements RestaurantRepository {
  final RestaurantRemoteDataSource remoteDataSource;

  RestaurantRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Restaurant>>> getRestaurants() async {
    try {
      final restaurants = await remoteDataSource.getRestaurants();
      return Right(restaurants.map((model) => model).toList());
    } catch (e) {
      return Left(ExceptionMapper.toFailure(e as Exception));
    }
  }

  @override
  Future<Either<Failure, Menu>> getMenu(String restaurantId) async {
    try {
      final menuInfo = await remoteDataSource.getMenu(restaurantId);
      return Right(menuInfo);
    } catch (e) {
      return Left(ExceptionMapper.toFailure(e as Exception));
    }
  }

  @override
  Future<Either<Failure, List<Category>>> getCategories(String tabId) async {
    try {
      final categoryResponse = await remoteDataSource.getCategories(tabId);
      return Right(categoryResponse);
    } catch (e) {
      return Left(ExceptionMapper.toFailure(e as Exception));
    }
  }

  @override
  Future<Either<Failure, List<Review>>> getReviews(String itemId) async {
    try {
      final itemDetails = await remoteDataSource.getReviews(itemId);
      return Right(itemDetails);
    } catch (e) {
      return Left(ExceptionMapper.toFailure(e as Exception));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getUserImages(String slug) async {
    try {
      final itemDetails = await remoteDataSource.getUserImages(slug);
      return Right(itemDetails);
    } catch (e) {
      return Left(ExceptionMapper.toFailure(e as Exception));
    }
  }
}
