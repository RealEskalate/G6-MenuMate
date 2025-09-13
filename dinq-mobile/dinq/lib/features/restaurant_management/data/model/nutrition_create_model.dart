import 'dart:convert';

class NutritionCreateModel {
  final num? calories;
  final num? protein;
  final num? carbs;
  final num? fat;

  NutritionCreateModel({this.calories, this.protein, this.carbs, this.fat});

  factory NutritionCreateModel.fromEntity(dynamic entity) {
    // entity is expected to have string fields in domain; try to parse nums if possible
    num? tryParse(String? s) {
      if (s == null) return null;
      return num.tryParse(s);
    }

    return NutritionCreateModel(
      calories: entity?.calories is num
          ? entity.calories
          : tryParse(entity?.calories),
      protein:
          entity?.protein is num ? entity.protein : tryParse(entity?.protein),
      carbs: entity?.carbs is num ? entity.carbs : tryParse(entity?.carbs),
      fat: entity?.fat is num ? entity.fat : tryParse(entity?.fat),
    );
  }

  factory NutritionCreateModel.fromMap(Map<String, dynamic> map) =>
      NutritionCreateModel(
        calories: map['calories'] ?? map['calories_kcal'],
        protein: map['protein'],
        carbs: map['carbs'] ?? map['carbohydrates'],
        fat: map['fat'],
      );

  Map<String, dynamic> toMap() => {
        if (calories != null) 'calories': calories,
        if (protein != null) 'protein': protein,
        if (carbs != null) 'carbs': carbs,
        if (fat != null) 'fat': fat,
      };

  factory NutritionCreateModel.fromJson(String json) =>
      NutritionCreateModel.fromMap(jsonDecode(json) as Map<String, dynamic>);

  String toJson() => jsonEncode(toMap());
}

// avoid importing dart:convert at top-level for minimalism; JSON helpers use jsonDecode/jsonEncode
