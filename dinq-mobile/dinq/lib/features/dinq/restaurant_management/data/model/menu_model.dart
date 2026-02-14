import 'dart:convert';

import '../../domain/entities/menu.dart';
import '../../domain/entities/item.dart';
import 'item_model.dart';

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

  factory MenuModel.fromMap(Map<String, dynamic> data) {
    return MenuModel(
      id: data['id'] ?? data['menu_id'] ?? '',
      restaurantId: data['restaurant_id'] ?? data['restaurantId'] ?? '',
      name: data['name'],
      slug: data['slug'],
      version: (data['version'] as num?)?.toInt(),
      isPublished: data['is_published'] ?? data['isPublished'] ?? false,
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
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'restaurant_id': restaurantId,
      if (name != null) 'name': name,
      if (slug != null) 'slug': slug,
      if (version != null) 'version': version,
      'is_published': isPublished,
      'items': items
          .map((e) => (e as ItemModel).toMap())
          .toList(),
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  factory MenuModel.fromJson(String data) {
    return MenuModel.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  String toJson() => json.encode(toMap());

  MenuModel copyWith({
    String? id,
    String? restaurantId,
    String? name,
    String? slug,
    int? version,
    bool? isPublished,
    List<Item>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MenuModel(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      version: version ?? this.version,
      isPublished: isPublished ?? this.isPublished,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool get stringify => true;

  Menu toEntity() => this;

  factory MenuModel.fromEntity(Menu entity) {
    return MenuModel(
      id: entity.id,
      restaurantId: entity.restaurantId,
      name: entity.name,
      slug: entity.slug,
      version: entity.version,
      isPublished: entity.isPublished,
      items:
          entity.items.map((e) => ItemModel.fromEntity(e)).toList(),
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
