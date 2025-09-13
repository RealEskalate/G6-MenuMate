import 'dart:convert';

import '../../domain/entities/nutrition.dart';

class NutritionModel extends Nutrition {
  NutritionModel({
    required super.calories,
    required super.protein,
    required super.carbs,
    required super.fat,
  });

  factory NutritionModel.fromMap(Map<String, dynamic> data) => NutritionModel(
        calories:
            (data['calories'] ?? data['calories_kcal'] ?? data['cal'] ?? '')
                .toString(),
        protein: (data['protein'] ?? data['proteins'] ?? '').toString(),
        carbs: (data['carbs'] ?? data['carbohydrates'] ?? data['carb'] ?? '')
            .toString(),
        fat: (data['fat'] ?? data['fats'] ?? '').toString(),
      );

  Map<String, dynamic> toMap() => {
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
      };

  factory NutritionModel.fromJson(String data) {
    return NutritionModel.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  String toJson() => json.encode(toMap());

  NutritionModel copyWith({
    String? calories,
    String? protein,
    String? carbs,
    String? fat,
  }) {
    return NutritionModel(
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
    );
  }

  Nutrition toEntity() => this;

  factory NutritionModel.fromEntity(Nutrition entity) => NutritionModel(
        calories: entity.calories,
        protein: entity.protein,
        carbs: entity.carbs,
        fat: entity.fat,
      );
}
