import 'dart:convert';
import '../../domain/entities/category.dart';
import '../../domain/entities/item.dart';
import 'item_model.dart';
import 'menu_model.dart';

class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.nameAm,
    required super.items,
  });

  /// Create a CategoryModel directly from a MenuModel
  factory CategoryModel.fromMenu(MenuModel menu) {
    return CategoryModel(
      id: menu.id,
      name: menu.name ?? 'Menu',
      nameAm: menu.name ?? 'Menu',
      items: menu.items,
    );
  }

  factory CategoryModel.fromMap(Map<String, dynamic> data) {
    return CategoryModel(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      nameAm: data['nameAm'] ?? '',
      items: (data['items'] as List<dynamic>?)
              ?.map((e) => ItemModel.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'nameAm': nameAm,
      'items': items.map((e) => (e as ItemModel).toMap()).toList(),
    };
  }

  factory CategoryModel.fromJson(String data) =>
      CategoryModel.fromMap(json.decode(data) as Map<String, dynamic>);

  String toJson() => json.encode(toMap());

  CategoryModel copyWith({
    String? id,
    String? name,
    String? nameAm,
    List<Item>? items,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nameAm: nameAm ?? this.nameAm,
      items: items ?? this.items,
    );
  }

  @override
  bool get stringify => true;

  @override
  Category toEntity() => this;

  factory CategoryModel.fromEntity(Category entity) {
    return CategoryModel(
      id: entity.id,
      name: entity.name,
      nameAm: entity.nameAm,
      items: entity.items.map((e) => ItemModel.fromEntity(e)).toList(),
    );
  }
}
