import 'package:equatable/equatable.dart';

import 'tab.dart';

class Menu extends Equatable {
  final String id;
  final String restaurantId;
  final bool isPublished;
  final List<Tab> tabs;
  final int viewCount;

  const Menu({
    required this.id,
    required this.restaurantId,
    required this.isPublished,
    required this.tabs,
    
    required this.viewCount,
  });

  @override
  List<Object?> get props {
    return [id];
  }
}
