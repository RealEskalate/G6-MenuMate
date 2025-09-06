import 'dart:io';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/menu.dart';

abstract class RestaurantEvent extends Equatable {
  const RestaurantEvent();

  @override
  List<Object?> get props => [];
}

class LoadRestaurants extends RestaurantEvent {
  final int page;
  final int pageSize;

  const LoadRestaurants({required this.page, required this.pageSize});
}

class LoadMenu extends RestaurantEvent {
  final String restaurantId;

  const LoadMenu(this.restaurantId);

  @override
  List<Object?> get props => [restaurantId];
}

// class LoadCategories extends RestaurantEvent {
//   final String tabId;

//   const LoadCategories(this.tabId);

//   @override
//   List<Object?> get props => [tabId];
// }

class LoadReviews extends RestaurantEvent {
  final String itemId;

  const LoadReviews(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

class LoadUserImages extends RestaurantEvent {
  final String slug;

  const LoadUserImages(this.slug);

  @override
  List<Object?> get props => [slug];
}

class LoadRestaurantBySlug extends RestaurantEvent {
  final String slug;

  const LoadRestaurantBySlug(this.slug);

  @override
  List<Object?> get props => [slug];
}

class CreateRestaurantEvent extends RestaurantEvent {
  final FormData restaurantModel;

  const CreateRestaurantEvent(this.restaurantModel);

  @override
  List<Object?> get props => [restaurantModel];
}

class UpdateRestaurantEvent extends RestaurantEvent {
  final FormData restaurantModel;
  final String slug;

  const UpdateRestaurantEvent(this.restaurantModel, this.slug);

  @override
  List<Object?> get props => [restaurantModel, slug];
}

class DeleteRestaurantEvent extends RestaurantEvent {
  final String restaurantId;

  const DeleteRestaurantEvent(this.restaurantId);

  @override
  List<Object?> get props => [restaurantId];
}

// Menu-related events
class CreateMenuEvent extends RestaurantEvent {
  final Menu menu;

  const CreateMenuEvent(this.menu);

  @override
  List<Object?> get props => [menu];
}

class UpdateMenuEvent extends RestaurantEvent {
  final String restaurantSlug;
  final String menuId;
  final String? title;
  final String? description;

  const UpdateMenuEvent({
    required this.restaurantSlug,
    required this.menuId,
    this.title,
    this.description,
  });

  @override
  List<Object?> get props => [restaurantSlug, menuId, title, description];
}

class DeleteMenuEvent extends RestaurantEvent {
  final String menuId;

  const DeleteMenuEvent(this.menuId);

  @override
  List<Object?> get props => [menuId];
}

class UploadMenuEvent extends RestaurantEvent {
  final File menuFile;

  const UploadMenuEvent(this.menuFile);

  @override
  List<Object?> get props => [menuFile];
}

class PublishMenuEvent extends RestaurantEvent {
  final String restaurantSlug;
  final String menuId;

  const PublishMenuEvent({required this.restaurantSlug, required this.menuId});

  @override
  List<Object?> get props => [restaurantSlug, menuId];
}

class GenerateMenuQrEvent extends RestaurantEvent {
  final String restaurantSlug;
  final String menuId;
  final int? size;
  final int? quality;
  final bool? includeLabel;
  final String? backgroundColor;
  final String? foregroundColor;
  final String? gradientFrom;
  final String? gradientTo;
  final String? gradientDirection;
  final String? logo;
  final double? logoSizePercent;
  final int? margin;
  final String? labelText;
  final String? labelColor;
  final int? labelFontSize;
  final String? labelFontUrl;

  const GenerateMenuQrEvent({
    required this.restaurantSlug,
    required this.menuId,
    this.size,
    this.quality,
    this.includeLabel,
    this.backgroundColor,
    this.foregroundColor,
    this.gradientFrom,
    this.gradientTo,
    this.gradientDirection,
    this.logo,
    this.logoSizePercent,
    this.margin,
    this.labelText,
    this.labelColor,
    this.labelFontSize,
    this.labelFontUrl,
  });

  @override
  List<Object?> get props => [
        restaurantSlug,
        menuId,
        size,
        quality,
        includeLabel,
        backgroundColor,
        foregroundColor,
        gradientFrom,
        gradientTo,
        gradientDirection,
        logo,
        logoSizePercent,
        margin,
        labelText,
        labelColor,
        labelFontSize,
        labelFontUrl,
      ];
}
