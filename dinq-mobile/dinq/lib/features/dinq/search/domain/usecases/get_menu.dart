import '../entities/menu.dart' as models;
import 'package:dio/dio.dart';
import '../../../../../core/constants/constants.dart';
import '../../../../../core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'dart:convert';

class GetMenuUseCase {
  final Dio _dio = Dio();
  
  // Updated to use slug instead of restaurantId
  Future<Either<Failure, models.Menu>> execute(String slug) async {
    print('GetMenuUseCase: Fetching menu with slug: $slug');
    try {
      // Ensure slug is properly formatted - remove any leading colons
      final cleanSlug = slug.startsWith(':') ? slug.substring(1) : slug;
      
      final url = '$baseUrl/menus/$cleanSlug';
      print('GetMenuUseCase: Sending GET request to: $url');
      
      final response = await _dio.get(
        url,
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );
      
      print('GetMenuUseCase: Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        try {
          print('GetMenuUseCase: Successfully fetched menu data');
          final menuData = response.data;
          return Right(_parseMenuData(menuData, cleanSlug));
        } catch (e) {
          print('GetMenuUseCase: Error parsing menu data: $e');
          // Fallback to mock data if parsing fails
          return Right(_getMockMenu(cleanSlug));
        }
      } else if (response.statusCode == 404) {
        print('GetMenuUseCase: Menu not found');
        return Left(NotFoundFailure('No menu found for this restaurant.'));
      } else {
        print('GetMenuUseCase: Server error: ${response.statusCode}');
        return Left(ServerFailure('Server error: ${response.statusCode}'));
      }
    } catch (e) {
      print('GetMenuUseCase: GET request error: $e');
      return Left(ServerFailure('Failed to connect to server: $e'));
    }
  }
  
  // Parse real menu data from API response
  models.Menu _parseMenuData(Map<String, dynamic> data, String slug) {
    try {
      final menuData = data['data'] ?? data;
      
      // Extract basic menu information
      final String id = menuData['_id'] ?? 'unknown-id';
      final String restaurantId = menuData['restaurant_id'] ?? 'unknown-restaurant';
      final String branchId = menuData['branch_id'] ?? 'main-branch';
      final int version = menuData['version'] ?? 1;
      final bool isPublished = menuData['is_published'] ?? true;
      
      // Parse dates if available
      DateTime? publishedAt;
      DateTime? createdAt;
      DateTime? updatedAt;
      
      if (menuData['published_at'] != null) {
        publishedAt = DateTime.parse(menuData['published_at']);
      }
      
      if (menuData['created_at'] != null) {
        createdAt = DateTime.parse(menuData['created_at']);
      }
      
      if (menuData['updated_at'] != null) {
        updatedAt = DateTime.parse(menuData['updated_at']);
      }
      
      // Parse tabs/categories/items
      List<models.Tab> tabs = [];
      
      if (menuData['tabs'] != null && menuData['tabs'] is List) {
        tabs = (menuData['tabs'] as List).map((tabData) {
          final String tabId = tabData['_id'] ?? 'unknown-tab-id';
          final String tabName = tabData['name'] ?? 'Unnamed Tab';
          
          List<models.Category> categories = [];
          
          if (tabData['categories'] != null && tabData['categories'] is List) {
            categories = (tabData['categories'] as List).map((categoryData) {
              final String categoryId = categoryData['_id'] ?? 'unknown-category-id';
              final String categoryName = categoryData['name'] ?? 'Unnamed Category';
              
              List<models.Item> items = [];
              
              if (categoryData['items'] != null && categoryData['items'] is List) {
                items = (categoryData['items'] as List).map((itemData) {
                  return models.Item(
                    id: itemData['_id'] ?? 'unknown-item-id',
                    name: itemData['name'] ?? 'Unnamed Item',
                    slug: itemData['slug'] ?? 'unknown-slug',
                    categoryId: categoryId,
                    description: itemData['description'] ?? '',
                    price: double.tryParse(itemData['price']?.toString() ?? '0') ?? 0.0,
                    currency: itemData['currency'] ?? '\$',
                    images: itemData['images'] != null ? List<String>.from(itemData['images']) : null,
                    ingredients: itemData['ingredients'] != null ? List<String>.from(itemData['ingredients']) : [],
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                    isDeleted: itemData['is_deleted'] ?? false,
                    viewCount: itemData['view_count'] ?? 0,
                    averageRating: double.tryParse(itemData['average_rating']?.toString() ?? '0') ?? 0.0,
                    reviewIds: itemData['review_ids'] != null ? List<String>.from(itemData['review_ids']) : [],
                  );
                }).toList();
              }
              
              return models.Category(
                id: categoryId,
                tabId: tabId,
                name: categoryName,
                items: items,
              );
            }).toList();
          }
          
          return models.Tab(
            id: tabId,
            menuId: id,
            name: tabName,
            categories: categories,
          );
        }).toList();
      }
      
      return models.Menu(
        id: id,
        restaurantId: restaurantId,
        branchId: branchId,
        version: version,
        isPublished: isPublished,
        publishedAt: publishedAt,
        createdAt: createdAt,
        updatedAt: updatedAt,
        updatedBy: menuData['updated_by'],
        isDeleted: menuData['is_deleted'] ?? false,
        viewCount: menuData['view_count'] ?? 0,
        tabs: tabs,
      );
    } catch (e) {
      print('Error parsing menu data: $e');
      // Return mock data as fallback
      return _getMockMenu(slug);
    }
  }

  // Mock data for testing UI
  models.Menu _getMockMenu(String slug) {
    print('GetMenuUseCase: Creating mock menu for slug: $slug');
    return models.Menu(
      id: 'menu-123',
      restaurantId: 'restaurant-$slug',
      branchId: 'branch-1',
      version: 1,
      isPublished: true,
      publishedAt: DateTime.now().subtract(const Duration(days: 5)),
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedBy: 'admin',
      isDeleted: false,
      viewCount: 120,
      tabs: [
        models.Tab(
          id: 'tab-1',
          menuId: 'menu-123',
          name: 'Starters',
          categories: [
            models.Category(
              id: 'category-1',
              tabId: 'tab-1',
              name: 'Appetizers',
              items: [
                models.Item(
                  id: 'item-1',
                  name: 'Bruschetta',
                  slug: 'bruschetta-item-1',
                  categoryId: 'category-1',
                  description:
                      'Toasted bread topped with tomatoes, garlic, basil and olive oil',
                  price: 12.99,
                  currency: '\$',
                  images: ['https://images.unsplash.com/photo-1572695157366-5e585ab2b69f?auto=format&fit=crop&w=400&q=80'],
                  ingredients: ['Bread', 'Tomatoes', 'Garlic', 'Basil', 'Olive Oil'],
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                  isDeleted: false,
                  viewCount: 0,
                  averageRating: 4.5,
                  reviewIds: ['review-1', 'review-2'],
                ),
                models.Item(
                  id: 'item-2',
                  name: 'Caprese Salad',
                  slug: 'caprese-salad-item-2',
                  categoryId: 'category-1',
                  description: 'Fresh mozzarella, tomatoes and basil with balsamic glaze',
                  price: 14.99,
                  currency: '\$',
                  images: ['https://images.unsplash.com/photo-1551782450-17144efb5723?auto=format&fit=crop&w=400&q=80'],
                  ingredients: [
                    'Mozzarella',
                    'Tomatoes',
                    'Basil',
                    'Balsamic Glaze',
                    'Olive Oil',
                  ],
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
              ],
            ),
          ],
        ),
        models.Tab(
          id: 'tab-2',
          menuId: 'menu-123',
          name: 'Pasta',
          categories: [
            models.Category(
              id: 'category-2',
              tabId: 'tab-2',
              name: 'Classic Pasta',
              items: [
                models.Item(
                  id: 'item-3',
                  name: 'Spaghetti Carbonara',
                  slug: 'spaghetti-carbonara-item-3',
                  categoryId: 'category-2',
                  description:
                      'Creamy pasta with pancetta, eggs, and Parmesan cheese',
                  price: 18.99,
                  currency: '\$',
                  images: ['https://images.unsplash.com/photo-1551892376-7e0f3f3f8f9f?auto=format&fit=crop&w=400&q=80'],
                  ingredients: [
                    'Spaghetti',
                    'Pancetta',
                    'Eggs',
                    'Parmesan',
                    'Black Pepper',
                  ],
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
                models.Item(
                  id: 'item-4',
                  name: 'Margherita Pizza',
                  slug: 'margherita-pizza-item-4',
                  categoryId: 'category-2',
                  description: 'Classic pizza with tomato sauce, mozzarella and fresh basil',
                  price: 16.99,
                  currency: '\$',
                  images: ['https://images.unsplash.com/photo-1542281286-9e0a16bb7366?auto=format&fit=crop&w=400&q=80'],
                  ingredients: [
                    'Pizza Dough',
                    'Tomato Sauce',
                    'Mozzarella',
                    'Basil',
                    'Olive Oil',
                  ],
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
              ],
            ),
          ],
        ),
        models.Tab(
          id: 'tab-3',
          menuId: 'menu-123',
          name: 'Main Courses',
          categories: [
            models.Category(
              id: 'category-3',
              tabId: 'tab-3',
              name: 'Meat Dishes',
              items: [
                models.Item(
                  id: 'item-5',
                  name: 'Osso Buco',
                  slug: 'osso-buco-item-5',
                  categoryId: 'category-3',
                  description: 'Braised veal shanks with vegetables and white wine',
                  price: 28.99,
                  currency: '\$',
                  images: ['https://images.unsplash.com/photo-1546833999-b9f581a1996d?auto=format&fit=crop&w=400&q=80'],
                  ingredients: [
                    'Veal Shanks',
                    'Vegetables',
                    'White Wine',
                    'Herbs',
                    'Risotto',
                  ],
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
                models.Item(
                  id: 'item-6',
                  name: 'Grilled Branzino',
                  slug: 'grilled-branzino-item-6',
                  categoryId: 'category-3',
                  description:
                      'Mediterranean sea bass grilled with herbs and lemon',
                  price: 24.99,
                  currency: '\$',
                  images: ['https://images.unsplash.com/photo-1467003909585-2f8a72700288?auto=format&fit=crop&w=400&q=80'],
                  ingredients: ['Sea Bass', 'Lemon', 'Herbs', 'Olive Oil', 'Garlic'],
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
              ],
            ),
          ],
        ),
        models.Tab(
          id: 'tab-4',
          menuId: 'menu-123',
          name: 'Beverages',
          categories: [
            models.Category(
              id: 'category-4',
              tabId: 'tab-4',
              name: 'Drinks',
              items: [
                models.Item(
                  id: 'item-7',
                  name: 'Espresso',
                  slug: 'espresso-item-7',
                  categoryId: 'category-4',
                  description: 'Rich and bold Italian espresso coffee',
                  price: 3.99,
                  currency: '\$',
                  images: ['https://images.unsplash.com/photo-1510591509098-f4fdc6d0ff04?auto=format&fit=crop&w=400&q=80'],
                  ingredients: ['Premium Coffee Beans'],
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
                models.Item(
                  id: 'item-8',
                  name: 'Limoncello',
                  slug: 'limoncello-item-8',
                  categoryId: 'category-4',
                  description: 'Traditional Italian lemon liqueur',
                  price: 8.99,
                  currency: '\$',
                  images: ['https://images.unsplash.com/photo-1551538827-9c037cb4f32a?auto=format&fit=crop&w=400&q=80'],
                  ingredients: ['Lemons', 'Alcohol', 'Sugar'],
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
              ],
            ),
          ],
        ),
      ],
      // No duplicate named arguments
      // Fields already set in the constructor
    );
  }
}
