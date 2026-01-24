import 'dart:convert';

import 'package:dinq/features/dinq/restaurant_management/data/model/menu_model.dart';
import 'package:dinq/features/dinq/restaurant_management/data/model/tab_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Mock TabModel data for testing
  final mockTabModel = const TabModel(
    id: 'tab_1',
    menuId: 'menu_1',
    name: 'Main Course',
    nameAm: 'ዋና ምግብ',
    categories: [],
    isDeleted: false,
  );

  final mockTabModelDeleted = const TabModel(
    id: 'tab_deleted',
    menuId: 'menu_1',
    name: 'Deleted Tab',
    nameAm: 'የተሰረዘ ትርፍ',
    categories: [],
    isDeleted: true,
  );

  const tMenuModel = MenuModel(
    id: 'menu_1',
    restaurantId: 'restaurant_1',
    isPublished: true,
    tabs: [], // Will be set in tests
    viewCount: 500,
  );

  group('MenuModel', () {
    test('should be a subclass of Menu entity', () {
      // Assert
      expect(tMenuModel, isA<MenuModel>());
    });

    group('fromMap', () {
      test('should return a valid model when all fields are present', () {
        // Arrange
        final Map<String, dynamic> jsonMap = {
          'id': 'menu_1',
          'restaurantId': 'restaurant_1',
          'isPublished': true,
          'tabs': [
            {
              'id': 'tab_1',
              'menuId': 'menu_1',
              'name': 'Main Course',
              'nameAm': 'ዋና ምግብ',
              'categories': [],
              'isDeleted': false,
            },
          ],
          'viewCount': 500,
        };

        // Act
        final result = MenuModel.fromMap(jsonMap);

        // Assert
        expect(result.id, 'menu_1');
        expect(result.restaurantId, 'restaurant_1');
        expect(result.isPublished, true);
        expect(result.viewCount, 500);
        expect(result.tabs.length, 1);
        expect(result.tabs[0].name, 'Main Course');
      });

      test('should handle null values and provide defaults', () {
        // Arrange
        final Map<String, dynamic> jsonMap = {};

        // Act
        final result = MenuModel.fromMap(jsonMap);

        // Assert
        expect(result.id, '');
        expect(result.restaurantId, '');
        expect(result.isPublished, false);
        expect(result.tabs, []);
        expect(result.viewCount, 0);
      });

      test('should handle partial data correctly', () {
        // Arrange
        final Map<String, dynamic> jsonMap = {
          'id': 'partial_menu',
          'restaurantId': 'restaurant_1',
          'isPublished': true,
        };

        // Act
        final result = MenuModel.fromMap(jsonMap);

        // Assert
        expect(result.id, 'partial_menu');
        expect(result.restaurantId, 'restaurant_1');
        expect(result.isPublished, true);
        expect(result.tabs, []);
        expect(result.viewCount, 0);
      });

      test('should handle empty tabs list', () {
        // Arrange
        final Map<String, dynamic> jsonMap = {
          'id': 'empty_tabs_menu',
          'restaurantId': 'restaurant_1',
          'isPublished': true,
          'tabs': [],
          'viewCount': 100,
        };

        // Act
        final result = MenuModel.fromMap(jsonMap);

        // Assert
        expect(result.tabs, []);
        expect(result.tabs.length, 0);
      });

      test('should handle multiple tabs', () {
        // Arrange
        final Map<String, dynamic> jsonMap = {
          'id': 'multi_tab_menu',
          'restaurantId': 'restaurant_1',
          'isPublished': true,
          'tabs': [
            {
              'id': 'tab_1',
              'menuId': 'multi_tab_menu',
              'name': 'Main Course',
              'nameAm': 'ዋና ምግብ',
              'categories': [],
              'isDeleted': false,
            },
            {
              'id': 'tab_2',
              'menuId': 'multi_tab_menu',
              'name': 'Desserts',
              'nameAm': 'መልክ ምግቦች',
              'categories': [],
              'isDeleted': false,
            },
          ],
          'viewCount': 200,
        };

        // Act
        final result = MenuModel.fromMap(jsonMap);

        // Assert
        expect(result.tabs.length, 2);
        expect(result.tabs[0].name, 'Main Course');
        expect(result.tabs[1].name, 'Desserts');
        expect(result.tabs[0].menuId, 'multi_tab_menu');
        expect(result.tabs[1].menuId, 'multi_tab_menu');
      });

      test('should handle tabs with nested categories', () {
        // Arrange
        final Map<String, dynamic> jsonMap = {
          'id': 'nested_menu',
          'restaurantId': 'restaurant_1',
          'isPublished': true,
          'tabs': [
            {
              'id': 'tab_1',
              'menuId': 'nested_menu',
              'name': 'Main Course',
              'nameAm': 'ዋና ምግብ',
              'categories': [
                {
                  'id': 'category_1',
                  'tabId': 'tab_1',
                  'name': 'Meat Dishes',
                  'nameAm': 'ስጋ ምግቦች',
                  'items': [],
                },
              ],
              'isDeleted': false,
            },
          ],
          'viewCount': 150,
        };

        // Act
        final result = MenuModel.fromMap(jsonMap);

        // Assert
        expect(result.tabs.length, 1);
        expect(result.tabs[0].categories.length, 1);
        expect(result.tabs[0].categories[0].name, 'Meat Dishes');
        expect(result.tabs[0].categories[0].tabId, 'tab_1');
      });
    });

    group('toMap', () {
      test('should return a JSON map containing the proper data', () {
        // Arrange
        final menuWithTabs = MenuModel(
          id: 'menu_1',
          restaurantId: 'restaurant_1',
          isPublished: true,
          tabs: [mockTabModel],
          viewCount: 500,
        );

        // Act
        final result = menuWithTabs.toMap();

        // Assert
        final expectedMap = {
          'id': 'menu_1',
          'restaurantId': 'restaurant_1',
          'isPublished': true,
          'tabs': [
            {
              'id': 'tab_1',
              'menuId': 'menu_1',
              'name': 'Main Course',
              'nameAm': 'ዋና ምግብ',
              'categories': [],
              'isDeleted': false,
            },
          ],
          'viewCount': 500,
        };
        expect(result, expectedMap);
      });

      test('should handle empty tabs list in toMap', () {
        // Arrange
        final menuWithEmptyTabs = const MenuModel(
          id: 'empty_menu',
          restaurantId: 'restaurant_1',
          isPublished: false,
          tabs: [],
          viewCount: 0,
        );

        // Act
        final result = menuWithEmptyTabs.toMap();

        // Assert
        expect(result['tabs'], []);
        expect(result['isPublished'], false);
      });

      test('should handle multiple tabs in toMap', () {
        // Arrange
        final menuWithMultipleTabs = MenuModel(
          id: 'multi_menu',
          restaurantId: 'restaurant_1',
          isPublished: true,
          tabs: [mockTabModel, mockTabModelDeleted],
          viewCount: 300,
        );

        // Act
        final result = menuWithMultipleTabs.toMap();

        // Assert
        expect(result['tabs'].length, 2);
        expect(result['tabs'][0]['name'], 'Main Course');
        expect(result['tabs'][1]['name'], 'Deleted Tab');
        expect(result['tabs'][1]['isDeleted'], true);
      });
    });

    group('fromJson', () {
      test('should return a valid model from JSON string', () {
        // Arrange
        final jsonString = '''
        {
          "id": "menu_1",
          "restaurantId": "restaurant_1",
          "isPublished": true,
          "tabs": [
            {
              "id": "tab_1",
              "menuId": "menu_1",
              "name": "Main Course",
              "nameAm": "ዋና ምግብ",
              "categories": [],
              "isDeleted": false
            }
          ],
          "viewCount": 500
        }
        ''';

        // Act
        final result = MenuModel.fromJson(jsonString);

        // Assert
        expect(result.id, 'menu_1');
        expect(result.restaurantId, 'restaurant_1');
        expect(result.isPublished, true);
        expect(result.viewCount, 500);
        expect(result.tabs.length, 1);
      });

      test('should handle malformed JSON gracefully', () {
        // Arrange
        const jsonString =
            '{"id": "test", "restaurantId": "restaurant_1"'; // Missing closing brace

        // Act & Assert
        expect(
          () => MenuModel.fromJson(jsonString),
          throwsA(isA<FormatException>()),
        );
      });

      test('should handle empty JSON object', () {
        // Arrange
        const jsonString = '{}';

        // Act
        final result = MenuModel.fromJson(jsonString);

        // Assert
        expect(result.id, '');
        expect(result.tabs, []);
        expect(result.isPublished, false);
      });
    });

    group('toJson', () {
      test('should return a JSON string containing the proper data', () {
        // Arrange
        final menuWithTabs = MenuModel(
          id: 'menu_1',
          restaurantId: 'restaurant_1',
          isPublished: true,
          tabs: [mockTabModel],
          viewCount: 500,
        );

        // Act
        final result = menuWithTabs.toJson();

        // Assert
        final decoded = json.decode(result);
        expect(decoded['id'], 'menu_1');
        expect(decoded['restaurantId'], 'restaurant_1');
        expect(decoded['isPublished'], true);
        expect(decoded['viewCount'], 500);
        expect(decoded['tabs'].length, 1);
      });

      test('should produce valid JSON that can be parsed back', () {
        // Arrange
        final originalMenu = MenuModel(
          id: 'roundtrip_menu',
          restaurantId: 'restaurant_1',
          isPublished: true,
          tabs: [mockTabModel],
          viewCount: 250,
        );

        // Act
        final jsonString = originalMenu.toJson();
        final parsedMenu = MenuModel.fromJson(jsonString);

        // Assert
        expect(parsedMenu.id, originalMenu.id);
        expect(parsedMenu.restaurantId, originalMenu.restaurantId);
        expect(parsedMenu.isPublished, originalMenu.isPublished);
        expect(parsedMenu.viewCount, originalMenu.viewCount);
        expect(parsedMenu.tabs.length, originalMenu.tabs.length);
      });
    });

    group('copyWith', () {
      test('should return a new instance with updated fields', () {
        // Arrange
        final originalMenu = MenuModel(
          id: 'original_menu',
          restaurantId: 'restaurant_1',
          isPublished: false,
          tabs: [mockTabModel],
          viewCount: 100,
        );

        // Act
        final result = originalMenu.copyWith(
          id: 'updated_menu',
          isPublished: true,
          viewCount: 200,
        );

        // Assert
        expect(result.id, 'updated_menu');
        expect(result.restaurantId, originalMenu.restaurantId);
        expect(result.isPublished, true);
        expect(result.tabs, originalMenu.tabs);
        expect(result.viewCount, 200);
      });

      test('should return the same instance when no fields are updated', () {
        // Arrange
        final originalMenu = const MenuModel(
          id: 'same_menu',
          restaurantId: 'restaurant_1',
          isPublished: true,
          tabs: [],
          viewCount: 50,
        );

        // Act
        final result = originalMenu.copyWith();

        // Assert
        expect(result, equals(originalMenu));
      });

      test('should handle tabs list updates in copyWith', () {
        // Arrange
        final originalMenu = MenuModel(
          id: 'tabs_menu',
          restaurantId: 'restaurant_1',
          isPublished: true,
          tabs: [mockTabModel],
          viewCount: 75,
        );

        // Act
        final result = originalMenu.copyWith(
          tabs: [mockTabModel, mockTabModelDeleted],
        );

        // Assert
        expect(result.tabs.length, 2);
        expect(result.tabs[0].name, 'Main Course');
        expect(result.tabs[1].name, 'Deleted Tab');
      });
    });

    group('toEntity', () {
      test('should return the same instance since MenuModel extends Menu', () {
        // Arrange
        final menuModel = const MenuModel(
          id: 'entity_menu',
          restaurantId: 'restaurant_1',
          isPublished: true,
          tabs: [],
          viewCount: 25,
        );

        // Act
        final result = menuModel.toEntity();

        // Assert
        expect(result, equals(menuModel));
        expect(result, isA<MenuModel>());
      });
    });

    group('stringify', () {
      test('should return true for stringify', () {
        // Assert
        expect(tMenuModel.stringify, true);
      });
    });

    group('equality and hashCode', () {
      test('should support equality comparison', () {
        // Arrange
        final menu1 = MenuModel(
          id: 'test_menu_1',
          restaurantId: 'restaurant_1',
          isPublished: true,
          tabs: [mockTabModel],
          viewCount: 100,
        );
        final menu2 = MenuModel(
          id: 'test_menu_1',
          restaurantId: 'restaurant_1',
          isPublished: true,
          tabs: [mockTabModel],
          viewCount: 100,
        );
        final menu3 = const MenuModel(
          id: 'test_menu_2',
          restaurantId: 'restaurant_1',
          isPublished: false,
          tabs: [],
          viewCount: 50,
        );

        // Assert
        expect(menu1, equals(menu2));
        expect(menu1, isNot(equals(menu3)));
      });

      test('should support hashCode generation', () {
        // Arrange
        final menu1 = const MenuModel(
          id: 'hash_menu',
          restaurantId: 'restaurant_1',
          isPublished: true,
          tabs: [],
          viewCount: 75,
        );
        final menu2 = const MenuModel(
          id: 'hash_menu',
          restaurantId: 'restaurant_1',
          isPublished: true,
          tabs: [],
          viewCount: 75,
        );

        // Assert
        expect(menu1.hashCode, equals(menu2.hashCode));
      });
    });

    group('edge cases', () {
      test('should handle special characters in menu data', () {
        // Arrange
        final jsonMap = {
          'id': 'special_menu_@#\$%',
          'restaurantId': 'restaurant_special_123',
          'isPublished': true,
          'tabs': [
            {
              'id': 'tab_special',
              'menuId': 'special_menu_@#\$%',
              'name': r'Special Tab @#$%',
              'nameAm': r'ልዩ ትርፍ @#$%',
              'categories': [],
              'isDeleted': false,
            },
          ],
          'viewCount': 999,
        };

        // Act
        final result = MenuModel.fromMap(jsonMap);
        final jsonResult = result.toJson();
        final parsedBack = MenuModel.fromJson(jsonResult);

        // Assert
        expect(result.id, contains('@'));
        expect(result.tabs[0].name, contains('#'));
        expect(result.tabs[0].nameAm, contains('ልዩ'));
        expect(parsedBack, equals(result));
      });

      test('should handle very large view counts', () {
        // Arrange
        final jsonMap = {
          'id': 'popular_menu',
          'restaurantId': 'restaurant_1',
          'isPublished': true,
          'tabs': [],
          'viewCount': 999999999,
        };

        // Act
        final result = MenuModel.fromMap(jsonMap);

        // Assert
        expect(result.viewCount, 999999999);
      });

      test('should handle null tabs list', () {
        // Arrange
        final jsonMap = {
          'id': 'null_tabs_menu',
          'restaurantId': 'restaurant_1',
          'isPublished': true,
          'tabs': null,
          'viewCount': 10,
        };

        // Act
        final result = MenuModel.fromMap(jsonMap);

        // Assert
        expect(result.tabs, []);
        expect(result.tabs.length, 0);
      });
    });
  });
}
