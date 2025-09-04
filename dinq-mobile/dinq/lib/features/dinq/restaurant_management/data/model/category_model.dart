import 'dart:convert';

import '../../domain/entities/category.dart';
import '../../domain/entities/item.dart';
import 'item_model.dart';

class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.tabId,
    required super.name,
    required super.nameAm,
    required super.items,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> data) => CategoryModel(
    id: data['id'] ?? '',
    tabId: data['tabId'] ?? '',
    name: data['name'] ?? '',
    nameAm: data['nameAm'] ?? '',
    items:
        (data['items'] as List<dynamic>?)
            ?.map((e) => ItemModel.fromMap(e as Map<String, dynamic>))
            .toList() ??
        [],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'tabId': tabId,
    'name': name,
    'nameAm': nameAm,
    'items': items.map((e) => (e as ItemModel).toMap()).toList(),
  };

  factory CategoryModel.fromJson(String data) {
    return CategoryModel.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  String toJson() => json.encode(toMap());

  CategoryModel copyWith({
    String? id,
    String? tabId,
    String? name,
    String? nameAm,
    List<Item>? items,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      tabId: tabId ?? this.tabId,
      name: name ?? this.name,
      nameAm: nameAm ?? this.nameAm,
      items: items ?? this.items,
    );
  }

  @override
  bool get stringify => true;

  Category toEntity() => this;

  factory CategoryModel.fromEntity(Category entity) => CategoryModel(
    id: entity.id,
    tabId: entity.tabId,
    name: entity.name,
    nameAm: entity.nameAm,
    items: entity.items.map((e) => ItemModel.fromEntity(e)).toList(),
  );
}
