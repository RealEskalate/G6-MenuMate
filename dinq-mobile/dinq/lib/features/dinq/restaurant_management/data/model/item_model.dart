import 'dart:convert';
import '../../domain/entities/item.dart';
import '../../domain/entities/nutrition.dart';
import 'nutrition_model.dart';

class ItemModel extends Item {
  const ItemModel({
    required super.id,
    required super.name,
    required super.nameAm,
    required super.slug,
    required super.menuSlug,
    super.images,
    super.description,
    super.descriptionAm,
    required super.price,
    required super.currency,
    super.allergies,
    super.allergiesAm,
    super.tabTags,
    super.ingredients,
    super.ingredientsAm,
    super.preparationTime,
    super.howToEat,
    super.howToEatAm,
    super.nutritionalInfo,
    required super.viewCount,
    required super.averageRating,
    required super.reviewIds,
  });

  factory ItemModel.fromMap(Map<String, dynamic> data) => ItemModel(
        id: data['id'] ?? '',
        name: data['name'] ?? '',
        nameAm: data['nameAm'] ?? data['name_am'] ?? '',
        slug: data['slug'] ?? '',
        menuSlug: data['menuSlug'] ?? data['menu_slug'] ?? '',
        images: ((data['images'] ?? data['image']) as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
        description: data['description'] ??
            data['description_en'] ??
            data['description_am'],
        descriptionAm: data['descriptionAm'] ?? data['description_am'],
        price: (data['price'] as num?)?.toDouble() ?? 0.0,
        currency: data['currency'] ?? '',
        allergies: (data['allergies'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
        allergiesAm: (() {
          final a = data['allergiesAm'] ?? data['allergies_am'];
          if (a == null) return null;
          if (a is List) return a.map((e) => e as String).toList();
          if (a is String) return [a];
          return null;
        })(),
        tabTags: ((data['tabTags'] ?? data['tab_tags']) as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
        ingredients: (() {
          final ingr = data['ingredients'] ?? data['ingredients_list'];
          if (ingr is List) return ingr.map((e) => e as String).toList();
          if (ingr is String) {
            return ingr
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList();
          }
          return null;
        })(),
        ingredientsAm: (() {
          final ingr = data['ingredientsAm'] ?? data['ingredients_am'];
          if (ingr is List) return ingr.map((e) => e as String).toList();
          if (ingr is String) {
            return ingr
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList();
          }
          return null;
        })(),
        preparationTime: (data['preparationTime'] as num?)?.toInt() ??
            (data['preparation_time'] as num?)?.toInt(),
        howToEat: data['howToEat'] ?? data['how_to_eat'],
        howToEatAm: data['howToEatAm'] ?? data['how_to_eat_am'],
        nutritionalInfo: (() {
          final n = data['nutritionalInfo'] ??
              data['nutrition'] ??
              data['nutritional_info'];
          if (n is Map<String, dynamic>) {
            return NutritionModel.fromMap(n);
          }
          return null;
        })(),
        viewCount: (data['view_count'] ?? data['viewCount']) is int
            ? (data['view_count'] ?? data['viewCount']) as int
            : ((data['view_count'] ?? data['viewCount']) as num?)?.toInt() ?? 0,
        averageRating: (data['average_rating'] as num?)?.toDouble() ??
            (data['averageRating'] as num?)?.toDouble() ??
            0.0,
        reviewIds: (data['reviewIds'] as List<dynamic>?)
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
        'menu_slug': menuSlug,
        'description': description,
        'description_am': descriptionAm,
        'images': images,
        'price': price,
        'currency': currency,
        'allergies': allergies,
        'allergies_am': allergiesAm,
        'tab_tags': tabTags,
        'ingredients': ingredients,
        'ingredients_am': ingredientsAm,
        'preparation_time': preparationTime,
        'how_to_eat': howToEat,
        'how_to_eat_am': howToEatAm,
        'nutritional_info': nutritionalInfo == null
            ? null
            : (nutritionalInfo is NutritionModel
                ? (nutritionalInfo as NutritionModel).toMap()
                : NutritionModel.fromEntity(nutritionalInfo!).toMap()),
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
    String? menuSlug,
    List<String>? images,
    String? description,
    String? descriptionAm,
    double? price,
    String? currency,
    List<String>? allergies,
    List<String>? allergiesAm,
    List<String>? tabTags,
    List<String>? ingredients,
    List<String>? ingredientsAm,
    int? preparationTime,
    String? howToEat,
    String? howToEatAm,
    Nutrition? nutritionalInfo,
    int? viewCount,
    double? averageRating,
    List<String>? reviewIds,
  }) {
    return ItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nameAm: nameAm ?? this.nameAm,
      slug: slug ?? this.slug,
      menuSlug: menuSlug ?? this.menuSlug,
      images: images ?? this.images,
      description: description ?? this.description,
      descriptionAm: descriptionAm ?? this.descriptionAm,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      allergies: allergies ?? this.allergies,
      allergiesAm: allergiesAm ?? this.allergiesAm,
      tabTags: tabTags ?? this.tabTags,
      ingredients: ingredients ?? this.ingredients,
      ingredientsAm: ingredientsAm ?? this.ingredientsAm,
      preparationTime: preparationTime ?? this.preparationTime,
      howToEat: howToEat ?? this.howToEat,
      howToEatAm: howToEatAm ?? this.howToEatAm,
      nutritionalInfo: nutritionalInfo ?? this.nutritionalInfo,
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
        menuSlug: entity.menuSlug,
        images: entity.images,
        description: entity.description,
        descriptionAm: entity.descriptionAm,
        price: entity.price,
        currency: entity.currency,
        allergies: entity.allergies,
        allergiesAm: entity.allergiesAm,
        tabTags: entity.tabTags,
        ingredients: entity.ingredients,
        ingredientsAm: entity.ingredientsAm,
        preparationTime: entity.preparationTime,
        howToEat: entity.howToEat,
        howToEatAm: entity.howToEatAm,
        nutritionalInfo: entity.nutritionalInfo,
        viewCount: entity.viewCount,
        averageRating: entity.averageRating,
        reviewIds: entity.reviewIds,
      );
}
