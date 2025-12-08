class FoodItem {
  final int? id;
  final String name;
  final String? brand;
  final double kCal;
  final double protein;
  final double carbs;
  final double fats;
  final double fiber;
  final double sodium;
  final String servingUnit; // "g", "ml", "slice"
  final double servingQuantity; // e.g. 100g
  final bool isCustom;

  FoodItem({
    this.id,
    required this.name,
    this.brand,
    required this.kCal,
    required this.protein,
    required this.carbs,
    required this.fats,
    this.fiber = 0,
    this.sodium = 0,
    required this.servingUnit,
    required this.servingQuantity,
    this.isCustom = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'kcal': kCal,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'fiber': fiber,
      'sodium': sodium,
      'serving_unit': servingUnit,
      'serving_quantity': servingQuantity,
      'is_custom': isCustom ? 1 : 0,
    };
  }

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      id: map['id'],
      name: map['name'],
      brand: map['brand'],
      kCal: map['kcal'],
      protein: map['protein'],
      carbs: map['carbs'],
      fats: map['fats'],
      fiber: map['fiber'] ?? 0,
      sodium: map['sodium'] ?? 0,
      servingUnit: map['serving_unit'],
      servingQuantity: map['serving_quantity'],
      isCustom: map['is_custom'] == 1,
    );
  }
}

class MealLog {
  final int? id;
  final String date;
  final String mealType; // Breakfast, Lunch, Dinner, Snack
  final int foodId;
  final double servingMultiplier; // e.g. 1.5 servings
  final FoodItem? food; // Joined

  MealLog({
    this.id,
    required this.date,
    required this.mealType,
    required this.foodId,
    required this.servingMultiplier,
    this.food,
  });
  
  // Computed Macros
  double get totalKCal => (food?.kCal ?? 0) * servingMultiplier;
  double get totalProtein => (food?.protein ?? 0) * servingMultiplier;
  double get totalCarbs => (food?.carbs ?? 0) * servingMultiplier;
  double get totalFats => (food?.fats ?? 0) * servingMultiplier;
}
