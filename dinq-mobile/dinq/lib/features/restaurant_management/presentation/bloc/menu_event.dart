import 'dart:io';

import 'package:equatable/equatable.dart';

import '../../domain/entities/menu.dart';

abstract class MenuEvent extends Equatable {
  const MenuEvent();

  @override
  List<Object?> get props => [];
}

class LoadMenuEvent extends MenuEvent {
  final String restaurantSlug;

  const LoadMenuEvent({required this.restaurantSlug});

  @override
  List<Object?> get props => [restaurantSlug];
}

class CreateMenuEvent extends MenuEvent {
  final Menu menu;

  const CreateMenuEvent(this.menu);

  @override
  List<Object?> get props => [menu];
}

class UpdateMenuEvent extends MenuEvent {
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

class DeleteMenuEvent extends MenuEvent {
  final String menuId;

  const DeleteMenuEvent(this.menuId);

  @override
  List<Object?> get props => [menuId];
}

class UploadMenuEvent extends MenuEvent {
  final File menuFile;

  const UploadMenuEvent(this.menuFile);

  @override
  List<Object?> get props => [menuFile];
}

class PublishMenuEvent extends MenuEvent {
  final String restaurantSlug;
  final String menuId;

  const PublishMenuEvent({required this.restaurantSlug, required this.menuId});

  @override
  List<Object?> get props => [restaurantSlug, menuId];
}

class GenerateMenuQrEvent extends MenuEvent {
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
