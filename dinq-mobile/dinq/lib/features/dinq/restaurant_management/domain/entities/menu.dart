import 'package:equatable/equatable.dart';

import 'item.dart';
import 'tab.dart';

class Menu extends Equatable {
  final String id;
  final String restaurantId;
  final String? name;
  final String? slug;
  final int? version;
  final bool isPublished;
  final List<Item> items;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Menu({
    required this.id,
    required this.restaurantId,
    this.name,
    this.slug,
    this.version,
    required this.isPublished,
    required this.items,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props {
    return [id];
  }
}
