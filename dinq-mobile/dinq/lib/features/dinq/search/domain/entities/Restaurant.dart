class Restaurant {
  final String id;
  final String name;
  final String? about;
  final List<String>? verificationDocs;
  final VerificationStatus verificationStatus;
  final Contact contact;
  final String ownerId;
  final String? logoImage;
  final List<String> branchIds;
  final double averageRating;
  final List<String>? tags;
  final bool isOpen;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final int viewCount;

  Restaurant({
    required this.id,
    required this.name,
    this.about,
    this.verificationDocs,
    required this.verificationStatus,
    required this.contact,
    required this.ownerId,
    this.logoImage,
    required this.branchIds,
    required this.averageRating,
    this.tags,
    this.isOpen = false,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
    this.viewCount = 0,
  });
}

enum VerificationStatus { pending, verified, rejected }

class Contact {
  final String phone;
  final String email;
  final List<Uri> social;

  Contact({
    required this.phone,
    required this.email,
    required this.social,
  });
}
