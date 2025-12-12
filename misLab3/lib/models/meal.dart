class Meal {
  final String idMeal;
  final String strMeal;
  final String? strCategory;
  final String? strArea;
  final String? strInstructions;
  final String? strMealThumb;
  final String? strYoutube;
  final List<Map<String, String>> ingredients;

  Meal({
    required this.idMeal,
    required this.strMeal,
    this.strCategory,
    this.strArea,
    this.strInstructions,
    this.strMealThumb,
    this.strYoutube,
    required this.ingredients,
  });

  factory Meal.fromShortJson(Map<String, dynamic> json) {
    return Meal(
      idMeal: json['idMeal'] ?? '',
      strMeal: json['strMeal'] ?? '',
      strCategory: null,
      strArea: null,
      strInstructions: null,
      strMealThumb: json['strMealThumb'],
      strYoutube: null,
      ingredients: [],
    );
  }

  factory Meal.fromJson(Map<String, dynamic> json) {
    final List<Map<String, String>> ingr = [];
    for (int i = 1; i <= 20; i++) {
      final ing = json['strIngredient$i'];
      final measure = json['strMeasure$i'];
      if (ing != null && (ing as String).trim().isNotEmpty) {
        ingr.add({ing.toString(): (measure ?? '').toString().trim()});
      }
    }
    return Meal(
      idMeal: json['idMeal'] ?? '',
      strMeal: json['strMeal'] ?? '',
      strCategory: json['strCategory'],
      strArea: json['strArea'],
      strInstructions: json['strInstructions'],
      strMealThumb: json['strMealThumb'],
      strYoutube: json['strYoutube'],
      ingredients: ingr,
    );
  }
}
