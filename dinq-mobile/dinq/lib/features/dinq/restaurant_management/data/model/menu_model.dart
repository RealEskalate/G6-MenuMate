import 'dart:convert';

import '../../domain/entities/menu.dart';
import '../../domain/entities/tab.dart';
import 'tab_model.dart';

class MenuModel extends Menu {
  const MenuModel({
    required super.id,
    required super.restaurantId,
    super.name,
    super.slug,
    super.version,
    required super.isPublished,
    required super.tabs,
    required super.viewCount,
    super.isDeleted,
    super.createdAt,
    super.updatedAt,
    super.averageRating,
  });

  factory MenuModel.fromMap(Map<String, dynamic> data) => MenuModel(
    id: data['id'] ?? data['menu_id'] ?? '',
    restaurantId: data['restaurant_id'] ?? data['restaurantId'] ?? '',
    name: data['name'] ?? data['menu_name'],
    slug: data['slug'],
    version: (data['version'] as num?)?.toInt(),
    isPublished: data['is_published'] ?? data['isPublished'] ?? false,
    tabs:
        (data['tabs'] as List<dynamic>?)
            ?.map((e) => TabModel.fromMap(e as Map<String, dynamic>))
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
    averageRating:
        (data['average_rating'] as num?)?.toDouble() ??
        (data['averageRating'] as num?)?.toDouble(),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'restaurant_id': restaurantId,
    if (name != null) 'name': name,
    if (slug != null) 'slug': slug,
    if (version != null) 'version': version,
    'is_published': isPublished,
    'tabs': tabs.map((e) => (e as TabModel).toMap()).toList(),
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
    String? id,
    String? restaurantId,
    bool? isPublished,
    List<Tab>? tabs,
    int? viewCount,
  }) {
    return MenuModel(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      isPublished: isPublished ?? this.isPublished,
      tabs: tabs ?? this.tabs,
      viewCount: viewCount ?? this.viewCount,
    );
  }

  @override
  bool get stringify => true;

  Menu toEntity() => this;

  factory MenuModel.fromEntity(Menu entity) => MenuModel(
    id: entity.id,
    restaurantId: entity.restaurantId,
    isPublished: entity.isPublished,
    tabs: entity.tabs.map((e) => TabModel.fromEntity(e)).toList(),
    viewCount: entity.viewCount,
  );
}
