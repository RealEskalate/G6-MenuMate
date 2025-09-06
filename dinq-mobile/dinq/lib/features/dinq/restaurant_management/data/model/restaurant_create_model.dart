import 'dart:convert';

class RestaurantCreateModel {
  final String? name;
  final String? nameAm;
  final String? description;
  final String? descriptionAm;
  final String? slug;
  final String? address;
  final String? phone;
  final String? email;
  final List<String>? images;
  final String? logo;

  RestaurantCreateModel({
    this.name,
    this.nameAm,
    this.description,
    this.descriptionAm,
    this.slug,
    this.address,
    this.phone,
    this.email,
    this.images,
    this.logo,
  });

  factory RestaurantCreateModel.fromMap(Map<String, dynamic> map) {
    return RestaurantCreateModel(
      name: map['name'] as String?,
      nameAm: map['name_am'] as String?,
      description: map['description'] as String?,
      descriptionAm: map['description_am'] as String?,
      slug: map['slug'] as String?,
      address: map['address'] as String?,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      images: (map['images'] as List?)?.map((e) => e.toString()).toList(),
      logo: map['logo'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (name != null) 'name': name,
      if (nameAm != null) 'name_am': nameAm,
      if (description != null) 'description': description,
      if (descriptionAm != null) 'description_am': descriptionAm,
      if (slug != null) 'slug': slug,
      if (address != null) 'address': address,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (images != null) 'images': images,
      if (logo != null) 'logo': logo,
    };
  }

  String toJson() => jsonEncode(toMap());

  factory RestaurantCreateModel.fromJson(String source) =>
      RestaurantCreateModel.fromMap(jsonDecode(source) as Map<String, dynamic>);

  RestaurantCreateModel copyWith({
    String? name,
    String? nameAm,
    String? description,
    String? descriptionAm,
    String? slug,
    String? address,
    String? phone,
    String? email,
    List<String>? images,
    String? logo,
  }) {
    return RestaurantCreateModel(
      name: name ?? this.name,
      nameAm: nameAm ?? this.nameAm,
      description: description ?? this.description,
      descriptionAm: descriptionAm ?? this.descriptionAm,
      slug: slug ?? this.slug,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      images: images ?? this.images,
      logo: logo ?? this.logo,
    );
  }
}
