import 'dart:io';
import 'package:dartz/dartz.dart';

import '../../../../../../core/error/failures.dart';
import '../entities/menu.dart';
import '../entities/qr.dart';
import '../../data/model/menu_create_model.dart';

abstract class MenuRepository {
  Future<Either<Failure, MenuCreateModel>> uploadMenu(File printedMenu);
  Future<Either<Failure, Menu>> createMenu(Menu menu);
  Future<Either<Failure, Menu>> publishMenu(
      {required String restaurantSlug, required String menuId});
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
  });
  Future<Either<Failure, void>> deleteMenu(String menuId);
  Future<Either<Failure, Menu>> updateMenu(
      {required String restaurantSlug,
      required String menuId,
      String? title,
      String? description});
  Future<Either<Failure, Menu>> getMenu(String restaurantSlug);
  // Future<Either<Failure, void>> updateItem();
}
