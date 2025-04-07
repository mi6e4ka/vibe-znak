import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _themeKey = 'theme_index';

  // Сохранение индекса темы
  Future<void> saveThemeIndex(int themeIndex) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, themeIndex);
  }

  // Загрузка индекса темы (по умолчанию - светлая тема с индексом 0)
  Future<int> loadThemeIndex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_themeKey) ?? 0;
  }
} 