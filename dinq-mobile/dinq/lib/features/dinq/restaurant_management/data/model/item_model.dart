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
    super.protein,
    super.carbs,
    super.fat,
  });

  factory ItemModel.fromMap(Map<String, dynamic> data) {
    return ItemModel(
      id: data['id'] ?? data['item_id'] ?? '',
      name: data['name'] ?? '',
      nameAm: data['name_am'] ?? data['nameAm'] ?? '',
      slug: data['slug'] ?? '',
      categoryId: data['category_id'] ?? data['categoryId'] ?? '',
      description: data['description'],
      image: (data['image'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      price: (data['price'] as num?)?.toInt() ?? 0,
      currency: data['currency'] ?? 'ETB',
      allergies: (data['allergies'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      userImages: data['user_images'] ?? data['userImages'],
      calories: (data['calories'] as num?)?.toInt(),
      ingredients: (data['ingredients'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      ingredientsAm: (data['ingredients_am'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      preparationTime:
          (data['preparation_time'] as num?)?.toInt(),
      howToEat: data['how_to_eat'] ?? data['howToEat'],
      howToEatAm: data['how_to_eat_am'] ?? data['howToEatAm'],
      viewCount: (data['view_count'] as num?)?.toInt() ?? 0,
      averageRating:
          (data['average_rating'] as num?)?.toDouble() ?? 0.0,
      reviewIds: (data['review_ids'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      protein: data['protein'],
      carbs: data['carbs'],
      fat: data['fat'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'name_am': nameAm,
      'slug': slug,
      'category_id': categoryId,
      if (description != null) 'description': description,
      if (image != null) 'image': image,
      'price': price,
      'currency': currency,
      if (allergies != null) 'allergies': allergies,
      if (userImages != null) 'user_images': userImages,
      if (calories != null) 'calories': calories,
      if (ingredients != null) 'ingredients': ingredients,
      if (ingredientsAm != null) 'ingredients_am': ingredientsAm,
      if (preparationTime != null)
        'preparation_time': preparationTime,
      if (howToEat != null) 'how_to_eat': howToEat,
      if (howToEatAm != null)
        'how_to_eat_am': howToEatAm,
      'view_count': viewCount,
      'average_rating': averageRating,
      'review_ids': reviewIds,
      if (protein != null) 'protein': protein,
      if (carbs != null) 'carbs': carbs,
      if (fat != null) 'fat': fat,
    };
  }

  factory ItemModel.fromJson(String source) =>
      ItemModel.fromMap(json.decode(source));

  String toJson() => json.encode(toMap());

  Item toEntity() => this;

  factory ItemModel.fromEntity(Item entity) {
    return ItemModel(
      id: entity.id,
      name: entity.name,
      nameAm: entity.nameAm,
      slug: entity.slug,
      categoryId: entity.categoryId,
      description: entity.description,
      image: entity.image,
      price: entity.price,
      currency: entity.currency,
      allergies: entity.allergies,
      userImages: entity.userImages,
      calories: entity.calories,
      ingredients: entity.ingredients,
      ingredientsAm: entity.ingredientsAm,
      preparationTime: entity.preparationTime,
      howToEat: entity.howToEat,
      howToEatAm: entity.howToEatAm,
      viewCount: entity.viewCount,
      averageRating: entity.averageRating,
      reviewIds: entity.reviewIds,
      protein: entity.protein,
      carbs: entity.carbs,
      fat: entity.fat,
    );
  }
}
