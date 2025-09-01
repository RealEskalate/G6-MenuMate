import 'dart:convert';

import 'package:dinq/features/restaurant_management/data/model/category_model.dart';
import 'package:dinq/features/restaurant_management/data/model/tab_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Mock CategoryModel data for testing
  final mockCategoryModel = const CategoryModel(
    id: 'category_1',
    tabId: 'tab_1',
    name: 'Meat Dishes',
    nameAm: 'ስጋ ምግቦች',
    items: [],
  );

  final mockCategoryModel2 = const CategoryModel(
    id: 'category_2',
    tabId: 'tab_1',
    name: 'Vegetarian',
    nameAm: 'አህዛዊ',
    items: [],
  );

  const tTabModel = TabModel(
    id: 'tab_1',
    menuId: 'menu_1',
    name: 'Main Course',
    nameAm: 'ዋና ምግብ',
    categories: [], // Will be set in tests
    isDeleted: false,
  );

  const tTabModelDeleted = TabModel(
    id: 'tab_deleted',
    menuId: 'menu_1',
    name: 'Deleted Tab',
    nameAm: 'የተሰረዘ ትርፍ',
    categories: [],
    isDeleted: true,
  );

  group('TabModel', () {
    test('should be a subclass of Tab entity', () {
      // Assert
      expect(tTabModel, isA<TabModel>());
    });

    group('fromMap', () {
      test('should return a valid model when all fields are present', () {
        // Arrange
        final Map<String, dynamic> jsonMap = {
          'id': 'tab_1',
          'menuId': 'menu_1',
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
        };

        // Act
        final result = TabModel.fromMap(jsonMap);

        // Assert
        expect(result.id, 'tab_1');
        expect(result.menuId, 'menu_1');
        expect(result.name, 'Main Course');
        expect(result.nameAm, 'ዋና ምግብ');
        expect(result.isDeleted, false);
        expect(result.categories.length, 1);
        expect(result.categories[0].name, 'Meat Dishes');
      });

      test('should handle null values and provide defaults', () {
        // Arrange
        final Map<String, dynamic> jsonMap = {};

        // Act
        final result = TabModel.fromMap(jsonMap);

        // Assert
        expect(result.id, '');
        expect(result.menuId, '');
        expect(result.name, '');
        expect(result.nameAm, '');
        expect(result.categories, []);
        expect(result.isDeleted, false);
      });

      test('should handle partial data correctly', () {
        // Arrange
        final Map<String, dynamic> jsonMap = {
          'id': 'partial_tab',
          'menuId': 'menu_1',
          'name': 'Partial Tab',
          'isDeleted': true,
        };

        // Act
        final result = TabModel.fromMap(jsonMap);

        // Assert
        expect(result.id, 'partial_tab');
        expect(result.menuId, 'menu_1');
        expect(result.name, 'Partial Tab');
        expect(result.nameAm, '');
        expect(result.categories, []);
        expect(result.isDeleted, true);
      });

      test('should handle empty categories list', () {
        // Arrange
        final Map<String, dynamic> jsonMap = {
          'id': 'empty_categories_tab',
          'menuId': 'menu_1',
          'name': 'Empty Categories Tab',
          'nameAm': 'ባዶ ምድቦች ትርፍ',
          'categories': [],
          'isDeleted': false,
        };

        // Act
        final result = TabModel.fromMap(jsonMap);

        // Assert
        expect(result.categories, []);
        expect(result.categories.length, 0);
      });

      test('should handle multiple categories', () {
        // Arrange
        final Map<String, dynamic> jsonMap = {
          'id': 'multi_category_tab',
          'menuId': 'menu_1',
          'name': 'Multiple Categories',
          'nameAm': 'ብዙ ምድቦች',
          'categories': [
            {
              'id': 'category_1',
              'tabId': 'multi_category_tab',
              'name': 'Meat Dishes',
              'nameAm': 'ስጋ ምግቦች',
              'items': [],
            },
            {
              'id': 'category_2',
              'tabId': 'multi_category_tab',
              'name': 'Vegetarian',
              'nameAm': 'አህዛዊ',
              'items': [],
            },
          ],
          'isDeleted': false,
        };

        // Act
        final result = TabModel.fromMap(jsonMap);

        // Assert
        expect(result.categories.length, 2);
        expect(result.categories[0].name, 'Meat Dishes');
        expect(result.categories[1].name, 'Vegetarian');
        expect(result.categories[0].tabId, 'multi_category_tab');
        expect(result.categories[1].tabId, 'multi_category_tab');
      });

      test('should handle categories with nested items', () {
        // Arrange
        final Map<String, dynamic> jsonMap = {
          'id': 'nested_tab',
          'menuId': 'menu_1',
          'name': 'Nested Tab',
          'nameAm': 'የተሰራ ትርፍ',
          'categories': [
            {
              'id': 'category_1',
              'tabId': 'nested_tab',
              'name': 'Meat Dishes',
              'nameAm': 'ስጋ ምግቦች',
              'items': [
                {
                  'id': 'item_1',
                  'name': 'Doro Wat',
                  'nameAm': 'ዶሮ ዋጥ',
                  'slug': 'doro-wat',
                  'categoryId': 'category_1',
                  'price': 250,
                  'currency': 'ETB',
                  'viewCount': 100,
                  'averageRating': 4.5,
                  'reviewIds': [],
                },
              ],
            },
          ],
          'isDeleted': false,
        };

        // Act
        final result = TabModel.fromMap(jsonMap);

        // Assert
        expect(result.categories.length, 1);
        expect(result.categories[0].items.length, 1);
        expect(result.categories[0].items[0].name, 'Doro Wat');
        expect(result.categories[0].items[0].categoryId, 'category_1');
      });
    });

    group('toMap', () {
      test('should return a JSON map containing the proper data', () {
        // Arrange
        final tabWithCategories = TabModel(
          id: 'tab_1',
          menuId: 'menu_1',
          name: 'Main Course',
          nameAm: 'ዋና ምግብ',
          categories: [mockCategoryModel],
          isDeleted: false,
        );

        // Act
        final result = tabWithCategories.toMap();

        // Assert
        final expectedMap = {
          'id': 'tab_1',
          'menuId': 'menu_1',
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
        };
        expect(result, expectedMap);
      });

      test('should handle empty categories list in toMap', () {
        // Arrange
        final tabWithEmptyCategories = const TabModel(
          id: 'empty_tab',
          menuId: 'menu_1',
          name: 'Empty Tab',
          nameAm: 'ባዶ ትርፍ',
          categories: [],
          isDeleted: false,
        );

        // Act
        final result = tabWithEmptyCategories.toMap();

        // Assert
        expect(result['categories'], []);
        expect(result['isDeleted'], false);
      });

      test('should handle deleted tab in toMap', () {
        // Act
        final result = tTabModelDeleted.toMap();

        // Assert
        expect(result['isDeleted'], true);
        expect(result['name'], 'Deleted Tab');
      });
    });

    group('fromJson', () {
      test('should return a valid model from JSON string', () {
        // Arrange
        final jsonString = '''
        {
          "id": "tab_1",
          "menuId": "menu_1",
          "name": "Main Course",
          "nameAm": "ዋና ምግብ",
          "categories": [
            {
              "id": "category_1",
              "tabId": "tab_1",
              "name": "Meat Dishes",
              "nameAm": "ስጋ ምግቦች",
              "items": []
            }
          ],
          "isDeleted": false
        }
        ''';

        // Act
        final result = TabModel.fromJson(jsonString);

        // Assert
        expect(result.id, 'tab_1');
        expect(result.menuId, 'menu_1');
        expect(result.name, 'Main Course');
        expect(result.nameAm, 'ዋና ምግብ');
        expect(result.isDeleted, false);
        expect(result.categories.length, 1);
      });

      test('should handle malformed JSON gracefully', () {
        // Arrange
        const jsonString =
            '{"id": "test", "menuId": "menu_1"'; // Missing closing brace

        // Act & Assert
        expect(
          () => TabModel.fromJson(jsonString),
          throwsA(isA<FormatException>()),
        );
      });

      test('should handle empty JSON object', () {
        // Arrange
        const jsonString = '{}';

        // Act
        final result = TabModel.fromJson(jsonString);

        // Assert
        expect(result.id, '');
        expect(result.categories, []);
        expect(result.isDeleted, false);
      });
    });

    group('toJson', () {
      test('should return a JSON string containing the proper data', () {
        // Arrange
        final tabWithCategories = TabModel(
          id: 'tab_1',
          menuId: 'menu_1',
          name: 'Main Course',
          nameAm: 'ዋና ምግብ',
          categories: [mockCategoryModel],
          isDeleted: false,
        );

        // Act
        final result = tabWithCategories.toJson();

        // Assert
        final decoded = json.decode(result);
        expect(decoded['id'], 'tab_1');
        expect(decoded['menuId'], 'menu_1');
        expect(decoded['name'], 'Main Course');
        expect(decoded['isDeleted'], false);
        expect(decoded['categories'].length, 1);
      });

      test('should produce valid JSON that can be parsed back', () {
        // Arrange
        final originalTab = TabModel(
          id: 'roundtrip_tab',
          menuId: 'menu_1',
          name: 'Roundtrip Tab',
          nameAm: 'የተሽከርካሪ ትርፍ',
          categories: [mockCategoryModel],
          isDeleted: false,
        );

        // Act
        final jsonString = originalTab.toJson();
        final parsedTab = TabModel.fromJson(jsonString);

        // Assert
        expect(parsedTab.id, originalTab.id);
        expect(parsedTab.menuId, originalTab.menuId);
        expect(parsedTab.name, originalTab.name);
        expect(parsedTab.nameAm, originalTab.nameAm);
        expect(parsedTab.isDeleted, originalTab.isDeleted);
        expect(parsedTab.categories.length, originalTab.categories.length);
      });
    });

    group('copyWith', () {
      test('should return a new instance with updated fields', () {
        // Arrange
        final originalTab = TabModel(
          id: 'original_tab',
          menuId: 'menu_1',
          name: 'Original Tab',
          nameAm: 'ኦሪጀናል ትርፍ',
          categories: [mockCategoryModel],
          isDeleted: false,
        );

        // Act
        final result = originalTab.copyWith(
          name: 'Updated Tab',
          isDeleted: true,
        );

        // Assert
        expect(result.id, originalTab.id);
        expect(result.menuId, originalTab.menuId);
        expect(result.name, 'Updated Tab');
        expect(result.nameAm, originalTab.nameAm);
        expect(result.categories, originalTab.categories);
        expect(result.isDeleted, true);
      });

      test('should return the same instance when no fields are updated', () {
        // Arrange
        final originalTab = const TabModel(
          id: 'same_tab',
          menuId: 'menu_1',
          name: 'Same Tab',
          nameAm: 'ተመሳሳይ ትርፍ',
          categories: [],
          isDeleted: false,
        );

        // Act
        final result = originalTab.copyWith();

        // Assert
        expect(result, equals(originalTab));
      });

      test('should handle categories list updates in copyWith', () {
        // Arrange
        final originalTab = TabModel(
          id: 'categories_tab',
          menuId: 'menu_1',
          name: 'Categories Tab',
          nameAm: 'ምድቦች ትርፍ',
          categories: [mockCategoryModel],
          isDeleted: false,
        );

        // Act
        final result = originalTab.copyWith(
          categories: [mockCategoryModel, mockCategoryModel2],
        );

        // Assert
        expect(result.categories.length, 2);
        expect(result.categories[0].name, 'Meat Dishes');
        expect(result.categories[1].name, 'Vegetarian');
      });
    });

    group('toEntity', () {
      test('should return the same instance since TabModel extends Tab', () {
        // Arrange
        final tabModel = const TabModel(
          id: 'entity_tab',
          menuId: 'menu_1',
          name: 'Entity Tab',
          nameAm: 'እንትነት ትርፍ',
          categories: [],
          isDeleted: false,
        );

        // Act
        final result = tabModel.toEntity();

        // Assert
        expect(result, equals(tabModel));
        expect(result, isA<TabModel>());
      });
    });

    group('stringify', () {
      test('should return true for stringify', () {
        // Assert
        expect(tTabModel.stringify, true);
      });
    });

    group('equality and hashCode', () {
      test('should support equality comparison', () {
        // Arrange
        final tab1 = TabModel(
          id: 'test_tab_1',
          menuId: 'menu_1',
          name: 'Test Tab',
          nameAm: 'የምክክር ትርፍ',
          categories: [mockCategoryModel],
          isDeleted: false,
        );
        final tab2 = TabModel(
          id: 'test_tab_1',
          menuId: 'menu_1',
          name: 'Test Tab',
          nameAm: 'የምክክር ትርፍ',
          categories: [mockCategoryModel],
          isDeleted: false,
        );
        final tab3 = const TabModel(
          id: 'test_tab_2',
          menuId: 'menu_1',
          name: 'Different Tab',
          nameAm: 'የተለየ ትርፍ',
          categories: [],
          isDeleted: true,
        );

        // Assert
        expect(tab1, equals(tab2));
        expect(tab1, isNot(equals(tab3)));
      });

      test('should support hashCode generation', () {
        // Arrange
        final tab1 = const TabModel(
          id: 'hash_tab',
          menuId: 'menu_1',
          name: 'Hash Tab',
          nameAm: 'ሃሽ ትርፍ',
          categories: [],
          isDeleted: false,
        );
        final tab2 = const TabModel(
          id: 'hash_tab',
          menuId: 'menu_1',
          name: 'Hash Tab',
          nameAm: 'ሃሽ ትርፍ',
          categories: [],
          isDeleted: false,
        );

        // Assert
        expect(tab1.hashCode, equals(tab2.hashCode));
      });
    });

    group('edge cases', () {
      test('should handle special characters in tab data', () {
        // Arrange
        final jsonMap = {
          'id': r'special_tab_@#$%',
          'menuId': 'menu_special_123',
          'name': r'Special Tab @#$%',
          'nameAm': r'ልዩ ትርፍ @#$%',
          'categories': [
            {
              'id': 'category_special',
              'tabId': r'special_tab_@#$%',
              'name': r'Special Category @#$%',
              'nameAm': r'ልዩ ምድብ @#$%',
              'items': [],
            },
          ],
          'isDeleted': false,
        };

        // Act
        final result = TabModel.fromMap(jsonMap);
        final jsonResult = result.toJson();
        final parsedBack = TabModel.fromJson(jsonResult);

        // Assert
        expect(result.id, contains('@'));
        expect(result.name, contains('#'));
        expect(result.nameAm, contains('ልዩ'));
        expect(result.categories[0].name, contains(r'$'));
        expect(parsedBack, equals(result));
      });

      test('should handle null categories list', () {
        // Arrange
        final jsonMap = {
          'id': 'null_categories_tab',
          'menuId': 'menu_1',
          'name': 'Null Categories Tab',
          'nameAm': 'ኑል ምድቦች ትርፍ',
          'categories': null,
          'isDeleted': false,
        };

        // Act
        final result = TabModel.fromMap(jsonMap);

        // Assert
        expect(result.categories, []);
        expect(result.categories.length, 0);
      });
    });
  });
}
