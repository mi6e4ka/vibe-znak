import 'package:flutter/material.dart';
import '../services/preferences_service.dart';

class AppThemeManager extends ChangeNotifier {
  int _currentThemeIndex;
  final PreferencesService _preferencesService;
  
  AppThemeManager({
    required int initialThemeIndex,
    required PreferencesService preferencesService,
  }) : _currentThemeIndex = initialThemeIndex,
       _preferencesService = preferencesService;
  
  // Получение текущей темы
  ThemeData get currentTheme => _getTheme(_currentThemeIndex);
  
  // Получение индекса текущей темы
  int get currentThemeIndex => _currentThemeIndex;
  
  // Установка темы по индексу
  Future<void> setTheme(int themeIndex) async {
    if (themeIndex != _currentThemeIndex) {
      _currentThemeIndex = themeIndex;
      await _preferencesService.saveThemeIndex(_currentThemeIndex);
      notifyListeners();
    }
  }
  
  // Получение темы по индексу
  ThemeData _getTheme(int index) {
    switch (index) {
      case 0:  // Светлая тема
        return _lightTheme;
      case 1:  // Темная тема
        return _darkTheme;
      case 2:  // Фуди тема (специализированная для приложения о еде)
        return _foodieTheme;
      default:
        return _lightTheme;
    }
  }
  
  // Светлая тема
  static final ThemeData _lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.orange,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 2,
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );
  
  // Темная тема
  static final ThemeData _darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.orange,
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 2,
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );
  
  // Фуди тема (специализированная для приложения о еде)
  static final ThemeData _foodieTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: Colors.deepOrange,
      onPrimary: Colors.white,
      secondary: Colors.green.shade700,
      onSecondary: Colors.white,
      error: Colors.red.shade700,
      onError: Colors.white,
      background: Colors.white,
      onBackground: Colors.brown.shade900,
      surface: Colors.white,
      onSurface: Colors.brown.shade900,
      primaryContainer: Colors.orange.shade100,
      onPrimaryContainer: Colors.brown.shade900,
      secondaryContainer: Colors.lightGreen.shade100,
      onSecondaryContainer: Colors.green.shade900,
    ),
    textTheme: TextTheme(
      titleLarge: TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.brown.shade900,
      ),
      titleMedium: TextStyle(
        fontWeight: FontWeight.w600,
        color: Colors.brown.shade800,
      ),
      bodyLarge: TextStyle(
        color: Colors.brown.shade800,
      ),
      bodyMedium: TextStyle(
        color: Colors.brown.shade700,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.deepOrange,
      foregroundColor: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.3),
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      shadowColor: Colors.black.withOpacity(0.2),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.orange.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    iconTheme: IconThemeData(
      color: Colors.deepOrange.shade400,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Colors.deepOrange,
      foregroundColor: Colors.white,
    ),
  );
} 