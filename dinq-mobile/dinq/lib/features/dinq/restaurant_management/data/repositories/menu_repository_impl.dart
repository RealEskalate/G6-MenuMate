import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../../core/error/exceptions.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/network/network_info.dart';
import '../../domain/entities/menu.dart';
import '../../domain/entities/qr.dart';
import '../../domain/repositories/menu_repository.dart';
import '../datasources/menu/menu_remote_data_source.dart';
import '../model/menu_create_model.dart';

class MenuRepositoryImpl implements MenuRepository {
  final NetworkInfo network;
  final MenuRemoteDataSource menuRemoteDataSource;

  MenuRepositoryImpl(
      {required this.network, required this.menuRemoteDataSource});

  @override
  Future<Either<Failure, MenuCreateModel>> uploadMenu(File printedMenu) async {
    final connected = await network.isConnected;
    if (connected) {
      try {
        final menuCreateModel =
            await menuRemoteDataSource.uploadMenu(printedMenu);
        return Right(menuCreateModel);
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
  Future<Either<Failure, Menu>> createMenu(Menu menu) async {
    final connected = await network.isConnected;
    if (connected) {
      try {
        final menuCreateModel = MenuCreateModel.fromEntity(menu);
        final resultModel =
            await menuRemoteDataSource.createMenu(menuCreateModel);
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
  Future<Either<Failure, Menu>> getMenu(String restaurantId) async {
    final connected = await network.isConnected;
    if (connected) {
      try {
        final menuModel = await menuRemoteDataSource.getMenu(restaurantId);
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
  Future<Either<Failure, Qr>> generateMenuQr({
    required String restaurantSlug,
    required String menuId,
    int? size,
    int? quality,
    bool? includeLabel,
    String? backgroundColor,
    String? foregroundColor,
    String? gradientFrom,
    String? gradientTo,
    String? gradientDirection,
    String? logo,
    double? logoSizePercent,
    int? margin,
    String? labelText,
    String? labelColor,
    int? labelFontSize,
    String? labelFontUrl,
  }) async {
    final connected = await network.isConnected;
    if (connected) {
      try {
        final custom = {
          'size': size,
          'quality': quality,
          'includeLabel': includeLabel,
          'backgroundColor': backgroundColor,
          'foregroundColor': foregroundColor,
          'gradientFrom': gradientFrom,
          'gradientTo': gradientTo,
          'gradientDirection': gradientDirection,
          'logo': logo,
          'logoSizePercent': logoSizePercent,
          'margin': margin,
          'labelText': labelText,
          'labelColor': labelColor,
          'labelFontSize': labelFontSize,
          'labelFontUrl': labelFontUrl,
        };
        final qrModel = await menuRemoteDataSource.generateQr(
            custom: custom, restaurantSlug: restaurantSlug, menuId: menuId);
        return Right(qrModel.toEntity());
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
  Future<Either<Failure, Menu>> publishMenu(
      {required String restaurantSlug, required String menuId}) async {
    final connected = await network.isConnected;
    if (connected) {
      try {
        final menuModel = await menuRemoteDataSource.publishMenu(
          restaurantSlug: restaurantSlug,
          menuId: menuId,
        );
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
    if (connected) {
      try {
        await menuRemoteDataSource.deleteMenu(menuId);
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
  Future<Either<Failure, Menu>> updateMenu(
      {required String restaurantSlug,
      required String menuId,
      String? title,
      String? description}) async {
    final connected = await network.isConnected;
    if (connected) {
      try {
        final updatedModel = await menuRemoteDataSource.updateMenu(
          restaurantSlug: restaurantSlug,
          menuId: menuId,
          title: title,
          description: description,
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
}
