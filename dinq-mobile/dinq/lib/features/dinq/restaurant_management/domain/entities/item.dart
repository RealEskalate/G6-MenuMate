import 'package:equatable/equatable.dart';

import 'nutrition.dart';

class Item extends Equatable {
  final String id;
  final String name;
  final String nameAm;
  final String slug;
  final String menuSlug;
  final String? description;
  final String? descriptionAm;
  final List<String>? images;
  final double price;
  final String currency;
  final List<String>? allergies;
  final List<String>? allergiesAm;
  final List<String>? tabTags;
  final int? preparationTime;
  final String? howToEat;
  final String? howToEatAm;
  final List<String>? ingredients;
  final List<String>? ingredientsAm;
  final Nutrition? nutritionalInfo;
  final int viewCount;
  final double averageRating;
  final List<String> reviewIds;

  const Item({
    required this.id,
    required this.name,
    required this.nameAm,
    required this.slug,
    required this.menuSlug,
    this.description,
    this.descriptionAm,
    this.images,
    required this.price,
    required this.currency,
    this.allergies,
    this.allergiesAm,
    this.tabTags,
    this.ingredients,
    this.ingredientsAm,
    this.preparationTime,
    this.howToEat,
    this.howToEatAm,
    this.nutritionalInfo,
    required this.viewCount,
    required this.averageRating,
    required this.reviewIds,
  });

  @override
  List<Object?> get props {
    return [id];
  }
}
