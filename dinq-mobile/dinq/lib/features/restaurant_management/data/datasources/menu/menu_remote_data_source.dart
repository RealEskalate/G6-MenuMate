import 'dart:io';

import '../../model/menu_create_model.dart';
import '../../model/menu_model.dart';
import '../../model/qr_model.dart';

abstract class MenuRemoteDataSource {
  Future<MenuCreateModel> uploadMenu(File printedMenu);
  Future<MenuModel> createMenu(MenuCreateModel menu);
  Future<MenuModel> publishMenu(
      {required String restaurantSlug, required String menuId});
  Future<QrModel> generateQr({
    required String restaurantSlug,
    required String menuId,
    required Map<String, Object?> custom,
  });
  Future<void> deleteMenu(String menuId);
  Future<MenuModel> updateMenu(
      {required String restaurantSlug,
      required String menuId,
      String? title,
      String? description});
  Future<MenuModel> getMenu(String restaurantSlug);
}
