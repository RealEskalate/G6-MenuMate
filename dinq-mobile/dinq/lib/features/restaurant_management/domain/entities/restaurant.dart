import 'package:equatable/equatable.dart';

class Restaurant extends Equatable {
  final String id;
  final String slug;
  final String restaurantName;
  final String managerId;
  final String restaurantPhone;
  final String? email;
  final String? location;
  final String? website;
  final String? cuisineType;
  final String? about;
  final List<String>? tags;
  final String? logoImage;
  final String? coverImage;
  final String? verificationDocs;
  final List<String> previousSlugs;
  final String verificationStatus;
  final String? defaultCurrency;
  final String? defaultLanguage;
  final double? defaultVat;
  final String? primaryColor;
  final String? accentColor;
  final double averageRating;
  final double viewCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Restaurant({
    required this.id,
    required this.slug,
    required this.restaurantName,
    required this.managerId,
    required this.restaurantPhone,
    this.email,
    this.location,
    this.website,
    this.cuisineType,
    this.about,
    this.tags,
    this.logoImage,
    this.coverImage,
    this.verificationDocs,
    required this.previousSlugs,
    required this.verificationStatus,
    this.defaultCurrency,
    this.defaultLanguage,
    this.defaultVat,
    this.primaryColor,
    this.accentColor,
    required this.averageRating,
    required this.viewCount,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id];
}
