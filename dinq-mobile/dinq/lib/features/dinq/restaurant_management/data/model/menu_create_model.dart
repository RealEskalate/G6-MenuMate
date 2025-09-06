import 'dart:convert';

import 'item_create_model.dart';

class MenuCreateModel {
  final String? name;
  final List<ItemCreateModel>? menuItems;
  final bool? isPublished;

  MenuCreateModel({this.name, this.menuItems, this.isPublished});

  factory MenuCreateModel.fromMap(Map<String, dynamic> map) {
    return MenuCreateModel(
      name: map['name'] as String?,
      menuItems: (map['menu_items'] as List?)
          ?.map((e) => ItemCreateModel.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      isPublished: map['is_published'] as bool?,
    );
  }

  factory MenuCreateModel.fromEntity(dynamic entity) {
    return MenuCreateModel(
      name: entity?.name as String?,
      menuItems: (entity?.items as List?)
          ?.map((e) => ItemCreateModel.fromEntity(e))
          .toList(),
      isPublished: entity?.isPublished as bool?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (name != null) 'name': name,
      if (menuItems != null)
        'menu_items': menuItems!.map((e) => e.toMap()).toList(),
      if (isPublished != null) 'is_published': isPublished,
    };
  }

  String toJson() => jsonEncode(toMap());

  factory MenuCreateModel.fromJson(String source) =>
      MenuCreateModel.fromMap(jsonDecode(source) as Map<String, dynamic>);

  MenuCreateModel copyWith({
    String? name,
    List<ItemCreateModel>? menuItems,
    bool? isPublished,
  }) {
    return MenuCreateModel(
      name: name ?? this.name,
      menuItems: menuItems ?? this.menuItems,
      isPublished: isPublished ?? this.isPublished,
    );
  }
}
