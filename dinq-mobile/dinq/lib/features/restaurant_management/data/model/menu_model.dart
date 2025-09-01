import 'dart:convert';

import '../../domain/entities/menu.dart';
import '../../domain/entities/tab.dart';
import 'tab_model.dart';

class MenuModel extends Menu {
  const MenuModel({
    required super.id,
    required super.restaurantId,
    required super.isPublished,
    required super.tabs,
    required super.viewCount,
  });

  factory MenuModel.fromMap(Map<String, dynamic> data) => MenuModel(
    id: data['id'] ?? '',
    restaurantId: data['restaurantId'] ?? '',
    isPublished: data['isPublished'] ?? false,
    tabs:
        (data['tabs'] as List<dynamic>?)
            ?.map((e) => TabModel.fromMap(e as Map<String, dynamic>))
            .toList() ??
        [],
    viewCount: data['viewCount'] ?? 0,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'restaurantId': restaurantId,
    'isPublished': isPublished,
    'tabs': tabs.map((e) => (e as TabModel).toMap()).toList(),
    'viewCount': viewCount,
  };


  factory MenuModel.fromJson(String data) {
    return MenuModel.fromMap(json.decode(data) as Map<String, dynamic>);
  }


  String toJson() => json.encode(toMap());

  MenuModel copyWith({
    String? id,
    String? restaurantId,
    bool? isPublished,
    List<Tab>? tabs,
    int? viewCount,
  }) {
    return MenuModel(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      isPublished: isPublished ?? this.isPublished,
      tabs: tabs ?? this.tabs,
      viewCount: viewCount ?? this.viewCount,
    );
  }

  @override
  bool get stringify => true;

  Menu toEntity() => this;
}
