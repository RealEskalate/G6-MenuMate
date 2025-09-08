import 'dart:convert';

import '../../domain/entities/qr.dart';

class QrModel extends Qr {
  const QrModel({
    required super.id,
    super.imageUrl,
    super.publicMenuUrl,
    super.downloadUrl,
    super.isActive,
    super.expiresAt,
    super.createdAt,
  });

  factory QrModel.fromMap(Map<String, dynamic> map) => QrModel(
        id: map['qr_code_id'] ?? map['id'] ?? '',
        imageUrl: map['image_url'] ?? map['imageUrl'],
        publicMenuUrl: map['public_menu_url'] ?? map['publicMenuUrl'],
        downloadUrl: map['download_url'] ?? map['downloadUrl'],
        isActive: map['is_active'] ?? map['isActive'],
        expiresAt: map['expires_at'] != null
            ? DateTime.tryParse(map['expires_at'] as String)
            : null,
        createdAt: map['created_at'] != null
            ? DateTime.tryParse(map['created_at'] as String)
            : null,
      );

  Map<String, dynamic> toMap() => {
        'qr_code_id': id,
        if (imageUrl != null) 'image_url': imageUrl,
        if (publicMenuUrl != null) 'public_menu_url': publicMenuUrl,
        if (downloadUrl != null) 'download_url': downloadUrl,
        if (isActive != null) 'is_active': isActive,
        if (expiresAt != null) 'expires_at': expiresAt!.toIso8601String(),
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      };

  factory QrModel.fromJson(String source) =>
      QrModel.fromMap(jsonDecode(source) as Map<String, dynamic>);

  String toJson() => jsonEncode(toMap());

  Qr toEntity() => this;

  factory QrModel.fromEntity(Qr entity) => QrModel(
        id: entity.id,
        imageUrl: entity.imageUrl,
        publicMenuUrl: entity.publicMenuUrl,
        downloadUrl: entity.downloadUrl,
        isActive: entity.isActive,
        expiresAt: entity.expiresAt,
        createdAt: entity.createdAt,
      );
}
