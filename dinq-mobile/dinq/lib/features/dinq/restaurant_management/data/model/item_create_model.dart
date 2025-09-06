import 'dart:convert';

import 'nutrition_create_model.dart';

class ItemCreateModel {
  final String? name;
  final String? nameAm;
  final String? description;
  final String? descriptionAm;
  final List<String>? tabTags;
  final List<String>? tabTagsAm;
  final num? price;
  final String? currency;
  final List<String>? allergies;
  final List<String>? allergiesAm;
  final NutritionCreateModel? nutritionalInfo;
  final int? preparationTime;
  final String? howToEat;
  final String? howToEatAm;
  final List<String>? images;

  ItemCreateModel({
    this.name,
    this.nameAm,
    this.description,
    this.descriptionAm,
    this.tabTags,
    this.tabTagsAm,
    this.price,
    this.currency,
    this.allergies,
    this.allergiesAm,
    this.nutritionalInfo,
    this.preparationTime,
    this.howToEat,
    this.howToEatAm,
    this.images,
  });

  factory ItemCreateModel.fromMap(Map<String, dynamic> map) {
    return ItemCreateModel(
      name: map['name'] as String?,
      nameAm: map['name_am'] as String?,
      description: map['description'] as String?,
      descriptionAm: map['description_am'] as String?,
      tabTags: (map['tab_tags'] as List?)?.map((e) => e.toString()).toList(),
      tabTagsAm:
          (map['tab_tags_am'] as List?)?.map((e) => e.toString()).toList(),
      price: map['price'] as num?,
      currency: map['currency'] as String?,
      allergies: (map['allergies'] as List?)?.map((e) => e.toString()).toList(),
      allergiesAm:
          (map['allergies_am'] as List?)?.map((e) => e.toString()).toList(),
      nutritionalInfo: map['nutritional_info'] != null
          ? NutritionCreateModel.fromMap(
              Map<String, dynamic>.from(map['nutritional_info']))
          : null,
      preparationTime: map['preparation_time'] as int?,
      howToEat: map['how_to_eat'] as String?,
      howToEatAm: map['how_to_eat_am'] as String?,
      images: (map['images'] as List?)?.map((e) => e.toString()).toList(),
    );
  }

  factory ItemCreateModel.fromEntity(dynamic entity) {
    return ItemCreateModel(
      name: entity?.name as String?,
      nameAm: entity?.nameAm as String?,
      description: entity?.description as String?,
      descriptionAm: entity?.descriptionAm as String?,
      tabTags: (entity?.tabTags as List?)?.map((e) => e.toString()).toList(),
      tabTagsAm:
          (entity?.tabTagsAm as List?)?.map((e) => e.toString()).toList(),
      price: entity?.price as num?,
      currency: entity?.currency as String?,
      allergies:
          (entity?.allergies as List?)?.map((e) => e.toString()).toList(),
      allergiesAm:
          (entity?.allergiesAm as List?)?.map((e) => e.toString()).toList(),
      nutritionalInfo: entity?.nutritionalInfo != null
          ? NutritionCreateModel.fromEntity(entity.nutritionalInfo)
          : null,
      preparationTime: entity?.preparationTime as int?,
      howToEat: entity?.howToEat as String?,
      howToEatAm: entity?.howToEatAm as String?,
      images: (entity?.images as List?)?.map((e) => e.toString()).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (name != null) 'name': name,
      if (nameAm != null) 'name_am': nameAm,
      if (description != null) 'description': description,
      if (descriptionAm != null) 'description_am': descriptionAm,
      if (tabTags != null) 'tab_tags': tabTags,
      if (tabTagsAm != null) 'tab_tags_am': tabTagsAm,
      if (price != null) 'price': price,
      if (currency != null) 'currency': currency,
      if (allergies != null) 'allergies': allergies,
      if (allergiesAm != null) 'allergies_am': allergiesAm,
      if (nutritionalInfo != null) 'nutritional_info': nutritionalInfo!.toMap(),
      if (preparationTime != null) 'preparation_time': preparationTime,
      if (howToEat != null) 'how_to_eat': howToEat,
      if (howToEatAm != null) 'how_to_eat_am': howToEatAm,
      if (images != null) 'images': images,
    };
  }

  String toJson() => jsonEncode(toMap());

  factory ItemCreateModel.fromJson(String source) =>
      ItemCreateModel.fromMap(jsonDecode(source) as Map<String, dynamic>);

  ItemCreateModel copyWith({
    String? name,
    String? nameAm,
    String? description,
    String? descriptionAm,
    List<String>? tabTags,
    List<String>? tabTagsAm,
    num? price,
    String? currency,
    List<String>? allergies,
    List<String>? allergiesAm,
    NutritionCreateModel? nutritionalInfo,
    int? preparationTime,
    String? howToEat,
    String? howToEatAm,
    List<String>? images,
  }) {
    return ItemCreateModel(
      name: name ?? this.name,
      nameAm: nameAm ?? this.nameAm,
      description: description ?? this.description,
      descriptionAm: descriptionAm ?? this.descriptionAm,
      tabTags: tabTags ?? this.tabTags,
      tabTagsAm: tabTagsAm ?? this.tabTagsAm,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      allergies: allergies ?? this.allergies,
      allergiesAm: allergiesAm ?? this.allergiesAm,
      nutritionalInfo: nutritionalInfo ?? this.nutritionalInfo,
      preparationTime: preparationTime ?? this.preparationTime,
      howToEat: howToEat ?? this.howToEat,
      howToEatAm: howToEatAm ?? this.howToEatAm,
      images: images ?? this.images,
    );
  }
}
