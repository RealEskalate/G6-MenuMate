import 'dart:convert';

import 'package:dinq/features/restaurant_management/data/model/review_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final tReviewModel = ReviewModel(
    id: 'review_1',
    userId: 'user_1',
    userName: 'John Doe',
    userAvatar: 'https://example.com/avatar.jpg',
    rating: 4.5,
    comment: 'Excellent food and great service!',
    images: const [
      'https://example.com/review1.jpg',
      'https://example.com/review2.jpg',
    ],
    like: 25,
    disLike: 2,
    createdAt: DateTime.parse('2024-01-15T10:30:00Z'),
    itemId: 'item_1',
  );

  final tReviewModelWithNulls = ReviewModel(
    id: 'review_nulls',
    itemId: 'item_1',
    userId: 'user_nulls',
    userName: 'Null User',
    userAvatar: 'https://example.com/null.jpg',
    rating: null,
    comment: null,
    images: null,
    like: 10,
    disLike: 1,
    createdAt: DateTime.parse('2024-01-10T12:00:00Z'),
  );

  group('ReviewModel', () {
    test('should be a subclass of Review entity', () {
      // Assert
      expect(tReviewModel, isA<ReviewModel>());
    });

    group('fromMap', () {
      test('should return a valid model when all fields are present', () {
        // Arrange
        final Map<String, dynamic> jsonMap = {
          'id': 'review_1',
          'userId': 'user_1',
          'userName': 'John Doe',
          'userAvatar': 'https://example.com/avatar.jpg',
          'rating': 4.5,
          'comment': 'Excellent food and great service!',
          'images': [
            'https://example.com/review1.jpg',
            'https://example.com/review2.jpg',
          ],
          'like': 25,
          'disLike': 2,
          'createdAt': '2024-01-15T10:30:00Z',
        };

        // Act
        final result = ReviewModel.fromMap(jsonMap);

        // Assert
        expect(result.id, 'review_1');
        expect(result.userId, 'user_1');
        expect(result.userName, 'John Doe');
        expect(result.userAvatar, 'https://example.com/avatar.jpg');
        expect(result.rating, 4.5);
        expect(result.comment, 'Excellent food and great service!');
        expect(result.images, [
          'https://example.com/review1.jpg',
          'https://example.com/review2.jpg',
        ]);
        expect(result.like, 25);
        expect(result.disLike, 2);
        expect(result.createdAt, DateTime.parse('2024-01-15T10:30:00Z'));
      });

      test('should handle null values and provide defaults', () {
        // Arrange
        final Map<String, dynamic> jsonMap = {};

        // Act
        final result = ReviewModel.fromMap(jsonMap);

        // Assert
        expect(result.id, '');
        expect(result.userId, '');
        expect(result.userName, '');
        expect(result.userAvatar, '');
        expect(result.rating, null);
        expect(result.comment, null);
        expect(result.images, null);
        expect(result.like, 0);
        expect(result.disLike, 0);
        expect(result.createdAt, isA<DateTime>());
      });

      test('should handle partial data correctly', () {
        // Arrange
        final Map<String, dynamic> jsonMap = {
          'id': 'partial_review',
          'userId': 'user_1',
          'userName': 'Partial User',
          'like': 15,
          'disLike': 3,
        };

        // Act
        final result = ReviewModel.fromMap(jsonMap);

        // Assert
        expect(result.id, 'partial_review');
        expect(result.userId, 'user_1');
        expect(result.userName, 'Partial User');
        expect(result.userAvatar, '');
        expect(result.rating, null);
        expect(result.comment, null);
        expect(result.images, null);
        expect(result.like, 15);
        expect(result.disLike, 3);
        expect(result.createdAt, isA<DateTime>());
      });

      test('should handle empty images list', () {
        // Arrange
        final Map<String, dynamic> jsonMap = {
          'id': 'empty_images_review',
          'userId': 'user_1',
          'userName': 'Empty Images User',
          'userAvatar': 'https://example.com/avatar.jpg',
          'images': [],
          'like': 5,
          'disLike': 0,
          'createdAt': '2024-01-01T00:00:00Z',
        };

        // Act
        final result = ReviewModel.fromMap(jsonMap);

        // Assert
        expect(result.images, []);
        expect(result.images!.length, 0);
      });

      test('should handle multiple images', () {
        // Arrange
        final Map<String, dynamic> jsonMap = {
          'id': 'multi_images_review',
          'userId': 'user_1',
          'userName': 'Multi Images User',
          'userAvatar': 'https://example.com/avatar.jpg',
          'images': ['img1.jpg', 'img2.jpg', 'img3.jpg', 'img4.jpg'],
          'like': 20,
          'disLike': 1,
          'createdAt': '2024-01-05T15:45:00Z',
        };

        // Act
        final result = ReviewModel.fromMap(jsonMap);

        // Assert
        expect(result.images, ['img1.jpg', 'img2.jpg', 'img3.jpg', 'img4.jpg']);
        expect(result.images!.length, 4);
      });

      test('should handle numeric rating conversion', () {
        // Arrange
        final Map<String, dynamic> jsonMap = {
          'id': 'rating_test_review',
          'userId': 'user_1',
          'userName': 'Rating Test User',
          'userAvatar': 'https://example.com/avatar.jpg',
          'rating': 4, // int instead of double
          'like': 10,
          'disLike': 0,
          'createdAt': '2024-01-01T00:00:00Z',
        };

        // Act
        final result = ReviewModel.fromMap(jsonMap);

        // Assert
        expect(result.rating, 4.0);
      });

      test('should handle invalid createdAt gracefully', () {
        // Arrange
        final Map<String, dynamic> jsonMap = {
          'id': 'invalid_date_review',
          'userId': 'user_1',
          'userName': 'Invalid Date User',
          'userAvatar': 'https://example.com/avatar.jpg',
          'createdAt': 'invalid-date-format',
          'like': 5,
          'disLike': 0,
        };

        // Act & Assert
        expect(
          () => ReviewModel.fromMap(jsonMap),
          throwsA(isA<FormatException>()),
        );
      });

      test('should handle null createdAt with current time fallback', () {
        // Arrange
        final Map<String, dynamic> jsonMap = {
          'id': 'null_date_review',
          'userId': 'user_1',
          'userName': 'Null Date User',
          'userAvatar': 'https://example.com/avatar.jpg',
          'createdAt': null,
          'like': 5,
          'disLike': 0,
        };

        // Act
        final result = ReviewModel.fromMap(jsonMap);

        // Assert
        expect(result.createdAt, isA<DateTime>());
        expect(
          result.createdAt.isAfter(
            DateTime.now().subtract(Duration(seconds: 1)),
          ),
          true,
        );
      });
    });

    group('toMap', () {
      test('should return a JSON map containing the proper data', () {
        // Act
        final result = tReviewModel.toMap();

        // Assert
        final expectedMap = {
          'id': 'review_1',
          'itemId': 'item_1',
          'userId': 'user_1',
          'userName': 'John Doe',
          'userAvatar': 'https://example.com/avatar.jpg',
          'rating': 4.5,
          'comment': 'Excellent food and great service!',
          'images': [
            'https://example.com/review1.jpg',
            'https://example.com/review2.jpg',
          ],
          'like': 25,
          'disLike': 2,
          'createdAt': '2024-01-15T10:30:00.000Z',
        };
        expect(result, expectedMap);
      });

      test('should handle null values in toMap', () {
        // Act
        final result = tReviewModelWithNulls.toMap();

        // Assert
        expect(result['rating'], null);
        expect(result['comment'], null);
        expect(result['images'], null);
        expect(result['like'], 10);
        expect(result['disLike'], 1);
      });

      test('should handle empty images list in toMap', () {
        // Arrange
        final reviewWithEmptyImages = ReviewModel(
          id: 'empty_images_review',
          itemId: 'item_1',
          userId: 'user_1',
          userName: 'Empty Images User',
          userAvatar: 'https://example.com/avatar.jpg',
          images: const [],
          like: 5,
          disLike: 0,
          createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
        );

        // Act
        final result = reviewWithEmptyImages.toMap();

        // Assert
        expect(result['images'], []);
      });
    });

    group('fromJson', () {
      test('should return a valid model from JSON string', () {
        // Arrange
        final jsonString = '''
        {
          "id": "review_1",
          "userId": "user_1",
          "userName": "John Doe",
          "userAvatar": "https://example.com/avatar.jpg",
          "rating": 4.5,
          "comment": "Excellent food and great service!",
          "images": ["https://example.com/review1.jpg", "https://example.com/review2.jpg"],
          "like": 25,
          "disLike": 2,
          "createdAt": "2024-01-15T10:30:00Z"
        }
        ''';

        // Act
        final result = ReviewModel.fromJson(jsonString);

        // Assert
        expect(result.id, 'review_1');
        expect(result.userId, 'user_1');
        expect(result.userName, 'John Doe');
        expect(result.rating, 4.5);
        expect(result.comment, 'Excellent food and great service!');
        expect(result.images, [
          'https://example.com/review1.jpg',
          'https://example.com/review2.jpg',
        ]);
        expect(result.like, 25);
        expect(result.disLike, 2);
      });

      test('should handle malformed JSON gracefully', () {
        // Arrange
        const jsonString =
            '{"id": "test", "userId": "user_1"'; // Missing closing brace

        // Act & Assert
        expect(
          () => ReviewModel.fromJson(jsonString),
          throwsA(isA<FormatException>()),
        );
      });

      test('should handle empty JSON object', () {
        // Arrange
        const jsonString = '{}';

        // Act
        final result = ReviewModel.fromJson(jsonString);

        // Assert
        expect(result.id, '');
        expect(result.like, 0);
        expect(result.disLike, 0);
        expect(result.createdAt, isA<DateTime>());
      });

      test('should handle complex JSON with all fields', () {
        // Arrange
        final jsonString = '''
        {
          "id": "complex_review",
          "userId": "user_complex",
          "userName": "Complex User",
          "userAvatar": "https://example.com/complex.jpg",
          "rating": 4.8,
          "comment": "This is a very detailed review with lots of information about the food quality, service, and overall experience.",
          "images": ["img1.jpg", "img2.jpg", "img3.jpg"],
          "like": 150,
          "disLike": 5,
          "createdAt": "2024-02-20T14:30:45Z"
        }
        ''';

        // Act
        final result = ReviewModel.fromJson(jsonString);

        // Assert
        expect(result.rating, 4.8);
        expect(result.comment, contains('very detailed'));
        expect(result.images!.length, 3);
        expect(result.like, 150);
        expect(result.disLike, 5);
      });
    });

    group('toJson', () {
      test('should return a JSON string containing the proper data', () {
        // Act
        final result = tReviewModel.toJson();

        // Assert
        final decoded = json.decode(result);
        expect(decoded['id'], 'review_1');
        expect(decoded['userId'], 'user_1');
        expect(decoded['userName'], 'John Doe');
        expect(decoded['rating'], 4.5);
        expect(decoded['like'], 25);
        expect(decoded['disLike'], 2);
        expect(decoded['createdAt'], '2024-01-15T10:30:00.000Z');
      });

      test('should produce valid JSON that can be parsed back', () {
        // Act
        final jsonString = tReviewModel.toJson();
        final parsedModel = ReviewModel.fromJson(jsonString);

        // Assert
        expect(parsedModel, equals(tReviewModel));
      });
    });

    group('copyWith', () {
      test('should return a new instance with updated fields', () {
        // Act
        final result = tReviewModel.copyWith(
          userName: 'Updated User',
          rating: 5.0,
          like: 30,
        );

        // Assert
        expect(result.id, tReviewModel.id);
        expect(result.userId, tReviewModel.userId);
        expect(result.userName, 'Updated User');
        expect(result.rating, 5.0);
        expect(result.like, 30);
        expect(result.disLike, tReviewModel.disLike);
        expect(result.createdAt, tReviewModel.createdAt);
      });

      test('should return the same instance when no fields are updated', () {
        // Act
        final result = tReviewModel.copyWith();

        // Assert
        expect(result, equals(tReviewModel));
      });

      
      test('should handle DateTime updates in copyWith', () {
        // Arrange
        final newDate = DateTime.parse('2024-02-01T10:00:00Z');

        // Act
        final result = tReviewModel.copyWith(createdAt: newDate);

        // Assert
        expect(result.createdAt, newDate);
        expect(result.createdAt, isNot(tReviewModel.createdAt));
      });
    });

    group('toEntity', () {
      test(
        'should return the same instance since ReviewModel extends Review',
        () {
          // Act
          final result = tReviewModel.toEntity();

          // Assert
          expect(result, equals(tReviewModel));
          expect(result, isA<ReviewModel>());
        },
      );
    });

    group('stringify', () {
      test('should return true for stringify', () {
        // Assert
        expect(tReviewModel.stringify, true);
      });
    });

    group('equality and hashCode', () {
      test('should support equality comparison', () {
        // Arrange
        final review1 = ReviewModel(
          id: 'test_review_1',
          itemId: 'item_1',
          userId: 'user_1',
          userName: 'Test User',
          userAvatar: 'https://example.com/test.jpg',
          rating: 4.0,
          comment: 'Test comment',
          images: const ['test.jpg'],
          like: 10,
          disLike: 1,
          createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
        );
        final review2 = ReviewModel(
          id: 'test_review_1',
          itemId: 'item_1',
          userId: 'user_1',
          userName: 'Test User',
          userAvatar: 'https://example.com/test.jpg',
          rating: 4.0,
          comment: 'Test comment',
          images: const ['test.jpg'],
          like: 10,
          disLike: 1,
          createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
        );
        final review3 = ReviewModel(
          id: 'test_review_2',
          itemId: 'item_1',
          userId: 'user_2',
          userName: 'Different User',
          userAvatar: 'https://example.com/different.jpg',
          rating: 3.0,
          comment: 'Different comment',
          images: const [],
          like: 5,
          disLike: 0,
          createdAt: DateTime.parse('2024-01-02T00:00:00Z'),
        );

        // Assert
        expect(review1, equals(review2));
        expect(review1, isNot(equals(review3)));
      });

      test('should support hashCode generation', () {
        // Arrange
        final review1 = ReviewModel(
          id: 'hash_review',
          itemId: 'item_1',
          userId: 'user_1',
          userName: 'Hash User',
          userAvatar: 'https://example.com/hash.jpg',
          like: 15,
          disLike: 2,
          createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
        );
        final review2 = ReviewModel(
          id: 'hash_review',
          itemId: 'item_1',
          userId: 'user_1',
          userName: 'Hash User',
          userAvatar: 'https://example.com/hash.jpg',
          like: 15,
          disLike: 2,
          createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
        );

        // Assert
        expect(review1.hashCode, equals(review2.hashCode));
      });
    });

    group('edge cases', () {
      test('should handle special characters in review data', () {
        // Arrange
        final jsonMap = {
          'id': r'special_review_@#$%',
          'userId': 'user_special_123',
          'userName': r'Special User @#$%',
          'userAvatar': r'https://example.com/avatar@#$%.jpg',
          'rating': 4.5,
          'comment': r'Special comment with @#$% symbols and émojis 😀',
          'images': [r'img@#$%.jpg', r'img2@#$%.jpg'],
          'like': 25,
          'disLike': 2,
          'createdAt': '2024-01-15T10:30:00Z',
        };

        // Act
        final result = ReviewModel.fromMap(jsonMap);
        final jsonResult = result.toJson();
        final parsedBack = ReviewModel.fromJson(jsonResult);

        // Assert
        expect(result.id, contains('@'));
        expect(result.userName, contains('#'));
        expect(result.comment, contains('😀'));
        expect(result.images![0], contains(r'$'));
        expect(parsedBack, equals(result));
      });
      test('should handle extreme rating values', () {
        // Arrange
        final jsonMap = {
          'id': 'extreme_rating_review',
          'userId': 'user_extreme',
          'userName': 'Extreme Rating User',
          'userAvatar': 'https://example.com/extreme.jpg',
          'rating': 999999.999999,
          'like': 1000000,
          'disLike': 999999,
          'createdAt': '2024-01-01T00:00:00Z',
        };

        // Act
        final result = ReviewModel.fromMap(jsonMap);

        // Assert
        expect(result.rating, 999999.999999);
        expect(result.like, 1000000);
        expect(result.disLike, 999999);
      });

      test('should handle zero and negative values appropriately', () {
        // Arrange
        final jsonMap = {
          'id': 'zero_values_review',
          'userId': 'user_zero',
          'userName': 'Zero Values User',
          'userAvatar': 'https://example.com/zero.jpg',
          'rating': 0.0,
          'like': 0,
          'disLike': 0,
          'createdAt': '2024-01-01T00:00:00Z',
        };

        // Act
        final result = ReviewModel.fromMap(jsonMap);

        // Assert
        expect(result.rating, 0.0);
        expect(result.like, 0);
        expect(result.disLike, 0);
      });
    });
  });
}
