class Meal {
  final String id;
  final String name;
  final String category;
  final String area;
  final String instructions;
  final String imageUrl;
  final String tags;
  final String youtubeUrl;
  final List<String> ingredients;
  final List<String> measures;
  bool isFavorite;

  Meal({
    required this.id,
    required this.name,
    required this.category,
    required this.area,
    required this.instructions,
    required this.imageUrl,
    required this.tags,
    required this.youtubeUrl,
    required this.ingredients,
    required this.measures,
    this.isFavorite = false,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    // TheMealDB API имеет ингредиенты и меры в виде strIngredient1, strIngredient2...
    // Собираем их в списки
    List<String> ingredients = [];
    List<String> measures = [];

    for (int i = 1; i <= 20; i++) {
      String? ingredient = json['strIngredient$i'];
      String? measure = json['strMeasure$i'];

      if (ingredient != null && ingredient.trim().isNotEmpty) {
        ingredients.add(ingredient);
        measures.add(measure?.trim() ?? '');
      }
    }

    return Meal(
      id: json['idMeal'] ?? '',
      name: json['strMeal'] ?? '',
      category: json['strCategory'] ?? '',
      area: json['strArea'] ?? '',
      instructions: json['strInstructions'] ?? '',
      imageUrl: json['strMealThumb'] ?? '',
      tags: json['strTags'] ?? '',
      youtubeUrl: json['strYoutube'] ?? '',
      ingredients: ingredients,
      measures: measures,
    );
  }

  Meal copyWith({
    String? id,
    String? name,
    String? category,
    String? area,
    String? instructions,
    String? imageUrl,
    String? tags,
    String? youtubeUrl,
    List<String>? ingredients,
    List<String>? measures,
    bool? isFavorite,
  }) {
    return Meal(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      area: area ?? this.area,
      instructions: instructions ?? this.instructions,
      imageUrl: imageUrl ?? this.imageUrl,
      tags: tags ?? this.tags,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
      ingredients: ingredients ?? this.ingredients,
      measures: measures ?? this.measures,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
} 