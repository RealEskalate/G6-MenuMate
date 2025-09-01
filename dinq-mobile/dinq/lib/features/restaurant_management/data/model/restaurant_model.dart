import 'dart:convert';

import '../../domain/entities/restaurant.dart';

class RestaurantModel extends Restaurant {
  const RestaurantModel({
    required super.id,
    required super.name,
    required super.description,
    required super.address,
    required super.phone,
    required super.email,
    required super.image,
    required super.isActive,
  });

  factory RestaurantModel.fromMap(Map<String, dynamic> data) => RestaurantModel(
    id: data['id'] ?? '',
    name: data['name'] ?? '',
    description: data['description'] ?? '',
    address: data['address'] ?? '',
    phone: data['phone'] ?? '',
    email: data['email'] ?? '',
    image: data['image'] ?? '',
    isActive: data['isActive'] ?? false,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'description': description,
    'address': address,
    'phone': phone,
    'email': email,
    'image': image,
    'isActive': isActive,
  };


  factory RestaurantModel.fromJson(String data) {
    return RestaurantModel.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  String toJson() => json.encode(toMap());

  RestaurantModel copyWith({
    String? id,
    String? name,
    String? description,
    String? address,
    String? phone,
    String? email,
    String? image,
    bool? isActive,
  }) {
    return RestaurantModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      image: image ?? this.image,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool get stringify => true;

  Restaurant toEntity() => this;
}
