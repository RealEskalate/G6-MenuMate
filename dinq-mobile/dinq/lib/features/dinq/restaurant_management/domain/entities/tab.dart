import 'package:equatable/equatable.dart';

import 'category.dart';

class Tab extends Equatable {
  final String id;
  final String menuId;
  final String name;
  final String nameAm;
  final List<Category> categories;
  final bool isDeleted;

  const Tab({
    required this.id,
    required this.menuId,
    required this.name,
    required this.nameAm,
    required this.categories,
    required this.isDeleted,
  });

  @override
  List<Object?> get props {
    return [id];
  }
}
