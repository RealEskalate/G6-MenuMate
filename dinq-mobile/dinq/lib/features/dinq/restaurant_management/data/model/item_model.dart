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
    nameAm: data['nameAm'] ?? data['name_am'] ?? '',
    slug: data['slug'] ?? '',
    categoryId: data['categoryId'] ?? data['category_id'] ?? '',
    description:
        data['description'] ?? data['description_en'] ?? data['description_am'],
    descriptionAm: data['descriptionAm'] ?? data['description_am'],
    image: (data['image'] as List<dynamic>?)?.map((e) => e as String).toList(),
    price: (data['price'] as num?)?.toInt() ?? 0,
    currency: data['currency'] ?? '',
    allergies: (data['allergies'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList(),
    userImages: (data['userImages'] as List<dynamic>?),
    calories:
        (data['calories'] as num?)?.toInt() ??
        (data['nutrition']?['calories'] as num?)?.toInt(),
    ingredients: (data['ingredients'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList(),
    ingredientsAm: (data['ingredientsAm'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList(),
    preparationTime:
        (data['preparationTime'] as num?)?.toInt() ??
        (data['preparation_time'] as num?)?.toInt(),
    howToEat: data['howToEat'] ?? data['how_to_eat'],
    howToEatAm: data['howToEatAm'] ?? data['how_to_eat_am'],
    viewCount: (data['view_count'] ?? data['viewCount']) is int
        ? (data['view_count'] ?? data['viewCount']) as int
        : ((data['view_count'] ?? data['viewCount']) as num?)?.toInt() ?? 0,
    averageRating:
        (data['average_rating'] as num?)?.toDouble() ??
        (data['averageRating'] as num?)?.toDouble() ??
        0.0,
    reviewIds:
        (data['reviewIds'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        ((data['review_ids'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            []),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'name_am': nameAm,
    'slug': slug,
    'category_id': categoryId,
    'description': description,
    'description_am': descriptionAm,
    'image': image,
    'price': price,
    'currency': currency,
    'allergies': allergies,
    'user_images': userImages,
    'calories': calories,
    'ingredients': ingredients,
    'ingredients_am': ingredientsAm,
    'preparation_time': preparationTime,
    'how_to_eat': howToEat,
    'how_to_eat_am': howToEatAm,
    'view_count': viewCount,
    'average_rating': averageRating,
    'review_ids': reviewIds,
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

  factory ItemModel.fromEntity(Item entity) => ItemModel(
    id: entity.id,
    name: entity.name,
    nameAm: entity.nameAm,
    slug: entity.slug,
    categoryId: entity.categoryId,
    description: entity.description,
    descriptionAm: entity.descriptionAm,
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
  );
}
