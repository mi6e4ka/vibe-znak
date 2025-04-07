import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/meal.dart';
import '../services/meal_service.dart';
import '../widgets/theme_selector.dart';

class TinderMealScreen extends StatefulWidget {
  const TinderMealScreen({super.key});

  @override
  State<TinderMealScreen> createState() => _TinderMealScreenState();
}

class _TinderMealScreenState extends State<TinderMealScreen> {
  final MealService _mealService = MealService();
  final CardSwiperController _cardController = CardSwiperController();
  final List<Meal> _meals = [];
  final List<Meal> _likedMeals = [];
  bool _isLoading = true;
  String _errorMessage = '';
  bool _isDebugMode = true; // Включаем режим отладки

  void _debugLog(String message) {
    if (_isDebugMode) {
      print('DEBUG: $message');
    }
  }

  @override
  void initState() {
    super.initState();
    _debugLog('Инициализация экрана TinderMeal');
    _loadMeals();
  }

  Future<void> _loadMeals() async {
    _debugLog('Начало загрузки блюд');
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      _debugLog('Вызов API для получения случайных блюд');
      // Уменьшаем количество блюд до 5 для более быстрой загрузки
      final meals = await _mealService.getRandomMeals(5);
      _debugLog('Получено ${meals.length} блюд');
      
      // Проверяем, все ли блюда загружены корректно
      if (meals.isEmpty) {
        _debugLog('Список блюд пуст!');
        setState(() {
          _errorMessage = 'Не удалось загрузить блюда. Пожалуйста, попробуйте снова.';
          _isLoading = false;
        });
        return;
      }
      
      setState(() {
        _meals.clear();
        _meals.addAll(meals);
        _isLoading = false;
      });
      _debugLog('Блюда успешно загружены и отображены');
    } catch (e) {
      _debugLog('Ошибка при загрузке блюд: $e');
      setState(() {
        _errorMessage = 'Ошибка при загрузке блюд: $e';
        _isLoading = false;
      });
    }
  }

  Future<bool> _onSwipe(int previousIndex, int? targetIndex, CardSwiperDirection direction) {
    _debugLog('Свайп карточки с индексом $previousIndex в направлении ${direction.name}');
    if (direction == CardSwiperDirection.right) {
      // Лайк - добавляем в избранное
      setState(() {
        _likedMeals.add(_meals[previousIndex]);
      });
      _debugLog('Блюдо добавлено в избранное: ${_meals[previousIndex].name}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Добавлено в избранное: ${_meals[previousIndex].name}'),
          duration: const Duration(seconds: 1),
        ),
      );
    }

    // Если осталось мало карточек, загружаем еще
    if (targetIndex != null && _meals.length - targetIndex <= 3) {
      _debugLog('Осталось мало карточек (${_meals.length - targetIndex}), загружаем еще');
      _loadMoreMeals();
    }
    
    return Future.value(true);
  }

  Future<void> _loadMoreMeals() async {
    _debugLog('Начало загрузки дополнительных блюд');
    try {
      // Уменьшаем количество дополнительных блюд
      final newMeals = await _mealService.getRandomMeals(3);
      _debugLog('Получено ${newMeals.length} дополнительных блюд');
      
      // Проверяем, были ли успешно загружены блюда
      if (newMeals.isEmpty) {
        _debugLog('Дополнительные блюда не были загружены');
        return;
      }
      
      setState(() {
        _meals.addAll(newMeals);
      });
      _debugLog('Дополнительные блюда добавлены, всего: ${_meals.length}');
    } catch (e) {
      _debugLog('Ошибка при загрузке дополнительных блюд: $e');
    }
  }

  @override
  void dispose() {
    _debugLog('Уничтожение виджета TinderMeal');
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _debugLog('Отрисовка интерфейса, состояние: isLoading=$_isLoading, errorMessage=${_errorMessage.isNotEmpty}, meals=${_meals.length}');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('ОбедТиндер'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: _likedMeals.isNotEmpty,
              label: Text(_likedMeals.length.toString()),
              child: const Icon(Icons.favorite),
            ),
            onPressed: _likedMeals.isEmpty ? null : _showLikedMeals,
            tooltip: 'Понравившиеся блюда',
          ),
          // Добавляем кнопку для повторной загрузки
          IconButton(
            icon: _isLoading 
                ? const SizedBox(
                  width: 20, 
                  height: 20, 
                  child: CircularProgressIndicator(strokeWidth: 2)
                ) 
                : const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadMeals,
            tooltip: 'Обновить',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Загрузка блюд...'),
                ],
              ),
            )
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage, textAlign: TextAlign.center),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _loadMeals,
                        child: const Text('Попробовать снова'),
                      ),
                    ],
                  ),
                )
              : _meals.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Нет доступных блюд'),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _loadMeals,
                            child: const Text('Загрузить блюда'),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: CardSwiper(
                              controller: _cardController,
                              cardsCount: _meals.length,
                              onSwipe: _onSwipe,
                              numberOfCardsDisplayed: 3,
                              backCardOffset: const Offset(20, 20),
                              padding: const EdgeInsets.all(24.0),
                              cardBuilder: (context, index, percentThresholdX, percentThresholdY) => 
                                _buildMealCard(_meals[index], percentThresholdX.toDouble()),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildCircleButton(
                                Icons.close, 
                                Colors.red, 
                                () => _cardController.swipe(),
                                'Не нравится',
                              ),
                              _buildCircleButton(
                                Icons.favorite, 
                                Colors.green, 
                                () => _cardController.swipe(),
                                'Нравится',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
    );
  }

  Widget _buildCircleButton(
      IconData icon, Color color, VoidCallback onPressed, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(16),
          backgroundColor: color,
        ),
        child: Icon(icon, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _buildMealCard(Meal meal, double percentThresholdX) {
    // Определяем направление свайпа для визуального отображения
    final bool isSwipingRight = percentThresholdX > 0;
    final double opacityFactor = percentThresholdX.abs() * 0.9; // Непрозрачность индикатора
    // Проверяем, что значение opacityFactor валидно (между 0.0 и 1.0)
    final double safeOpacityFactor = opacityFactor.clamp(0.0, 1.0);
    
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Основное содержимое карточки
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Изображение блюда
                    CachedNetworkImage(
                      imageUrl: meal.imageUrl,
                      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                      fit: BoxFit.cover,
                    ),
                    // Градиент для лучшей читаемости текста
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Название блюда поверх изображения
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Text(
                        meal.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: const Offset(1, 1),
                              blurRadius: 3,
                              color: Colors.black.withOpacity(0.6),
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Категория и регион
                      Wrap(
                        spacing: 8,
                        children: [
                          Chip(
                            label: Text(meal.category),
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                            visualDensity: VisualDensity.compact,
                            labelStyle: const TextStyle(fontSize: 12),
                          ),
                          Chip(
                            label: Text(meal.area),
                            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                            visualDensity: VisualDensity.compact,
                            labelStyle: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Заголовок для ингредиентов
                      Row(
                        children: [
                          Icon(
                            Icons.egg_alt,
                            size: 16,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Основные ингредиенты:',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Список ингредиентов (первые 3)
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: meal.ingredients.take(3).map((ingredient) {
                          return Chip(
                            label: Text(ingredient),
                            visualDensity: VisualDensity.compact,
                            labelStyle: const TextStyle(fontSize: 10),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 8),
                      // Кнопка для открытия подробностей
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => _showMealDetails(meal),
                          icon: const Icon(Icons.restaurant_menu, size: 16),
                          label: const Text('Подробнее'),
                          style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // Индикаторы свайпа (нравится/не нравится)
          if (percentThresholdX != 0 && percentThresholdX.abs() > 0.01) ...[
            // Индикатор лайка (справа)
            if (isSwipingRight)
              Positioned(
                top: 20,
                left: 20,
                child: Transform.rotate(
                  angle: -0.2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(safeOpacityFactor),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Text(
                      'НРАВИТСЯ',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16 + safeOpacityFactor * 4,
                      ),
                    ),
                  ),
                ),
              ),
              
            // Индикатор дизлайка (слева)
            if (!isSwipingRight)
              Positioned(
                top: 20,
                right: 20,
                child: Transform.rotate(
                  angle: 0.2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(safeOpacityFactor),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Text(
                      'НЕ НРАВИТСЯ',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16 + safeOpacityFactor * 4,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  void _showLikedMeals() {
    _debugLog('Открытие списка избранных блюд (${_likedMeals.length})');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) => Column(
            children: [
              // Индикатор для drag
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.favorite, color: Colors.red),
                    const SizedBox(width: 12),
                    Text(
                      'Понравившиеся блюда',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
              if (_likedMeals.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.restaurant,
                          size: 70,
                          color: Theme.of(context).disabledColor,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Пока нет понравившихся блюд',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        const Text('Свайпните вправо, чтобы добавить блюдо в избранное'),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: _likedMeals.length,
                    itemBuilder: (context, index) {
                      final meal = _likedMeals[_likedMeals.length - 1 - index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(8),
                          leading: CircleAvatar(
                            radius: 30,
                            backgroundImage: CachedNetworkImageProvider(meal.imageUrl),
                          ),
                          title: Text(
                            meal.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('${meal.category} • ${meal.area}'),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 4,
                                children: meal.ingredients.take(2).map((ingredient) => 
                                  Chip(
                                    label: Text(
                                      ingredient, 
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                    visualDensity: VisualDensity.compact,
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    padding: EdgeInsets.zero,
                                  )
                                ).toList(),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.info_outline),
                            onPressed: () => _showMealDetails(meal),
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMealDetails(Meal meal) {
    _debugLog('Отображение детальной информации о блюде: ${meal.name}');
    final screenWidth = MediaQuery.of(context).size.width;
    final maxDialogWidth = screenWidth * 0.9;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: maxDialogWidth,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Изображение с наложенным градиентом и названием
                  Stack(
                    children: [
                      // Изображение блюда
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: CachedNetworkImage(
                          imageUrl: meal.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                        ),
                      ),
                      // Градиент для текста
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Название блюда
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Text(
                          meal.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      // Кнопка закрытия
                      Positioned(
                        top: 8,
                        right: 8,
                        child: CircleAvatar(
                          backgroundColor: Colors.black.withOpacity(0.5),
                          radius: 16,
                          child: IconButton(
                            icon: const Icon(Icons.close, size: 16, color: Colors.white),
                            onPressed: () => Navigator.of(context).pop(),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Информация о категории и кухне
                        Row(
                          children: [
                            Expanded(
                              child: Card(
                                color: Theme.of(context).colorScheme.primaryContainer,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                  child: Column(
                                    children: [
                                      const Icon(Icons.category),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'Категория',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      Text(
                                        meal.category,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Card(
                                color: Theme.of(context).colorScheme.secondaryContainer,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                  child: Column(
                                    children: [
                                      const Icon(Icons.public),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'Кухня',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      Text(
                                        meal.area,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        _buildDetailSection(
                          title: 'Ингредиенты',
                          icon: Icons.egg_alt,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(
                              meal.ingredients.length,
                              (i) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      margin: const EdgeInsets.only(top: 6, right: 8),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text('${meal.measures[i]} ${meal.ingredients[i]}'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        _buildDetailSection(
                          title: 'Инструкция',
                          icon: Icons.menu_book,
                          child: Text(meal.instructions),
                        ),
                        
                        const SizedBox(height: 24),
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.check),
                            label: const Text('Понятно'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildDetailSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const Divider(),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
} 