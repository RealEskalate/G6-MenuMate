import 'dart:convert';

import 'package:dinq/features/dinq/restaurant_management/data/model/restaurant_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const tRestaurantModel = RestaurantModel(
    id: 'restaurant_1',
    name: 'Mama\'s Kitchen',
    description: 'Authentic Ethiopian cuisine with modern twist',
    address: '123 Addis Ababa Street, Addis Ababa',
    phone: '+251911123456',
    email: 'contact@mamas-kitchen.et',
    image: 'https://example.com/restaurant.jpg',
    isActive: true,
  );

  const tRestaurantModelInactive = RestaurantModel(
    id: 'restaurant_2',
    name: 'Inactive Restaurant',
    description: 'This restaurant is currently inactive',
    address: '456 Bole Road, Addis Ababa',
    phone: '+251922654321',
    email: 'info@inactive.et',
    image: 'https://example.com/inactive.jpg',
    isActive: false,
  );

  group('RestaurantModel', () {
    test('should be a subclass of Restaurant entity', () {
      // Assert
      expect(tRestaurantModel, isA<RestaurantModel>());
    });

    group('fromMap', () {
      test('should return a valid model when all fields are present', () {
        // Arrange
        final Map<String, dynamic> jsonMap = {
          'id': 'restaurant_1',
          'name': 'Mama\'s Kitchen',
          'description': 'Authentic Ethiopian cuisine with modern twist',
          'address': '123 Addis Ababa Street, Addis Ababa',
          'phone': '+251911123456',
          'email': 'contact@mamas-kitchen.et',
          'image': 'https://example.com/restaurant.jpg',
          'isActive': true,
        };

        // Act
        final result = RestaurantModel.fromMap(jsonMap);

        // Assert
        expect(result, equals(tRestaurantModel));
      });

      test('should handle null values and provide defaults', () {
        // Arrange
        final Map<String, dynamic> jsonMap = {};

        // Act
        final result = RestaurantModel.fromMap(jsonMap);

        // Assert
        expect(result.id, '');
        expect(result.name, '');
        expect(result.description, '');
        expect(result.address, '');
        expect(result.phone, '');
        expect(result.email, '');
        expect(result.image, '');
        expect(result.isActive, false);
      });

      test('should handle partial data correctly', () {
        // Arrange
        final Map<String, dynamic> jsonMap = {
          'id': 'partial_1',
          'name': 'Partial Restaurant',
          'isActive': true,
        };

        // Act
        final result = RestaurantModel.fromMap(jsonMap);

        // Assert
        expect(result.id, 'partial_1');
        expect(result.name, 'Partial Restaurant');
        expect(result.description, '');
        expect(result.address, '');
        expect(result.phone, '');
        expect(result.email, '');
        expect(result.image, '');
        expect(result.isActive, true);
      });
    });

    group('toMap', () {
      test('should return a JSON map containing the proper data', () {
        // Act
        final result = tRestaurantModel.toMap();

        // Assert
        final expectedMap = {
          'id': 'restaurant_1',
          'name': 'Mama\'s Kitchen',
          'description': 'Authentic Ethiopian cuisine with modern twist',
          'address': '123 Addis Ababa Street, Addis Ababa',
          'phone': '+251911123456',
          'email': 'contact@mamas-kitchen.et',
          'image': 'https://example.com/restaurant.jpg',
          'isActive': true,
        };
        expect(result, expectedMap);
      });

      test('should handle inactive restaurant correctly', () {
        // Act
        final result = tRestaurantModelInactive.toMap();

        // Assert
        expect(result['isActive'], false);
        expect(result['name'], 'Inactive Restaurant');
      });
    });

    group('fromJson', () {
      test('should return a valid model from JSON string', () {
        // Arrange
        final jsonString = '''
        {
          "id": "restaurant_1",
          "name": "Mama's Kitchen",
          "description": "Authentic Ethiopian cuisine with modern twist",
          "address": "123 Addis Ababa Street, Addis Ababa",
          "phone": "+251911123456",
          "email": "contact@mamas-kitchen.et",
          "image": "https://example.com/restaurant.jpg",
          "isActive": true
        }
        ''';

        // Act
        final result = RestaurantModel.fromJson(jsonString);

        // Assert
        expect(result, equals(tRestaurantModel));
      });

      test('should handle malformed JSON gracefully', () {
        // Arrange
        const jsonString =
            '{"id": "test", "name": "Test Restaurant"'; // Missing closing brace

        // Act & Assert
        expect(
          () => RestaurantModel.fromJson(jsonString),
          throwsA(isA<FormatException>()),
        );
      });

      test('should handle empty JSON object', () {
        // Arrange
        const jsonString = '{}';

        // Act
        final result = RestaurantModel.fromJson(jsonString);

        // Assert
        expect(result.id, '');
        expect(result.name, '');
        expect(result.isActive, false);
      });
    });

    group('toJson', () {
      test('should return a JSON string containing the proper data', () {
        // Act
        final result = tRestaurantModel.toJson();

        // Assert
        final expectedJsonMap = {
          'id': 'restaurant_1',
          'name': 'Mama\'s Kitchen',
          'description': 'Authentic Ethiopian cuisine with modern twist',
          'address': '123 Addis Ababa Street, Addis Ababa',
          'phone': '+251911123456',
          'email': 'contact@mamas-kitchen.et',
          'image': 'https://example.com/restaurant.jpg',
          'isActive': true,
        };
        expect(json.decode(result), expectedJsonMap);
      });

      test('should produce valid JSON that can be parsed back', () {
        // Act
        final jsonString = tRestaurantModel.toJson();
        final parsedModel = RestaurantModel.fromJson(jsonString);

        // Assert
        expect(parsedModel, equals(tRestaurantModel));
      });
    });

    group('copyWith', () {
      test('should return a new instance with updated fields', () {
        // Act
        final result = tRestaurantModel.copyWith(
          name: 'Updated Kitchen',
          isActive: false,
        );

        // Assert
        expect(result.id, tRestaurantModel.id);
        expect(result.name, 'Updated Kitchen');
        expect(result.description, tRestaurantModel.description);
        expect(result.isActive, false);
      });

      test('should return the same instance when no fields are updated', () {
        // Act
        final result = tRestaurantModel.copyWith();

        // Assert
        expect(result, equals(tRestaurantModel));
      });

      test('should handle null values in copyWith', () {
        // Act
        final result = tRestaurantModel.copyWith(name: null, description: null);

        // Assert
        expect(result.name, tRestaurantModel.name);
        expect(result.description, tRestaurantModel.description);
      });
    });

    group('toEntity', () {
      test(
        'should return the same instance since RestaurantModel extends Restaurant',
        () {
          // Act
          final result = tRestaurantModel.toEntity();

          // Assert
          expect(result, equals(tRestaurantModel));
          expect(result, isA<RestaurantModel>());
        },
      );
    });

    group('stringify', () {
      test('should return true for stringify', () {
        // Assert
        expect(tRestaurantModel.stringify, true);
      });
    });

    group('equality and hashCode', () {
      test('should support equality comparison', () {
        // Arrange
        final model1 = const RestaurantModel(
          id: 'test_1',
          name: 'Test Restaurant',
          description: 'Test description',
          address: 'Test address',
          phone: '123456789',
          email: 'test@example.com',
          image: 'test.jpg',
          isActive: true,
        );
        final model2 = const RestaurantModel(
          id: 'test_1',
          name: 'Test Restaurant',
          description: 'Test description',
          address: 'Test address',
          phone: '123456789',
          email: 'test@example.com',
          image: 'test.jpg',
          isActive: true,
        );
        final model3 = const RestaurantModel(
          id: 'test_2',
          name: 'Different Restaurant',
          description: 'Different description',
          address: 'Different address',
          phone: '987654321',
          email: 'different@example.com',
          image: 'different.jpg',
          isActive: false,
        );

        // Assert
        expect(model1, equals(model2));
        expect(model1, isNot(equals(model3)));
      });

      test('should support hashCode generation', () {
        // Arrange
        final model1 = const RestaurantModel(
          id: 'test_1',
          name: 'Test Restaurant',
          description: 'Test description',
          address: 'Test address',
          phone: '123456789',
          email: 'test@example.com',
          image: 'test.jpg',
          isActive: true,
        );
        final model2 = const RestaurantModel(
          id: 'test_1',
          name: 'Test Restaurant',
          description: 'Test description',
          address: 'Test address',
          phone: '123456789',
          email: 'test@example.com',
          image: 'test.jpg',
          isActive: true,
        );

        // Assert
        expect(model1.hashCode, equals(model2.hashCode));
      });
    });

    group('edge cases', () {
      test('should handle special characters in strings', () {
        // Arrange
        final jsonMap = {
          'id': 'special_@#\$%',
          'name': 'Restaurant with @#% symbols',
          'description': 'Description with émojis 😀 and spëcial chärs',
          'address': '123 Ümlaut Straße, Addis Ababa',
          'phone': '+251-911-123-456',
          'email': 'contact@mamas-kitchen.co.uk',
          'image': 'https://example.com/image.jpg?param=value&other=test',
          'isActive': true,
        };

        // Act
        final result = RestaurantModel.fromMap(jsonMap);
        final jsonResult = result.toJson();
        final parsedBack = RestaurantModel.fromJson(jsonResult);

        // Assert
        expect(result.id, contains('@'));
        expect(result.name, contains('#'));
        expect(result.description, contains('😀'));
        expect(result.address, contains('Ü'));
        expect(result.email, contains('.co.uk'));
        expect(result.image, contains('?'));
        expect(parsedBack, equals(result));
      });
    });
  });
}
