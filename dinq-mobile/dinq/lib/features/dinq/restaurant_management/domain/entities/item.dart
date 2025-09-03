import 'package:equatable/equatable.dart';

class Item extends Equatable {
  final String id;
  final String name;
  final String nameAm;
  final String slug;
  final String categoryId;
  final String? description;
  final String? descriptionAm;
  final List<String>? image;
  final int price;
  final String currency;
  final List<String>? allergies;
  final List<dynamic>? userImages;
  final int? calories;
  final List<String>? ingredients;
  final List<String>? ingredientsAm;
  final int? preparationTime;
  final String? howToEat;
  final String? howToEatAm;
  final int viewCount;
  final double averageRating;
  final List<String> reviewIds;

  const Item({
    required this.id,
    required this.name,
    required this.nameAm,
    required this.slug,
    required this.categoryId,
    this.description,
    this.descriptionAm,
    this.image,
    required this.price,
    required this.currency,
    this.allergies,
    this.userImages,
    this.calories,
    this.ingredients,
    this.ingredientsAm,
    this.preparationTime,
    this.howToEat,
    this.howToEatAm,
    required this.viewCount,
    required this.averageRating,
    required this.reviewIds,
  });

  @override
  List<Object?> get props {
    return [id];
  }
}
