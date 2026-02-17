import 'package:equatable/equatable.dart';
import 'item.dart';

class Category extends Equatable {
  final String id;
  final String name;
  final String nameAm;
  final List<Item> items;

  const Category({
    required this.id,
    required this.name,
    required this.nameAm,
    required this.items,
  });

  @override
  List<Object?> get props => [id];
}
