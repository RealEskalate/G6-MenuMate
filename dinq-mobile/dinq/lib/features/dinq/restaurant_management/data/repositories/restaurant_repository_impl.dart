import 'dart:io';

// import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../../core/error/exceptions.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/network/network_info.dart';
import '../../domain/entities/menu.dart';
import '../../domain/entities/restaurant.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/restaurant_repository.dart';
import '../datasources/restaurant_remote_data_source.dart';
import '../model/menu_model.dart';

class RestaurantRepositoryImpl implements RestaurantRepository {
  final RestaurantRemoteDataSource remoteDataSource;
  final NetworkInfo network;

  RestaurantRepositoryImpl({
    required this.remoteDataSource,
    required this.network,
  });

  @override
  Future<Either<Failure, List<Menu>>> getListOfMenus(String slug) async {
    final connected = await network.isConnected;
    print('[Reop] getListOfMenus - isconnected = $connected');
    try {
      final listMenus = await remoteDataSource.getListOfMenues(slug);
      print(listMenus);
      return Right(listMenus);
    } catch (e) {
      return Left(ExceptionMapper.toFailure(e as Exception));
    }
  }

  // Restaurant
  @override
  Future<Either<Failure, Restaurant>> createRestaurant(
    FormData restaurant,
  ) async {
    final connected = await network.isConnected;
    print('[Repo] createRestaurant - isConnected=$connected');
    if (connected) {
      try {
        final resultModel = await remoteDataSource.createRestaurant(
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
    print('[Repo] getRestaurants - isConnected=$connected');
    if (connected) {
      try {
        final restaurants = await remoteDataSource.getRestaurants();
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
    print('[Repo] getRestaurantBySlug - isConnected=$connected slug=$slug');
    if (connected) {
      try {
        final restaurantModel = await remoteDataSource.getRestaurantBySlug(
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
    Map<String, dynamic> restaurant,
    String slug,
  ) async {
    final connected = await network.isConnected;
    print('[Repo] updateRestaurant - isConnected=$connected slug=$slug');
    if (connected) {
      try {
        final updatedModel = await remoteDataSource.updateRestaurant(
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
    print('[Repo] deleteRestaurant - isConnected=$connected id=$restaurantId');
    if (connected) {
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

  // Menu

  @override
  Future<Either<Failure, Menu>> uploadMenu(File printedMenu) async {
    final connected = await network.isConnected;
    if (connected) {
      try {
        final menuModel = await remoteDataSource.uploadMenu(printedMenu);
        return Right(menuModel.toEntity());
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
    final connected = await network.isConnected;
    print('[Repo] getMenu - isConnected=$connected restaurantId=$restaurantId');
    if (connected) {
      try {
        final menuModel = await remoteDataSource.getMenu(restaurantId);
        return Right(menuModel.toEntity());
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
  Future<Either<Failure, void>> deleteMenu(String menuId) async {
    final connected = await network.isConnected;
    print('[Repo] deleteMenu - isConnected=$connected menuId=$menuId');
    if (connected) {
      try {
        await remoteDataSource.deleteMenu(menuId);
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
  Future<Either<Failure, Menu>> updateMenu(Menu menu) async {
    final connected = await network.isConnected;
    print('[Repo] updateMenu - isConnected=$connected menuId=${menu.id}');
    if (connected) {
      try {
        final updatedModel = await remoteDataSource.updateMenu(
          MenuModel.fromEntity(menu),
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

  // Review
  @override
  Future<Either<Failure, List<Review>>> getReviews(String itemId) async {
    final connected = await network.isConnected;
    print('[Repo] getReviews - isConnected=$connected itemId=$itemId');
    if (connected) {
      try {
        final reviewModels = await remoteDataSource.getReviews(itemId);
        return Right(reviewModels.map((m) => m.toEntity()).toList());
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
  Future<Either<Failure, List<Restaurant>>> searchRestaurants(
      String name) async {
    final connected = await network.isConnected;
    print('[Repo] getReviews - isConnected=$connected search for =$name');
    if (connected) {
      try {
        final restaurants =
            await remoteDataSource.searchRestaurants(name: name);
        return Right(restaurants.map((m) => m.toEntity()).toList());
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
  Future<Either<Failure, void>> deleteReview(String reviewId) async {
    final connected = await network.isConnected;
    print('[Repo] deleteReview - isConnected=$connected reviewId=$reviewId');
    if (connected) {
      try {
        await remoteDataSource.deleteReview(reviewId);
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

  // User Image
  @override
  Future<Either<Failure, List<String>>> getUserImages(String slug) async {
    final connected = await network.isConnected;
    print('[Repo] getUserImages - isConnected=$connected slug=$slug');
    if (connected) {
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
}
