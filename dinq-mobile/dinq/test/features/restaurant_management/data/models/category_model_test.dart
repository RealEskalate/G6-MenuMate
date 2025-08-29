import 'dart:convert';

import 'package:dinq/features/restaurant_management/data/model/category_model.dart';
import 'package:dinq/features/restaurant_management/data/model/item_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Mock ItemModel data for testing
  final mockItemModel = const ItemModel(
    id: 'item_1',
    name: 'Doro Wat',
    nameAm: 'ዶሮ ዋጥ',
    slug: 'doro-wat',
    categoryId: 'category_1',
    price: 250,
    currency: 'ETB',
    viewCount: 100,
    averageRating: 4.5,
    reviewIds: [],
  );

  final mockItemModel2 = const ItemModel(
    id: 'item_2',
    name: 'Tibs',
    nameAm: 'ቲብስ',
    slug: 'tibs',
    categoryId: 'category_1',
    price: 200,
    currency: 'ETB',
    viewCount: 80,
    averageRating: 4.2,
    reviewIds: [],
  );

  const tCategoryModel = CategoryModel(
    id: 'category_1',
    tabId: 'tab_1',
    name: 'Meat Dishes',
    nameAm: 'ስጋ ምግቦች',
    items: [], // Will be set in tests
  );

  const tCategoryModelEmpty = CategoryModel(
    id: 'category_empty',
    tabId: 'tab_1',
    name: 'Empty Category',
    nameAm: 'ባዶ ምድብ',
    items: [],
  );

  group('CategoryModel', () {
    test('should be a subclass of Category entity', () {
      // Assert
      expect(tCategoryModel, isA<CategoryModel>());
    });

    group('fromMap', () {
      test('should return a valid model when all fields are present', () {
        // Arrange
        final Map<String, dynamic> jsonMap = {
          'id': 'category_1',
          'tabId': 'tab_1',
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
        };

        // Act
        final result = CategoryModel.fromMap(jsonMap);

        // Assert
        expect(result.id, 'category_1');
        expect(result.tabId, 'tab_1');
        expect(result.name, 'Meat Dishes');
        expect(result.nameAm, 'ስጋ ምግቦች');
        expect(result.items.length, 1);
        expect(result.items[0].name, 'Doro Wat');
      });

      test('should handle null values and provide defaults', () {
        // Arrange
        final Map<String, dynamic> jsonMap = {};

        // Act
        final result = CategoryModel.fromMap(jsonMap);

        // Assert
        expect(result.id, '');
        expect(result.tabId, '');
        expect(result.name, '');
        expect(result.nameAm, '');
        expect(result.items, []);
      });

      test('should handle partial data correctly', () {
        // Arrange
        final Map<String, dynamic> jsonMap = {
          'id': 'partial_category',
          'tabId': 'tab_1',
          'name': 'Partial Category',
        };

        // Act
        final result = CategoryModel.fromMap(jsonMap);

        // Assert
        expect(result.id, 'partial_category');
        expect(result.tabId, 'tab_1');
        expect(result.name, 'Partial Category');
        expect(result.nameAm, '');
        expect(result.items, []);
      });

      test('should handle empty items list', () {
        // Arrange
        final Map<String, dynamic> jsonMap = {
          'id': 'empty_items_category',
          'tabId': 'tab_1',
          'name': 'Empty Items Category',
          'nameAm': 'ባዶ ንጥሎች ምድብ',
          'items': [],
        };

        // Act
        final result = CategoryModel.fromMap(jsonMap);

        // Assert
        expect(result.items, []);
        expect(result.items.length, 0);
      });

      test('should handle multiple items', () {
        // Arrange
        final Map<String, dynamic> jsonMap = {
          'id': 'multi_item_category',
          'tabId': 'tab_1',
          'name': 'Multiple Items Category',
          'nameAm': 'ብዙ ንጥሎች ምድብ',
          'items': [
            {
              'id': 'item_1',
              'name': 'Doro Wat',
              'nameAm': 'ዶሮ ዋጥ',
              'slug': 'doro-wat',
              'categoryId': 'multi_item_category',
              'price': 250,
              'currency': 'ETB',
              'viewCount': 100,
              'averageRating': 4.5,
              'reviewIds': [],
            },
            {
              'id': 'item_2',
              'name': 'Tibs',
              'nameAm': 'ቲብስ',
              'slug': 'tibs',
              'categoryId': 'multi_item_category',
              'price': 200,
              'currency': 'ETB',
              'viewCount': 80,
              'averageRating': 4.2,
              'reviewIds': [],
            },
          ],
        };

        // Act
        final result = CategoryModel.fromMap(jsonMap);

        // Assert
        expect(result.items.length, 2);
        expect(result.items[0].name, 'Doro Wat');
        expect(result.items[1].name, 'Tibs');
        expect(result.items[0].categoryId, 'multi_item_category');
        expect(result.items[1].categoryId, 'multi_item_category');
      });
    });

    group('toMap', () {
      test('should return a JSON map containing the proper data', () {
        // Arrange
        final categoryWithItems = CategoryModel(
          id: 'category_1',
          tabId: 'tab_1',
          name: 'Meat Dishes',
          nameAm: 'ስጋ ምግቦች',
          items: [mockItemModel],
        );

        // Act
        final result = categoryWithItems.toMap();

        // Assert
        final expectedMap = {
          'id': 'category_1',
          'tabId': 'tab_1',
          'name': 'Meat Dishes',
          'nameAm': 'ስጋ ምግቦች',
          'items': [
            {
              'id': 'item_1',
              'name': 'Doro Wat',
              'nameAm': 'ዶሮ ዋጥ',
              'slug': 'doro-wat',
              'categoryId': 'category_1',
              'description': null,
              'descriptionAm': null,
              'image': null,
              'price': 250,
              'currency': 'ETB',
              'allergies': null,
              'userImages': null,
              'calories': null,
              'ingredients': null,
              'ingredientsAm': null,
              'preparationTime': null,
              'howToEat': null,
              'howToEatAm': null,
              'viewCount': 100,
              'averageRating': 4.5,
              'reviewIds': [],
            },
          ],
        };
        expect(result, expectedMap);
      });

      test('should handle empty items list in toMap', () {
        // Act
        final result = tCategoryModelEmpty.toMap();

        // Assert
        expect(result['items'], []);
        expect(result['name'], 'Empty Category');
      });

      test('should handle multiple items in toMap', () {
        // Arrange
        final categoryWithMultipleItems = CategoryModel(
          id: 'multi_category',
          tabId: 'tab_1',
          name: 'Multiple Items',
          nameAm: 'ብዙ ንጥሎች',
          items: [mockItemModel, mockItemModel2],
        );

        // Act
        final result = categoryWithMultipleItems.toMap();

        // Assert
        expect(result['items'].length, 2);
        expect(result['items'][0]['name'], 'Doro Wat');
        expect(result['items'][1]['name'], 'Tibs');
      });
    });

    group('fromJson', () {
      test('should return a valid model from JSON string', () {
        // Arrange
        final jsonString = '''
        {
          "id": "category_1",
          "tabId": "tab_1",
          "name": "Meat Dishes",
          "nameAm": "ስጋ ምግቦች",
          "items": [
            {
              "id": "item_1",
              "name": "Doro Wat",
              "nameAm": "ዶሮ ዋጥ",
              "slug": "doro-wat",
              "categoryId": "category_1",
              "price": 250,
              "currency": "ETB",
              "viewCount": 100,
              "averageRating": 4.5,
              "reviewIds": []
            }
          ]
        }
        ''';

        // Act
        final result = CategoryModel.fromJson(jsonString);

        // Assert
        expect(result.id, 'category_1');
        expect(result.tabId, 'tab_1');
        expect(result.name, 'Meat Dishes');
        expect(result.nameAm, 'ስጋ ምግቦች');
        expect(result.items.length, 1);
      });

      test('should handle malformed JSON gracefully', () {
        // Arrange
        const jsonString =
            '{"id": "test", "tabId": "tab_1"'; // Missing closing brace

        // Act & Assert
        expect(
          () => CategoryModel.fromJson(jsonString),
          throwsA(isA<FormatException>()),
        );
      });

      test('should handle empty JSON object', () {
        // Arrange
        const jsonString = '{}';

        // Act
        final result = CategoryModel.fromJson(jsonString);

        // Assert
        expect(result.id, '');
        expect(result.items, []);
      });
    });

    group('toJson', () {
      test('should return a JSON string containing the proper data', () {
        // Arrange
        final categoryWithItems = CategoryModel(
          id: 'category_1',
          tabId: 'tab_1',
          name: 'Meat Dishes',
          nameAm: 'ስጋ ምግቦች',
          items: [mockItemModel],
        );

        // Act
        final result = categoryWithItems.toJson();

        // Assert
        final decoded = json.decode(result);
        expect(decoded['id'], 'category_1');
        expect(decoded['tabId'], 'tab_1');
        expect(decoded['name'], 'Meat Dishes');
        expect(decoded['items'].length, 1);
      });

      test('should produce valid JSON that can be parsed back', () {
        // Arrange
        final originalCategory = CategoryModel(
          id: 'roundtrip_category',
          tabId: 'tab_1',
          name: 'Roundtrip Category',
          nameAm: 'የተሽከርካሪ ምድብ',
          items: [mockItemModel],
        );

        // Act
        final jsonString = originalCategory.toJson();
        final parsedCategory = CategoryModel.fromJson(jsonString);

        // Assert
        expect(parsedCategory.id, originalCategory.id);
        expect(parsedCategory.tabId, originalCategory.tabId);
        expect(parsedCategory.name, originalCategory.name);
        expect(parsedCategory.nameAm, originalCategory.nameAm);
        expect(parsedCategory.items.length, originalCategory.items.length);
      });
    });

    group('copyWith', () {
      test('should return a new instance with updated fields', () {
        // Arrange
        final originalCategory = CategoryModel(
          id: 'original_category',
          tabId: 'tab_1',
          name: 'Original Category',
          nameAm: 'ኦሪጀናል ምድብ',
          items: [mockItemModel],
        );

        // Act
        final result = originalCategory.copyWith(
          name: 'Updated Category',
          nameAm: 'የተሻሻለ ምድብ',
        );

        // Assert
        expect(result.id, originalCategory.id);
        expect(result.tabId, originalCategory.tabId);
        expect(result.name, 'Updated Category');
        expect(result.nameAm, 'የተሻሻለ ምድብ');
        expect(result.items, originalCategory.items);
      });

      test('should return the same instance when no fields are updated', () {
        // Arrange
        final originalCategory = const CategoryModel(
          id: 'same_category',
          tabId: 'tab_1',
          name: 'Same Category',
          nameAm: 'ተመሳሳይ ምድብ',
          items: [],
        );

        // Act
        final result = originalCategory.copyWith();

        // Assert
        expect(result, equals(originalCategory));
      });

      test('should handle items list updates in copyWith', () {
        // Arrange
        final originalCategory = CategoryModel(
          id: 'items_category',
          tabId: 'tab_1',
          name: 'Items Category',
          nameAm: 'ንጥሎች ምድብ',
          items: [mockItemModel],
        );

        // Act
        final result = originalCategory.copyWith(
          items: [mockItemModel, mockItemModel2],
        );

        // Assert
        expect(result.items.length, 2);
        expect(result.items[0].name, 'Doro Wat');
        expect(result.items[1].name, 'Tibs');
      });
    });

    group('toEntity', () {
      test(
        'should return the same instance since CategoryModel extends Category',
        () {
          // Arrange
          final categoryModel = const CategoryModel(
            id: 'entity_category',
            tabId: 'tab_1',
            name: 'Entity Category',
            nameAm: 'እንትነት ምድብ',
            items: [],
          );

          // Act
          final result = categoryModel.toEntity();

          // Assert
          expect(result, equals(categoryModel));
          expect(result, isA<CategoryModel>());
        },
      );
    });

    group('stringify', () {
      test('should return true for stringify', () {
        // Assert
        expect(tCategoryModel.stringify, true);
      });
    });

    group('equality and hashCode', () {
      test('should support equality comparison', () {
        // Arrange
        final category1 = CategoryModel(
          id: 'test_category_1',
          tabId: 'tab_1',
          name: 'Test Category',
          nameAm: 'የምክክር ምድብ',
          items: [mockItemModel],
        );
        final category2 = CategoryModel(
          id: 'test_category_1',
          tabId: 'tab_1',
          name: 'Test Category',
          nameAm: 'የምክክር ምድብ',
          items: [mockItemModel],
        );
        final category3 = const CategoryModel(
          id: 'test_category_2',
          tabId: 'tab_1',
          name: 'Different Category',
          nameAm: 'የተለየ ምድብ',
          items: [],
        );

        // Assert
        expect(category1, equals(category2));
        expect(category1, isNot(equals(category3)));
      });

      test('should support hashCode generation', () {
        // Arrange
        final category1 = const CategoryModel(
          id: 'hash_category',
          tabId: 'tab_1',
          name: 'Hash Category',
          nameAm: 'ሃሽ ምድብ',
          items: [],
        );
        final category2 = const CategoryModel(
          id: 'hash_category',
          tabId: 'tab_1',
          name: 'Hash Category',
          nameAm: 'ሃሽ ምድብ',
          items: [],
        );

        // Assert
        expect(category1.hashCode, equals(category2.hashCode));
      });
    });

    group('edge cases', () {
      test('should handle special characters in category data', () {
        // Arrange
        final jsonMap = {
          'id': r'special_category_@#$%',
          'tabId': 'tab_special_123',
          'name': r'Special Category @#$%',
          'nameAm': r'ልዩ ምድብ @#$%',
          'items': [
            {
              'id': 'item_special',
              'name': r'Special Item @#$%',
              'nameAm': r'ልዩ ንጥል @#$%',
              'slug': 'special-item',
              'categoryId': r'special_category_@#$%',
              'price': 300,
              'currency': 'ETB',
              'viewCount': 50,
              'averageRating': 4.0,
              'reviewIds': [],
            },
          ],
        };

        // Act
        final result = CategoryModel.fromMap(jsonMap);
        final jsonResult = result.toJson();
        final parsedBack = CategoryModel.fromJson(jsonResult);

        // Assert
        expect(result.id, contains('@'));
        expect(result.name, contains('#'));
        expect(result.nameAm, contains('ልዩ'));
        expect(result.items[0].name, contains(r'$'));
        expect(parsedBack, equals(result));
      });

      test('should handle null items list', () {
        // Arrange
        final jsonMap = {
          'id': 'null_items_category',
          'tabId': 'tab_1',
          'name': 'Null Items Category',
          'nameAm': 'ኑል ንጥሎች ምድብ',
          'items': null,
        };

        // Act
        final result = CategoryModel.fromMap(jsonMap);

        // Assert
        expect(result.items, []);
        expect(result.items.length, 0);
      });
    });
  });
}
