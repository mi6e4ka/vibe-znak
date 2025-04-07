import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import 'package:animate_do/animate_do.dart';

class ThemeSelector extends StatelessWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<AppThemeManager>(context);
    
    return PopupMenuButton(
      tooltip: 'Изменить тему',
      icon: const Icon(Icons.palette_outlined),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) => [
        _buildPopupMenuItem(
          context: context,
          title: 'Светлая тема',
          icon: Icons.light_mode,
          value: 0,
          currentThemeIndex: themeManager.currentThemeIndex,
          color: Colors.amber,
        ),
        _buildPopupMenuItem(
          context: context,
          title: 'Темная тема',
          icon: Icons.dark_mode,
          value: 1,
          currentThemeIndex: themeManager.currentThemeIndex,
          color: Colors.indigo,
        ),
        _buildPopupMenuItem(
          context: context,
          title: 'Foodie тема',
          icon: Icons.restaurant_menu,
          value: 2,
          currentThemeIndex: themeManager.currentThemeIndex,
          color: Colors.deepOrange,
        ),
      ],
      onSelected: (int themeIndex) {
        themeManager.setTheme(themeIndex);
        
        // Показываем Snackbar с информацией о смене темы
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Тема изменена'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {},
            ),
          ),
        );
      },
    );
  }

  PopupMenuItem<int> _buildPopupMenuItem({
    required BuildContext context,
    required String title,
    required IconData icon,
    required int value,
    required int currentThemeIndex,
    required Color color,
  }) {
    final isSelected = value == currentThemeIndex;
    
    return PopupMenuItem<int>(
      value: value,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const Spacer(),
          if (isSelected)
            FadeIn(
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }
} 