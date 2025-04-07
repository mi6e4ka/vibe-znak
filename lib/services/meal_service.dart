import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/meal.dart';

class MealService {
  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';
  static const int _apiTimeout = 15; // таймаут в секундах
  bool _isDebugMode = true; // Включаем режим отладки
  
  void _debugLog(String message) {
    if (_isDebugMode) {
      print('API DEBUG: $message');
    }
  }

  // Получить случайное блюдо
  Future<Meal> getRandomMeal() async {
    _debugLog('Запрос случайного блюда');
    try {
      final response = await http.get(Uri.parse('$_baseUrl/random.php'))
        .timeout(Duration(seconds: _apiTimeout));
      
      _debugLog('Ответ API (статус: ${response.statusCode}): ${response.body.substring(0, 100)}...');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['meals'] != null && data['meals'].isNotEmpty) {
          _debugLog('Блюдо успешно получено');
          return Meal.fromJson(data['meals'][0]);
        }
        _debugLog('Ошибка: данные блюда не найдены в ответе API');
        throw Exception('Данные блюда не найдены');
      } else {
        _debugLog('Ошибка API: ${response.statusCode}');
        throw Exception('Ошибка при получении случайного блюда: ${response.statusCode}');
      }
    } on TimeoutException {
      _debugLog('Ошибка: таймаут запроса API');
      throw Exception('Превышено время ожидания запроса. Проверьте подключение к интернету');
    } catch (e) {
      _debugLog('Ошибка при получении случайного блюда: $e');
      throw Exception('Ошибка при получении блюда: $e');
    }
  }

  // Получить несколько случайных блюд
  Future<List<Meal>> getRandomMeals(int count) async {
    _debugLog('Запрос $count случайных блюд');
    List<Meal> meals = [];
    
    // Ограничиваем количество блюд для предотвращения проблем
    int safeCount = count > 10 ? 10 : count;
    
    // Используем Promise.all подход для параллельной загрузки
    List<Future<void>> futures = [];
    
    for (int i = 0; i < safeCount; i++) {
      futures.add(
        getRandomMeal().then((meal) {
          // Проверяем, что такого блюда еще нет в списке (избегаем дубликатов)
          if (!meals.any((m) => m.id == meal.id)) {
            meals.add(meal);
            _debugLog('Добавлено блюдо ${meal.name} (${meals.length}/$safeCount)');
          } else {
            _debugLog('Дубликат блюда: ${meal.name}, пропускаем');
          }
        }).catchError((e) {
          _debugLog('Ошибка при получении блюда #$i: $e');
          // Продолжаем работу, даже если одно из блюд не загрузилось
        })
      );
    }
    
    // Ожидаем завершения всех запросов с лимитом по времени
    try {
      await Future.wait(futures)
        .timeout(Duration(seconds: _apiTimeout * 2));
    } catch (e) {
      _debugLog('Ошибка при загрузке нескольких блюд: $e');
      // Возвращаем те блюда, которые успели загрузиться
    }
    
    _debugLog('Загружено ${meals.length} из $safeCount блюд');
    return meals;
  }

  // Поиск блюд по названию
  Future<List<Meal>> searchMealsByName(String name) async {
    _debugLog('Поиск блюд по названию: $name');
    try {
      final response = await http.get(Uri.parse('$_baseUrl/search.php?s=$name'))
        .timeout(Duration(seconds: _apiTimeout));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['meals'] != null) {
          final meals = List<Meal>.from(data['meals'].map((meal) => Meal.fromJson(meal)));
          _debugLog('Найдено ${meals.length} блюд');
          return meals;
        }
        _debugLog('По запросу ничего не найдено');
        return [];
      } else {
        _debugLog('Ошибка API при поиске: ${response.statusCode}');
        throw Exception('Ошибка при поиске блюд: ${response.statusCode}');
      }
    } on TimeoutException {
      _debugLog('Таймаут при поиске');
      throw Exception('Превышено время ожидания запроса. Проверьте подключение к интернету');
    } catch (e) {
      _debugLog('Ошибка при поиске: $e');
      throw Exception('Ошибка при поиске блюд: $e');
    }
  }

  // Получить список категорий
  Future<List<String>> getCategories() async {
    _debugLog('Запрос списка категорий');
    try {
      final response = await http.get(Uri.parse('$_baseUrl/list.php?c=list'))
        .timeout(Duration(seconds: _apiTimeout));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['meals'] != null) {
          final categories = List<String>.from(data['meals'].map((category) => category['strCategory']));
          _debugLog('Получено ${categories.length} категорий');
          return categories;
        }
        return [];
      } else {
        _debugLog('Ошибка API при запросе категорий: ${response.statusCode}');
        throw Exception('Ошибка при получении категорий: ${response.statusCode}');
      }
    } catch (e) {
      _debugLog('Ошибка при запросе категорий: $e');
      throw Exception('Ошибка при получении категорий: $e');
    }
  }

  // Получить блюда по категории
  Future<List<Meal>> getMealsByCategory(String category) async {
    _debugLog('Запрос блюд по категории: $category');
    try {
      final response = await http.get(Uri.parse('$_baseUrl/filter.php?c=$category'))
        .timeout(Duration(seconds: _apiTimeout));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['meals'] != null) {
          _debugLog('Получены базовые данные для ${data['meals'].length} блюд');
          
          // Ограничиваем количество блюд для детальной загрузки
          final int maxDetailedItems = 5;
          final int itemsToLoad = data['meals'].length > maxDetailedItems 
              ? maxDetailedItems 
              : data['meals'].length;
          
          List<Meal> basicMeals = [];
          for (var i = 0; i < itemsToLoad; i++) {
            var mealData = data['meals'][i];
            try {
              _debugLog('Загрузка полной информации о блюде ${mealData['strMeal']}');
              Meal fullMeal = await getMealById(mealData['idMeal']);
              basicMeals.add(fullMeal);
              _debugLog('Успешно загружена полная информация');
            } catch (e) {
              _debugLog('Ошибка при получении полной информации о блюде: $e');
            }
          }
          return basicMeals;
        }
        return [];
      } else {
        _debugLog('Ошибка API при запросе блюд категории: ${response.statusCode}');
        throw Exception('Ошибка при получении блюд по категории: ${response.statusCode}');
      }
    } catch (e) {
      _debugLog('Ошибка при запросе блюд категории: $e');
      throw Exception('Ошибка при получении блюд по категории: $e');
    }
  }

  // Получить блюдо по ID
  Future<Meal> getMealById(String id) async {
    _debugLog('Запрос блюда по ID: $id');
    try {
      final response = await http.get(Uri.parse('$_baseUrl/lookup.php?i=$id'))
        .timeout(Duration(seconds: _apiTimeout));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['meals'] != null && data['meals'].isNotEmpty) {
          _debugLog('Блюдо успешно получено');
          return Meal.fromJson(data['meals'][0]);
        }
        _debugLog('Блюдо с ID $id не найдено');
        throw Exception('Блюдо с ID $id не найдено');
      } else {
        _debugLog('Ошибка API при запросе блюда: ${response.statusCode}');
        throw Exception('Ошибка при получении блюда по ID: ${response.statusCode}');
      }
    } catch (e) {
      _debugLog('Ошибка при запросе блюда по ID: $e');
      throw Exception('Ошибка при получении блюда по ID: $e');
    }
  }
} 