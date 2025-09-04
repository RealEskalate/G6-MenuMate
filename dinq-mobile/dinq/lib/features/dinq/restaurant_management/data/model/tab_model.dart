import 'dart:convert';

import '../../domain/entities/category.dart';
import '../../domain/entities/tab.dart';
import 'category_model.dart';

class TabModel extends Tab {
  const TabModel({
    required super.id,
    required super.menuId,
    required super.name,
    required super.nameAm,
    required super.categories,
    required super.isDeleted,
  });

  factory TabModel.fromMap(Map<String, dynamic> data) => TabModel(
    id: data['id'] ?? '',
    menuId: data['menuId'] ?? '',
    name: data['name'] ?? '',
    nameAm: data['nameAm'] ?? '',
    categories:
        (data['categories'] as List<dynamic>?)
            ?.map((e) => CategoryModel.fromMap(e as Map<String, dynamic>))
            .toList() ??
        [],
    isDeleted: data['isDeleted'] ?? false,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'menuId': menuId,
    'name': name,
    'nameAm': nameAm,
    'categories': categories.map((e) => (e as CategoryModel).toMap()).toList(),
    'isDeleted': isDeleted,
  };

  factory TabModel.fromJson(String data) {
    return TabModel.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  String toJson() => json.encode(toMap());

  TabModel copyWith({
    String? id,
    String? menuId,
    String? name,
    String? nameAm,
    List<Category>? categories,
    bool? isDeleted,
  }) {
    return TabModel(
      id: id ?? this.id,
      menuId: menuId ?? this.menuId,
      name: name ?? this.name,
      nameAm: nameAm ?? this.nameAm,
      categories: categories ?? this.categories,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  bool get stringify => true;

  Tab toEntity() => this;

  factory TabModel.fromEntity(Tab entity) => TabModel(
    id: entity.id,
    menuId: entity.menuId,
    name: entity.name,
    nameAm: entity.nameAm,
    categories: entity.categories
        .map((e) => CategoryModel.fromEntity(e))
        .toList(),
    isDeleted: entity.isDeleted,
  );
}
