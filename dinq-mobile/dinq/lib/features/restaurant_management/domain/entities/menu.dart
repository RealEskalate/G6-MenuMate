import 'package:equatable/equatable.dart';

import 'item.dart';

class Menu extends Equatable {
  final String id;
  final String restaurantId;
  final String name;
  final String? slug;
  final int? version;
  final bool isPublished;
  final List<Item> items;
  final int viewCount;
  final bool? isDeleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final double? averageRating;

  const Menu({
    required this.id,
    required this.restaurantId,
    required this.name,
    this.slug,
    this.version,
    required this.isPublished,
    required this.items,
    required this.viewCount,
    this.isDeleted,
    this.createdAt,
    this.updatedAt,
    this.averageRating,
  });

  @override
  List<Object?> get props {
    return [id];
  }
}
