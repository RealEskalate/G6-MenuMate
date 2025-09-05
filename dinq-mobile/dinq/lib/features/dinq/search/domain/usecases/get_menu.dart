import '../entities/menu.dart' as models;

class GetMenuUseCase {
  Future<models.Menu> execute(String restaurantId) async {
    // This is a mock implementation that would be replaced with actual API call
    // In a real implementation, this would call a repository method
    return _getMockMenu(restaurantId);
  }

  // Mock data for testing UI
  models.Menu _getMockMenu(String restaurantId) {
    return models.Menu(
      id: 'menu-123',
      restaurantId: restaurantId,
      branchId: 'branch-1',
      version: 1,
      isPublished: true,
      publishedAt: DateTime.now().subtract(const Duration(days: 5)),
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
                  name: 'Sambusa',
                  slug: 'sambusa-item-1',
                  categoryId: 'category-1',
                  description:
                      'Crispy pastry filled with spiced lentils and vegetables',
                  price: 45.0,
                  currency: 'ETB',
                  images: ['https://example.com/sambusa.jpg'],
                  ingredients: ['Pastry', 'Lentils', 'Onions', 'Spices'],
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
                models.Item(
                  id: 'item-2',
                  name: 'Timatim Salad',
                  slug: 'timatim-salad-item-2',
                  categoryId: 'category-1',
                  description: 'Fresh tomato salad with onions and jalapeños',
                  price: 35.0,
                  currency: 'ETB',
                  images: ['https://example.com/timatim.jpg'],
                  ingredients: [
                    'Tomatoes',
                    'Onions',
                    'Jalapeños',
                    'Lemon juice',
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
          name: 'Vegetarian',
          categories: [
            models.Category(
              id: 'category-2',
              tabId: 'tab-2',
              name: 'Main Dishes',
              items: [
                models.Item(
                  id: 'item-3',
                  name: 'Shiro',
                  slug: 'shiro-item-3',
                  categoryId: 'category-2',
                  description:
                      'Spiced chickpea stew, a staple in Ethiopian cuisine',
                  price: 80.0,
                  currency: 'ETB',
                  images: ['https://example.com/shiro.jpg'],
                  ingredients: [
                    'Chickpea flour',
                    'Onions',
                    'Garlic',
                    'Berbere spice',
                  ],
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
                models.Item(
                  id: 'item-4',
                  name: 'Misir Wot',
                  slug: 'misir-wot-item-4',
                  categoryId: 'category-2',
                  description: 'Spicy red lentil stew',
                  price: 75.0,
                  currency: 'ETB',
                  images: ['https://example.com/misir.jpg'],
                  ingredients: [
                    'Red lentils',
                    'Onions',
                    'Garlic',
                    'Berbere spice',
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
          name: 'Meat',
          categories: [
            models.Category(
              id: 'category-3',
              tabId: 'tab-3',
              name: 'Specialties',
              items: [
                models.Item(
                  id: 'item-5',
                  name: 'Doro Wot',
                  slug: 'doro-wot-item-5',
                  categoryId: 'category-3',
                  description: 'Spicy chicken stew, Ethiopia\'s national dish',
                  price: 180.0,
                  currency: 'ETB',
                  images: ['https://example.com/doro.jpg'],
                  ingredients: [
                    'Chicken',
                    'Onions',
                    'Garlic',
                    'Berbere spice',
                    'Eggs',
                  ],
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
                models.Item(
                  id: 'item-6',
                  name: 'Kitfo',
                  slug: 'kitfo-item-6',
                  categoryId: 'category-3',
                  description:
                      'Minced raw beef seasoned with mitmita and niter kibbeh',
                  price: 220.0,
                  currency: 'ETB',
                  images: ['https://example.com/kitfo.jpg'],
                  ingredients: ['Minced beef', 'Mitmita spice', 'Niter kibbeh'],
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
          name: 'Drinks',
          categories: [
            models.Category(
              id: 'category-4',
              tabId: 'tab-4',
              name: 'Beverages',
              items: [
                models.Item(
                  id: 'item-7',
                  name: 'Ethiopian Coffee',
                  slug: 'ethiopian-coffee-item-7',
                  categoryId: 'category-4',
                  description: 'Traditional Ethiopian coffee ceremony',
                  price: 40.0,
                  currency: 'ETB',
                  images: ['https://example.com/coffee.jpg'],
                  ingredients: ['Freshly roasted coffee beans'],
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
                models.Item(
                  id: 'item-8',
                  name: 'Tej',
                  slug: 'tej-item-8',
                  categoryId: 'category-4',
                  description: 'Ethiopian honey wine',
                  price: 60.0,
                  currency: 'ETB',
                  images: ['https://example.com/tej.jpg'],
                  ingredients: ['Honey', 'Gesho leaves'],
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
