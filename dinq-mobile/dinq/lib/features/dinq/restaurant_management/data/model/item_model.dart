import 'dart:convert';

import '../../domain/entities/item.dart';

class ItemModel extends Item {
  const ItemModel({
    required super.id,
    required super.name,
    required super.nameAm,
    required super.slug,
    required super.categoryId,
    super.description,
    super.descriptionAm,
    super.image,
    required super.price,
    required super.currency,
    super.allergies,
    super.userImages,
    super.calories,
    super.ingredients,
    super.ingredientsAm,
    super.preparationTime,
    super.howToEat,
    super.howToEatAm,
    required super.viewCount,
    required super.averageRating,
    required super.reviewIds,
  });

  factory ItemModel.fromMap(Map<String, dynamic> data) => ItemModel(
    id: data['id'] ?? '',
    name: data['name'] ?? '',
    nameAm: data['nameAm'] ?? '',
    slug: data['slug'] ?? '',
    categoryId: data['categoryId'] ?? '',
    description: data['description'],
    descriptionAm: data['descriptionAm'],
    image: (data['image'] as List<dynamic>?)?.map((e) => e as String).toList(),
    price: data['price'] ?? 0,
    currency: data['currency'] ?? '',
    allergies: (data['allergies'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList(),
    userImages: (data['userImages'] as List<dynamic>?),
    calories: data['calories'],
    ingredients: (data['ingredients'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList(),
    ingredientsAm: (data['ingredientsAm'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList(),
    preparationTime: data['preparationTime'],
    howToEat: data['howToEat'],
    howToEatAm: data['howToEatAm'],
    viewCount: data['viewCount'] ?? 0,
    averageRating: (data['averageRating'] as num?)?.toDouble() ?? 0.0,
    reviewIds:
        (data['reviewIds'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'nameAm': nameAm,
    'slug': slug,
    'categoryId': categoryId,
    'description': description,
    'descriptionAm': descriptionAm,
    'image': image,
    'price': price,
    'currency': currency,
    'allergies': allergies,
    'userImages': userImages,
    'calories': calories,
    'ingredients': ingredients,
    'ingredientsAm': ingredientsAm,
    'preparationTime': preparationTime,
    'howToEat': howToEat,
    'howToEatAm': howToEatAm,
    'viewCount': viewCount,
    'averageRating': averageRating,
    'reviewIds': reviewIds,
  };


  factory ItemModel.fromJson(String data) {
    return ItemModel.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  String toJson() => json.encode(toMap());

  ItemModel copyWith({
    String? id,
    String? name,
    String? nameAm,
    String? slug,
    String? categoryId,
    String? description,
    String? descriptionAm,
    List<String>? image,
    int? price,
    String? currency,
    List<String>? allergies,
    List<dynamic>? userImages,
    int? calories,
    List<String>? ingredients,
    List<String>? ingredientsAm,
    int? preparationTime,
    String? howToEat,
    String? howToEatAm,
    int? viewCount,
    double? averageRating,
    List<String>? reviewIds,
  }) {
    return ItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nameAm: nameAm ?? this.nameAm,
      slug: slug ?? this.slug,
      categoryId: categoryId ?? this.categoryId,
      description: description ?? this.description,
      descriptionAm: descriptionAm ?? this.descriptionAm,
      image: image ?? this.image,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      allergies: allergies ?? this.allergies,
      userImages: userImages ?? this.userImages,
      calories: calories ?? this.calories,
      ingredients: ingredients ?? this.ingredients,
      ingredientsAm: ingredientsAm ?? this.ingredientsAm,
      preparationTime: preparationTime ?? this.preparationTime,
      howToEat: howToEat ?? this.howToEat,
      howToEatAm: howToEatAm ?? this.howToEatAm,
      viewCount: viewCount ?? this.viewCount,
      averageRating: averageRating ?? this.averageRating,
      reviewIds: reviewIds ?? this.reviewIds,
    );
  }

  @override
  bool get stringify => true;

  Item toEntity() => this;
}
