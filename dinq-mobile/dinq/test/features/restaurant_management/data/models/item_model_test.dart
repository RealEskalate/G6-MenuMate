import 'dart:convert';

import 'package:dinq/features/restaurant_management/data/model/item_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const tItemModel = ItemModel(
    id: 'item_1',
    name: 'Doro Wat',
    nameAm: 'ዶሮ ዋጥ',
    slug: 'doro-wat',
    categoryId: 'category_1',
    description: 'Spicy chicken stew with berbere spice',
    descriptionAm: 'በበርበረ ቅመም የሆነ የዶሮ ዋጥ',
    image: ['https://example.com/doro1.jpg', 'https://example.com/doro2.jpg'],
    price: 250,
    currency: 'ETB',
    allergies: ['Spicy', 'Chicken'],
    userImages: ['user1.jpg', 'user2.jpg'],
    calories: 450,
    ingredients: ['Chicken', 'Berbere', 'Onion', 'Garlic'],
    ingredientsAm: ['ዶሮ', 'በርበረ', 'ሽንኩርት', 'ነጭ ሽንኩርት'],
    preparationTime: 45,
    howToEat: 'Eat with injera bread',
    howToEatAm: 'ከእንጀራ ጋር ብላ',
    viewCount: 1250,
    averageRating: 4.5,
    reviewIds: ['review_1', 'review_2'],
  );

  const tItemModelMinimal = ItemModel(
    id: 'item_minimal',
    name: 'Minimal Item',
    nameAm: 'አነስተኛ ንጥል',
    slug: 'minimal-item',
    categoryId: 'category_1',
    price: 100,
    currency: 'ETB',
    viewCount: 0,
    averageRating: 0.0,
    reviewIds: [],
  );

  group('ItemModel', () {
    test('should be a subclass of Item entity', () {
      // Assert
      expect(tItemModel, isA<ItemModel>());
    });

    group('fromMap', () {
      test('should return a valid model when all fields are present', () {
        // Arrange
        final Map<String, dynamic> jsonMap = {
          'id': 'item_1',
          'name': 'Doro Wat',
          'nameAm': 'ዶሮ ዋጥ',
          'slug': 'doro-wat',
          'categoryId': 'category_1',
          'description': 'Spicy chicken stew with berbere spice',
          'descriptionAm': 'በበርበረ ቅመም የሆነ የዶሮ ዋጥ',
          'image': [
            'https://example.com/doro1.jpg',
            'https://example.com/doro2.jpg',
          ],
          'price': 250,
          'currency': 'ETB',
          'allergies': ['Spicy', 'Chicken'],
          'userImages': ['user1.jpg', 'user2.jpg'],
          'calories': 450,
          'ingredients': ['Chicken', 'Berbere', 'Onion', 'Garlic'],
          'ingredientsAm': ['ዶሮ', 'በርበረ', 'ሽንኩርት', 'ነጭ ሽንኩርት'],
          'preparationTime': 45,
          'howToEat': 'Eat with injera bread',
          'howToEatAm': 'ከእንጀራ ጋር ብላ',
          'viewCount': 1250,
          'averageRating': 4.5,
          'reviewIds': ['review_1', 'review_2'],
        };

        // Act
        final result = ItemModel.fromMap(jsonMap);

        // Assert
        expect(result, equals(tItemModel));
      });

      test('should handle null values and provide defaults', () {
        // Arrange
        final Map<String, dynamic> jsonMap = {};

        // Act
        final result = ItemModel.fromMap(jsonMap);

        // Assert
        expect(result.id, '');
        expect(result.name, '');
        expect(result.nameAm, '');
        expect(result.slug, '');
        expect(result.categoryId, '');
        expect(result.description, null);
        expect(result.descriptionAm, null);
        expect(result.image, null);
        expect(result.price, 0);
        expect(result.currency, '');
        expect(result.allergies, null);
        expect(result.userImages, null);
        expect(result.calories, null);
        expect(result.ingredients, null);
        expect(result.ingredientsAm, null);
        expect(result.preparationTime, null);
        expect(result.howToEat, null);
        expect(result.howToEatAm, null);
        expect(result.viewCount, 0);
        expect(result.averageRating, 0.0);
        expect(result.reviewIds, []);
      });

      test('should handle partial data correctly', () {
        // Arrange
        final Map<String, dynamic> jsonMap = {
          'id': 'partial_1',
          'name': 'Partial Item',
          'nameAm': 'አንዳንድ ንጥል',
          'price': 150,
          'currency': 'ETB',
          'viewCount': 100,
          'averageRating': 3.5,
        };

        // Act
        final result = ItemModel.fromMap(jsonMap);

        // Assert
        expect(result.id, 'partial_1');
        expect(result.name, 'Partial Item');
        expect(result.nameAm, 'አንዳንድ ንጥል');
        expect(result.price, 150);
        expect(result.currency, 'ETB');
        expect(result.viewCount, 100);
        expect(result.averageRating, 3.5);
        expect(result.description, null);
        expect(result.image, null);
        expect(result.reviewIds, []);
      });

      test('should handle list parsing correctly', () {
        // Arrange
        final Map<String, dynamic> jsonMap = {
          'id': 'list_test',
          'name': 'List Test Item',
          'nameAm': 'ዝርዝር ምክክር ንጥል',
          'slug': 'list-test',
          'categoryId': 'category_1',
          'image': ['img1.jpg', 'img2.jpg', 'img3.jpg'],
          'allergies': ['Nuts', 'Dairy'],
          'ingredients': ['Ingredient 1', 'Ingredient 2'],
          'reviewIds': ['rev1', 'rev2', 'rev3'],
          'price': 200,
          'currency': 'ETB',
          'viewCount': 50,
          'averageRating': 4.0,
        };

        // Act
        final result = ItemModel.fromMap(jsonMap);

        // Assert
        expect(result.image, ['img1.jpg', 'img2.jpg', 'img3.jpg']);
        expect(result.allergies, ['Nuts', 'Dairy']);
        expect(result.ingredients, ['Ingredient 1', 'Ingredient 2']);
        expect(result.reviewIds, ['rev1', 'rev2', 'rev3']);
      });

      test('should handle empty lists', () {
        // Arrange
        final Map<String, dynamic> jsonMap = {
          'id': 'empty_lists',
          'name': 'Empty Lists Item',
          'nameAm': 'ባዶ ዝርዝሮች ንጥል',
          'slug': 'empty-lists',
          'categoryId': 'category_1',
          'image': [],
          'allergies': [],
          'ingredients': [],
          'reviewIds': [],
          'price': 100,
          'currency': 'ETB',
          'viewCount': 0,
          'averageRating': 0.0,
        };

        // Act
        final result = ItemModel.fromMap(jsonMap);

        // Assert
        expect(result.image, []);
        expect(result.allergies, []);
        expect(result.ingredients, []);
        expect(result.reviewIds, []);
      });

      test('should handle numeric conversion for averageRating', () {
        // Arrange
        final Map<String, dynamic> jsonMap = {
          'id': 'rating_test',
          'name': 'Rating Test',
          'nameAm': 'ደሞዝ ምክክር',
          'slug': 'rating-test',
          'categoryId': 'category_1',
          'averageRating': 4, // int instead of double
          'price': 100,
          'currency': 'ETB',
          'viewCount': 10,
          'reviewIds': [],
        };

        // Act
        final result = ItemModel.fromMap(jsonMap);

        // Assert
        expect(result.averageRating, 4.0);
      });
    });

    group('toMap', () {
      test('should return a JSON map containing the proper data', () {
        // Act
        final result = tItemModel.toMap();

        // Assert
        final expectedMap = {
          'id': 'item_1',
          'name': 'Doro Wat',
          'nameAm': 'ዶሮ ዋጥ',
          'slug': 'doro-wat',
          'categoryId': 'category_1',
          'description': 'Spicy chicken stew with berbere spice',
          'descriptionAm': 'በበርበረ ቅመም የሆነ የዶሮ ዋጥ',
          'image': [
            'https://example.com/doro1.jpg',
            'https://example.com/doro2.jpg',
          ],
          'price': 250,
          'currency': 'ETB',
          'allergies': ['Spicy', 'Chicken'],
          'userImages': ['user1.jpg', 'user2.jpg'],
          'calories': 450,
          'ingredients': ['Chicken', 'Berbere', 'Onion', 'Garlic'],
          'ingredientsAm': ['ዶሮ', 'በርበረ', 'ሽንኩርት', 'ነጭ ሽንኩርት'],
          'preparationTime': 45,
          'howToEat': 'Eat with injera bread',
          'howToEatAm': 'ከእንጀራ ጋር ብላ',
          'viewCount': 1250,
          'averageRating': 4.5,
          'reviewIds': ['review_1', 'review_2'],
        };
        expect(result, expectedMap);
      });

      test('should handle null values in toMap', () {
        // Act
        final result = tItemModelMinimal.toMap();

        // Assert
        expect(result['description'], null);
        expect(result['image'], null);
        expect(result['allergies'], null);
        expect(result['calories'], null);
        expect(result['ingredients'], null);
        expect(result['preparationTime'], null);
        expect(result['howToEat'], null);
      });
    });

    group('fromJson', () {
      test('should return a valid model from JSON string', () {
        // Arrange
        final jsonString = '''
        {
          "id": "item_1",
          "name": "Doro Wat",
          "nameAm": "ዶሮ ዋጥ",
          "slug": "doro-wat",
          "categoryId": "category_1",
          "description": "Spicy chicken stew with berbere spice",
          "price": 250,
          "currency": "ETB",
          "viewCount": 1250,
          "averageRating": 4.5,
          "reviewIds": ["review_1", "review_2"]
        }
        ''';

        // Act
        final result = ItemModel.fromJson(jsonString);

        // Assert
        expect(result.id, 'item_1');
        expect(result.name, 'Doro Wat');
        expect(result.nameAm, 'ዶሮ ዋጥ');
        expect(result.price, 250);
        expect(result.currency, 'ETB');
        expect(result.viewCount, 1250);
        expect(result.averageRating, 4.5);
        expect(result.reviewIds, ['review_1', 'review_2']);
      });

      test('should handle complex JSON with all fields', () {
        // Arrange
        final jsonString = '''
        {
          "id": "complex_item",
          "name": "Complex Item",
          "nameAm": "ከባድ ንጥል",
          "slug": "complex-item",
          "categoryId": "category_1",
          "description": "Complex description",
          "descriptionAm": "ከባድ መግለጫ",
          "image": ["img1.jpg", "img2.jpg"],
          "price": 300,
          "currency": "ETB",
          "allergies": ["Peanuts", "Gluten"],
          "userImages": ["user1.jpg"],
          "calories": 500,
          "ingredients": ["Ing1", "Ing2"],
          "ingredientsAm": ["ኢንግ1", "ኢንግ2"],
          "preparationTime": 60,
          "howToEat": "Eat carefully",
          "howToEatAm": "በጥንቃቄ ብላ",
          "viewCount": 200,
          "averageRating": 4.8,
          "reviewIds": ["r1", "r2", "r3"]
        }
        ''';

        // Act
        final result = ItemModel.fromJson(jsonString);

        // Assert
        expect(result.image, ['img1.jpg', 'img2.jpg']);
        expect(result.allergies, ['Peanuts', 'Gluten']);
        expect(result.ingredients, ['Ing1', 'Ing2']);
        expect(result.ingredientsAm, ['ኢንግ1', 'ኢንግ2']);
        expect(result.reviewIds, ['r1', 'r2', 'r3']);
      });
    });

    group('toJson', () {
      test('should return a JSON string containing the proper data', () {
        // Act
        final result = tItemModel.toJson();

        // Assert
        final decoded = json.decode(result);
        expect(decoded['id'], 'item_1');
        expect(decoded['name'], 'Doro Wat');
        expect(decoded['price'], 250);
        expect(decoded['averageRating'], 4.5);
        expect(decoded['reviewIds'], ['review_1', 'review_2']);
      });

      test('should produce valid JSON that can be parsed back', () {
        // Act
        final jsonString = tItemModel.toJson();
        final parsedModel = ItemModel.fromJson(jsonString);

        // Assert
        expect(parsedModel, equals(tItemModel));
      });
    });

    group('copyWith', () {
      test('should return a new instance with updated fields', () {
        // Act
        final result = tItemModel.copyWith(
          name: 'Updated Doro Wat',
          price: 300,
          averageRating: 4.8,
        );

        // Assert
        expect(result.id, tItemModel.id);
        expect(result.name, 'Updated Doro Wat');
        expect(result.price, 300);
        expect(result.averageRating, 4.8);
        expect(result.description, tItemModel.description);
      });

      test('should handle list updates in copyWith', () {
        // Act
        final result = tItemModel.copyWith(
          image: ['new_image.jpg'],
          allergies: ['New Allergy'],
          reviewIds: ['new_review'],
        );

        // Assert
        expect(result.image, ['new_image.jpg']);
        expect(result.allergies, ['New Allergy']);
        expect(result.reviewIds, ['new_review']);
      });
    });

    group('toEntity', () {
      test('should return the same instance since ItemModel extends Item', () {
        // Act
        final result = tItemModel.toEntity();

        // Assert
        expect(result, equals(tItemModel));
        expect(result, isA<ItemModel>());
      });
    });

    group('stringify', () {
      test('should return true for stringify', () {
        // Assert
        expect(tItemModel.stringify, true);
      });
    });

    group('equality and hashCode', () {
      test('should support equality comparison', () {
        // Arrange
        final model1 = ItemModel(
          id: 'test_1',
          name: 'Test Item',
          nameAm: 'የምክክር ንጥል',
          slug: 'test-item',
          categoryId: 'category_1',
          price: 100,
          currency: 'ETB',
          viewCount: 10,
          averageRating: 3.5,
          reviewIds: ['r1'],
        );
        final model2 = ItemModel(
          id: 'test_1',
          name: 'Test Item',
          nameAm: 'የምክክር ንጥል',
          slug: 'test-item',
          categoryId: 'category_1',
          price: 100,
          currency: 'ETB',
          viewCount: 10,
          averageRating: 3.5,
          reviewIds: ['r1'],
        );

        // Assert
        expect(model1, equals(model2));
      });

      test('should support hashCode generation', () {
        // Arrange
        final model1 = ItemModel(
          id: 'test_1',
          name: 'Test Item',
          nameAm: 'የምክክር ንጥል',
          slug: 'test-item',
          categoryId: 'category_1',
          price: 100,
          currency: 'ETB',
          viewCount: 10,
          averageRating: 3.5,
          reviewIds: ['r1'],
        );
        final model2 = ItemModel(
          id: 'test_1',
          name: 'Test Item',
          nameAm: 'የምክክር ንጥል',
          slug: 'test-item',
          categoryId: 'category_1',
          price: 100,
          currency: 'ETB',
          viewCount: 10,
          averageRating: 3.5,
          reviewIds: ['r1'],
        );

        // Assert
        expect(model1.hashCode, equals(model2.hashCode));
      });
    });
  });
}
