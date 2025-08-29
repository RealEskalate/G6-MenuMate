class Menu {
  final String id;
  final String restaurantId;
  final String branchId;
  final int version;
  final bool isPublished;
  final DateTime? publishedAt;
  final List<Tab> tabs;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String updatedBy;
  final bool isDeleted;
  final int viewCount;

  Menu({
    required this.id,
    required this.restaurantId,
    required this.branchId,
    required this.version,
    required this.isPublished,
    this.publishedAt,
    required this.tabs,
    required this.createdAt,
    required this.updatedAt,
    required this.updatedBy,
    this.isDeleted = false,
    this.viewCount = 0,
  });
}

class Tab {
  final String id;
  final String menuId;
  final String name;
  final List<Category> categories;
  final bool isDeleted;

  Tab({
    required this.id,
    required this.menuId,
    required this.name,
    required this.categories,
    this.isDeleted = false,
  });
}

class Category {
  final String id;
  final String tabId;
  final String? name;
  final List<Item> items;

  Category({
    required this.id,
    required this.tabId,
    this.name,
    required this.items,
  });
}

class Item {
  final String id;
  final String name;
  final String slug;
  final String categoryId;
  final String? description;
  final List<String>? images;
  final double price;
  final String currency;
  final bool isAvailable;
  final List<String>? allergies;
  final List<String>? userImages;
  final int? calories;
  final List<String>? ingredients;
  final int? preparationTime;
  final dynamic howToEat;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final int viewCount;
  final double? averageRating;
  final List<String>? reviewIds;

  Item({
    required this.id,
    required this.name,
    required this.slug,
    required this.categoryId,
    this.description,
    this.images,
    required this.price,
    this.currency = "ETB",
    this.isAvailable = true,
    this.allergies,
    this.userImages,
    this.calories,
    this.ingredients,
    this.preparationTime,
    this.howToEat,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
    this.viewCount = 0,
    this.averageRating,
    this.reviewIds,
  });
}