import '../entities/menu.dart' as models;
import 'package:dio/dio.dart';
import '../../../../../core/constants/constants.dart';
import '../../../../../core/error/failures.dart';
import 'package:dartz/dartz.dart';

class GetMenuUseCase {
  final Dio _dio = Dio();
  
  // Updated to use slug instead of restaurantId
  Future<Either<Failure, models.Menu>> execute(String slug) async {
    print('GetMenuUseCase: Fetching menu with slug: $slug');
    try {
      final url = '$baseUrl/menus/$slug';
      print('GetMenuUseCase: Sending GET request to: $url');
      
      final response = await _dio.get(
        url,
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );
      
      print('GetMenuUseCase: Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        // TODO: Parse the actual response data
        // For now, returning mock data
        print('GetMenuUseCase: Successfully fetched menu data');
        return Right(_getMockMenu(slug));
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
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedBy: 'user-123',
    );
  }
}
