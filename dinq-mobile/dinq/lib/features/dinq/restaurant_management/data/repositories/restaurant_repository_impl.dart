import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../../core/error/exceptions.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/network/network_info.dart';
import '../../domain/entities/restaurant.dart';
import '../../domain/repositories/restaurant_repository.dart';
import '../datasources/restaurant/restaurant_remote_data_source_restaurant.dart';

class RestaurantRepositoryImpl implements RestaurantRepository {
  final RestaurantRemoteDataSource restRemoteDataSource;
  final NetworkInfo network;

  RestaurantRepositoryImpl({
    required this.restRemoteDataSource,
    required this.network,
  });

  // Restaurant
  @override
  Future<Either<Failure, Restaurant>> createRestaurant(
    FormData restaurant,
  ) async {
    final connected = await network.isConnected;
    if (connected) {
      try {
        final resultModel = await restRemoteDataSource.createRestaurant(
          restaurant,
        );
        return Right(resultModel.toEntity());
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
  Future<Either<Failure, List<Restaurant>>> getRestaurants({
    int page = 1,
    int pageSize = 20,
  }) async {
    final connected = await network.isConnected;
    // debug: log network connectivity
    // ignore: avoid_print
    print(
        'RestaurantRepositoryImpl.getRestaurants - network.isConnected: $connected');

    if (connected) {
      try {
        // debug: indicate remote datasource will be called
        // ignore: avoid_print
        print(
            'RestaurantRepositoryImpl.getRestaurants - calling remote datasource');
        final restaurants = await restRemoteDataSource.getRestaurants(
            page: page, pageSize: pageSize);
        return Right(restaurants.map((model) => model.toEntity()).toList());
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
    final connected = await network.isConnected;
    if (connected) {
      try {
        final restaurantModel = await restRemoteDataSource.getRestaurantBySlug(
          slug,
        );
        return Right(restaurantModel.toEntity());
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
    FormData restaurant,
    String slug,
  ) async {
    final connected = await network.isConnected;
    if (connected) {
      try {
        final updatedModel = await restRemoteDataSource.updateRestaurant(
          restaurant,
          slug,
        );
        return Right(updatedModel.toEntity());
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
    final connected = await network.isConnected;
    if (connected) {
      try {
        await restRemoteDataSource.deleteRestaurant(restaurantId);
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

  // Menu

  // Review
}
