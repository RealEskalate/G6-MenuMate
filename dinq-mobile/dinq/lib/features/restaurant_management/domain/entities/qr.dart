import 'package:equatable/equatable.dart';

class Qr extends Equatable {
  final String id;
  final String? imageUrl;
  final String? publicMenuUrl;
  final String? downloadUrl;
  final bool? isActive;
  final DateTime? expiresAt;
  final DateTime? createdAt;

  const Qr({
    required this.id,
    this.imageUrl,
    this.publicMenuUrl,
    this.downloadUrl,
    this.isActive,
    this.expiresAt,
    this.createdAt,
  });

  @override
  List<Object?> get props => [id];
}
