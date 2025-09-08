import 'dart:convert';

import 'item_create_model.dart';

class MenuCreateModel {
  final String? name;
  final String? description;
  final List<ItemCreateModel>? menuItems;
  final bool? isPublished;

  MenuCreateModel(
      {this.name, this.description, this.menuItems, this.isPublished});

  /// Create from various map shapes returned by APIs or OCR results.
  /// Accepts keys like `name` or `title`, and `menu_items` or `items`.
  factory MenuCreateModel.fromMap(Map<String, dynamic> map) {
    // Normalize top-level name/title
    final name = (map['name'] ?? map['title']) as String?;
    final description = (map['description'] ?? map['desc']) as String?;

    // Accept both 'menu_items' and OCR-style 'items'
    final rawItems = map['menu_items'] ?? map['items'];

    List<ItemCreateModel>? menuItems;
    if (rawItems is List) {
      menuItems = rawItems.where((e) => e != null).map((e) {
        if (e is Map<String, dynamic>) return _normalizeAndBuildItem(e);
        if (e is String) return ItemCreateModel.fromMap({'name': e});
        return ItemCreateModel.fromMap(Map<String, dynamic>.from(e as Map));
      }).toList();
    }

    return MenuCreateModel(
      name: name,
      description: description,
      menuItems: menuItems,
      isPublished: map['is_published'] as bool?,
    );
  }

  factory MenuCreateModel.fromEntity(dynamic entity) {
    return MenuCreateModel(
      name: entity?.name as String?,
      description: entity?.description as String?,
      menuItems: (entity?.items as List?)
          ?.map((e) => ItemCreateModel.fromEntity(e))
          .toList(),
      isPublished: entity?.isPublished as bool?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (name != null) 'name': name,
      if (description != null) 'description': description,
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
    String? description,
    List<ItemCreateModel>? menuItems,
    bool? isPublished,
  }) {
    return MenuCreateModel(
      name: name ?? this.name,
      description: description ?? this.description,
      menuItems: menuItems ?? this.menuItems,
      isPublished: isPublished ?? this.isPublished,
    );
  }

  // Helper: normalize item map shapes produced by OCR into the shape
  // expected by ItemCreateModel.fromMap.
  static ItemCreateModel _normalizeAndBuildItem(Map<String, dynamic> raw) {
    final m = Map<String, dynamic>.from(raw);

    // title -> name
    if (m.containsKey('title') && !m.containsKey('name')) {
      m['name'] = m['title'];
    }
    if (m.containsKey('title_am') && !m.containsKey('name_am')) {
      m['name_am'] = m['title_am'];
    }

    // description fields
    if (m.containsKey('description') && !m.containsKey('description')) {
      // keep as-is
    }
    if (m.containsKey('description_am') && !m.containsKey('description_am')) {
      // keep as-is
    }

    // price may come as number or string
    if (m.containsKey('price')) {
      final p = m['price'];
      if (p is String) {
        final parsed = num.tryParse(p.replaceAll(RegExp(r"[^0-9\.-]"), ''));
        if (parsed != null) m['price'] = parsed;
      }
    }

    // Ensure tab_tags fields are lists of strings
    if (m['tab_tags'] is! List && m['tab_tags'] != null) {
      m['tab_tags'] =
          (m['tab_tags'] as String).split(',').map((e) => e.trim()).toList();
    }
    if (m['tab_tags_am'] is! List && m['tab_tags_am'] != null) {
      m['tab_tags_am'] =
          (m['tab_tags_am'] as String).split(',').map((e) => e.trim()).toList();
    }

    // nutritional_info may be a map already usable by NutritionCreateModel

    return ItemCreateModel.fromMap(m);
  }
}
