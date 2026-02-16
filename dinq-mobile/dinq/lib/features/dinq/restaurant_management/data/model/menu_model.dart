import 'dart:convert';
import '../../domain/entities/menu.dart';
import '../../domain/entities/item.dart';
import 'item_model.dart';
import 'category_model.dart';

class MenuModel extends Menu {
  const MenuModel({
    required super.id,
    required super.restaurantId,
    super.name,
    super.slug,
    super.version,
    required super.isPublished,
    required super.items,
    super.createdAt,
    super.updatedAt,
  });

  /// Convert a Menu to a list of CategoryModels (each menu = 1 category)
  List<CategoryModel> get asCategory => [CategoryModel.fromMenu(this)];

  factory MenuModel.fromMap(Map<String, dynamic> data) => MenuModel(
        id: data['id'] ?? '',
        restaurantId: data['restaurant_id'] ?? '',
        name: data['name'],
        slug: data['slug'],
        version: (data['version'] as num?)?.toInt(),
        isPublished: data['is_published'] ?? false,
        items: (data['items'] as List<dynamic>?)
                ?.map((e) => ItemModel.fromMap(e as Map<String, dynamic>))
                .toList() ??
            [],
        createdAt: data['created_at'] != null
            ? DateTime.tryParse(data['created_at'] as String)
            : null,
        updatedAt: data['updated_at'] != null
            ? DateTime.tryParse(data['updated_at'] as String)
            : null,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'restaurant_id': restaurantId,
        if (name != null) 'name': name,
        if (slug != null) 'slug': slug,
        if (version != null) 'version': version,
        'is_published': isPublished,
        'items': items.map((e) => (e as ItemModel).toMap()).toList(),
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      };

  Menu toEntity() => this;

  factory MenuModel.fromEntity(Menu entity) => MenuModel(
        id: entity.id,
        restaurantId: entity.restaurantId,
        name: entity.name,
        slug: entity.slug,
        version: entity.version,
        isPublished: entity.isPublished,
        items: entity.items.map((e) => ItemModel.fromEntity(e)).toList(),
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
      );
}
