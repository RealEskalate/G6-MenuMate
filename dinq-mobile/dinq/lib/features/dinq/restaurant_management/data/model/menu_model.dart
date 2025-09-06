import 'dart:convert';

import '../../domain/entities/item.dart';
import '../../domain/entities/menu.dart';
import 'item_model.dart';

class MenuModel extends Menu {
  const MenuModel({
    required super.id,
    required super.restaurantId,
    required super.name,
    super.slug,
    super.version,
    required super.isPublished,
    required super.items,
    required super.viewCount,
    super.isDeleted,
    super.createdAt,
    super.updatedAt,
    super.averageRating,
  });

  factory MenuModel.fromMap(Map<String, dynamic> data) => MenuModel(
        id: data['id'] ?? data['menu_id'] ?? '',
        restaurantId: data['restaurant_id'] ?? data['restaurantId'] ?? '',
        name: data['name'] ?? data['menu_name'] ?? 'menu',
        slug: data['slug'],
        version: (data['version'] as num?)?.toInt(),
        isPublished: data['is_published'] ?? data['isPublished'] ?? false,
        items: (data['items'] as List<dynamic>?)
                ?.map((e) => ItemModel.fromMap(e as Map<String, dynamic>))
                .toList() ??
            [],
        viewCount: (data['view_count'] ?? data['viewCount']) is int
            ? (data['view_count'] ?? data['viewCount']) as int
            : ((data['view_count'] ?? data['viewCount']) as num?)?.toInt() ?? 0,
        isDeleted: data['is_deleted'] ?? data['isDeleted'],
        createdAt: data['created_at'] != null
            ? DateTime.tryParse(data['created_at'] as String)
            : null,
        updatedAt: data['updated_at'] != null
            ? DateTime.tryParse(data['updated_at'] as String)
            : null,
        averageRating: (data['average_rating'] as num?)?.toDouble() ??
            (data['averageRating'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'restaurant_id': restaurantId,
        'name': name,
        if (slug != null) 'slug': slug,
        if (version != null) 'version': version,
        'is_published': isPublished,
        'items': items.map((e) => (e as ItemModel).toMap()).toList(),
        'view_count': viewCount,
        if (isDeleted != null) 'is_deleted': isDeleted,
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
        if (averageRating != null) 'average_rating': averageRating,
      };

  factory MenuModel.fromJson(String data) {
    return MenuModel.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  String toJson() => json.encode(toMap());

  MenuModel copyWith({
    String? name,
    String? id,
    String? restaurantId,
    String? slug,
    int? version,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? averageRating,
    bool? isPublished,
    List<Item>? items,
    int? viewCount,
  }) {
    return MenuModel(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      version: version ?? this.version,
      isPublished: isPublished ?? this.isPublished,
      items: items ?? this.items,
      viewCount: viewCount ?? this.viewCount,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      averageRating: averageRating ?? this.averageRating,
    );
  }

  @override
  bool get stringify => true;

  Menu toEntity() => this;

  factory MenuModel.fromEntity(Menu entity) => MenuModel(
        id: entity.id,
        restaurantId: entity.restaurantId,
        name: entity.name,
        slug: entity.slug,
        version: entity.version,
        isPublished: entity.isPublished,
        items: entity.items.map((e) => ItemModel.fromEntity(e)).toList(),
        viewCount: entity.viewCount,
        isDeleted: entity.isDeleted,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
        averageRating: entity.averageRating,
      );
}
