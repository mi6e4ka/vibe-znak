class LunchOption {
  final String name;
  final String category;
  final bool isFavorite;

  LunchOption({
    required this.name,
    required this.category,
    this.isFavorite = false,
  });

  LunchOption copyWith({
    String? name,
    String? category,
    bool? isFavorite,
  }) {
    return LunchOption(
      name: name ?? this.name,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  static List<LunchOption> getSampleOptions() {
    return [
      LunchOption(name: 'Пицца', category: 'Фастфуд'),
      LunchOption(name: 'Суши', category: 'Азиатская'),
      LunchOption(name: 'Бургер', category: 'Фастфуд'),
      LunchOption(name: 'Паста', category: 'Итальянская'),
      LunchOption(name: 'Салат', category: 'Здоровая'),
      LunchOption(name: 'Рамен', category: 'Азиатская'),
      LunchOption(name: 'Шаурма', category: 'Фастфуд'),
      LunchOption(name: 'Стейк', category: 'Мясо'),
      LunchOption(name: 'Суп', category: 'Первое блюдо'),
      LunchOption(name: 'Плов', category: 'Восточная'),
    ];
  }
} 