import 'package:dartz/dartz.dart';

import '../../../../../core/error/exceptions.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/network/network_info.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/menu.dart';
import '../../domain/entities/restaurant.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/restaurant_repository.dart';
import '../datasources/restaurant_remote_data_source.dart';
import '../model/restaurant_model.dart';

class RestaurantRepositoryImpl implements RestaurantRepository {
  final RestaurantRemoteDataSource remoteDataSource;
  final NetworkInfo network;

  RestaurantRepositoryImpl({
    required this.remoteDataSource,
    required this.network,
  });

  @override
  Future<Either<Failure, List<Restaurant>>> getRestaurants({
    int page = 1,
    int pageSize = 20,
  }) async {
    if (await network.isConnected) {
      try {
        final restaurants = await remoteDataSource.getRestaurants();
        return Right(restaurants.map((model) => model).toList());
      } catch (e) {
        return Left(ExceptionMapper.toFailure(e as Exception));
      }
    } else {
      return const Left(
        NetworkFailure(
          'No internet connection available. Please check your network settings and try again.',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Menu>> getMenu(String restaurantId) async {
    if (await network.isConnected) {
      try {
        final menuInfo = await remoteDataSource.getMenu(restaurantId);
        return Right(menuInfo);
      } catch (e) {
        return Left(ExceptionMapper.toFailure(e as Exception));
      }
    } else {
      return const Left(
        NetworkFailure(
          'No internet connection available. Please check your network settings and try again.',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<Category>>> getCategories(String tabId) async {
    if (await network.isConnected) {
      try {
        final categoryResponse = await remoteDataSource.getCategories(tabId);
        return Right(categoryResponse);
      } catch (e) {
        return Left(ExceptionMapper.toFailure(e as Exception));
      }
    } else {
      return const Left(
        NetworkFailure(
          'No internet connection available. Please check your network settings and try again.',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<Review>>> getReviews(String itemId) async {
    if (await network.isConnected) {
      try {
        final itemDetails = await remoteDataSource.getReviews(itemId);
        return Right(itemDetails);
      } catch (e) {
        return Left(ExceptionMapper.toFailure(e as Exception));
      }
    } else {
      return const Left(
        NetworkFailure(
          'No internet connection available. Please check your network settings and try again.',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<String>>> getUserImages(String slug) async {
    if (await network.isConnected) {
      try {
        final itemDetails = await remoteDataSource.getUserImages(slug);
        return Right(itemDetails);
      } catch (e) {
        return Left(ExceptionMapper.toFailure(e as Exception));
      }
    } else {
      return const Left(
        NetworkFailure(
          'No internet connection available. Please check your network settings and try again.',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Restaurant>> createRestaurant(
    RestaurantModel restaurant,
  ) async {
    if (await network.isConnected) {
      try {
        final result = await remoteDataSource.createRestaurant(restaurant);
        return Right(result);
      } catch (e) {
        return Left(ExceptionMapper.toFailure(e as Exception));
      }
    } else {
      return const Left(
        NetworkFailure(
          'No internet connection available. Please check your network settings and try again.',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Restaurant>> getRestaurantBySlug(String slug) async {
    if (await network.isConnected) {
      try {
        final restaurant = await remoteDataSource.getRestaurantBySlug(slug);
        return Right(restaurant);
      } catch (e) {
        return Left(ExceptionMapper.toFailure(e as Exception));
      }
    } else {
      return const Left(
        NetworkFailure(
          'No internet connection available. Please check your network settings and try again.',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Restaurant>> updateRestaurant(
    RestaurantModel restaurant,
    String slug,
  ) async {
    if (await network.isConnected) {
      try {
        final updatedRestaurant = await remoteDataSource.updateRestaurant(
          restaurant,
          slug,
        );
        return Right(updatedRestaurant);
      } catch (e) {
        return Left(ExceptionMapper.toFailure(e as Exception));
      }
    } else {
      return const Left(
        NetworkFailure(
          'No internet connection available. Please check your network settings and try again.',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteRestaurant(String restaurantId) async {
    if (await network.isConnected) {
      try {
        await remoteDataSource.deleteRestaurant(restaurantId);
        return const Right(null);
      } catch (e) {
        return Left(ExceptionMapper.toFailure(e as Exception));
      }
    } else {
      return const Left(
        NetworkFailure(
          'No internet connection available. Please check your network settings and try again.',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> updateItem() {
    // TODO: implement updateItem
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> updateMenu(Menu menu) {
    // TODO: implement updateMenu
    throw UnimplementedError();
  }
}
