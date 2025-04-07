import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'models/lunch_option.dart';
import 'screens/history_screen.dart';
import 'screens/tinder_meal_screen.dart';
import 'theme/app_theme.dart';
import 'services/preferences_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Инициализируем сервис предпочтений
  final preferencesService = PreferencesService();
  // Загружаем сохраненную тему
  final themeIndex = await preferencesService.loadThemeIndex();
  
  runApp(MyApp(
    initialThemeIndex: themeIndex,
    preferencesService: preferencesService,
  ));
}

class MyApp extends StatelessWidget {
  final int initialThemeIndex;
  final PreferencesService preferencesService;
  
  const MyApp({
    super.key, 
    required this.initialThemeIndex,
    required this.preferencesService,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppThemeManager(
        initialThemeIndex: initialThemeIndex,
        preferencesService: preferencesService,
      ),
      child: Consumer<AppThemeManager>(
        builder: (context, themeManager, child) {
    return MaterialApp(
            title: 'ОбедРулетка',
            theme: themeManager.currentTheme,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const LunchRoulette(),
    const TinderMealScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<AppThemeManager>(context);
    
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 40,
                    child: Icon(
                      Icons.restaurant,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Меню приложения',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.casino),
              title: const Text('Рулетка еды'),
              selected: _currentIndex == 0,
              onTap: () {
                setState(() {
                  _currentIndex = 0;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.swipe),
              title: const Text('Свайп меню'),
              selected: _currentIndex == 1,
              onTap: () {
                setState(() {
                  _currentIndex = 1;
                });
                Navigator.pop(context);
              },
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Настройки',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.color_lens),
              title: const Text('Тема оформления'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Выберите тему'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RadioListTile<int>(
                          title: const Text('Светлая тема'),
                          value: 0,
                          groupValue: themeManager.currentThemeIndex,
                          onChanged: (value) {
                            themeManager.setTheme(value!);
                            Navigator.pop(context);
                          },
                        ),
                        RadioListTile<int>(
                          title: const Text('Темная тема'),
                          value: 1,
                          groupValue: themeManager.currentThemeIndex,
                          onChanged: (value) {
                            themeManager.setTheme(value!);
                            Navigator.pop(context);
                          },
                        ),
                        RadioListTile<int>(
                          title: const Text('Фуди тема'),
                          value: 2,
                          groupValue: themeManager.currentThemeIndex,
                          onChanged: (value) {
                            themeManager.setTheme(value!);
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Закрыть'),
                      ),
                    ],
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('О приложении'),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'ОбедРулетка',
                  applicationVersion: 'v1.0.0',
                  applicationIcon: const Icon(Icons.restaurant, size: 50),
                  children: [
                    const Text(
                      'Приложение для выбора блюд на обед. Используйте рулетку для быстрого выбора или свайпайте карточки для более детального ознакомления с блюдами.',
                      textAlign: TextAlign.justify,
                    ),
                  ],
                );
                // Закрываем Drawer после показа диалога
                Future.delayed(const Duration(milliseconds: 100), () {
                  Navigator.pop(context);
                });
              },
            ),
          ],
        ),
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.casino),
            label: 'Рулетка',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swipe),
            label: 'Тиндер',
          ),
        ],
      ),
    );
  }
}

class LunchRoulette extends StatefulWidget {
  const LunchRoulette({super.key});

  @override
  State<LunchRoulette> createState() => _LunchRouletteState();
}

class _LunchRouletteState extends State<LunchRoulette> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final Random _random = Random();
  int _selectedIndex = 0;
  bool _isSpinning = false;
  final List<String> _history = [];
  final List<bool> _favorites = [];

  // Список вариантов обеда
  final List<String> _lunchOptions = [
    'Пицца',
    'Суши',
    'Бургер',
    'Паста',
    'Салат',
    'Рамен',
    'Шаурма',
    'Стейк',
    'Суп',
    'Плов',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _controller.addListener(() {
      setState(() {});
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isSpinning = false;
          _addToHistory(_lunchOptions[_selectedIndex]);
        });
        
        // Показываем диалог с результатом
        _showResultDialog(_lunchOptions[_selectedIndex]);
      }
    });
  }

  void _addToHistory(String item) {
    setState(() {
      _history.add(item);
      _favorites.add(false);
    });
  }

  void _toggleFavorite(int index) {
    setState(() {
      _favorites[index] = !_favorites[index];
    });
  }

  void _showResultDialog(String result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Ваш выбор!', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.restaurant,
              size: 70,
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            Text(
              result,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Приятного аппетита!',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ОК'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _spinWheel() {
    if (_isSpinning) return;

    setState(() {
      _isSpinning = true;
    });

    // Генерируем случайное количество оборотов (от 2 до 5) плюс случайная позиция
    final int targetRotations = 2 + _random.nextInt(3);
    final double targetAngle = targetRotations * 2 * pi + (_random.nextDouble() * 2 * pi);
    
    // Обновляем анимацию для нового целевого угла
    _animation = Tween<double>(
      begin: 0,
      end: targetAngle,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCirc,
    ));
    
    // Вычисляем индекс, который будет выбран после остановки
    final int optionsCount = _lunchOptions.length;
    final double anglePerItem = 2 * pi / optionsCount;
    final double normalizedAngle = targetAngle % (2 * pi);
    _selectedIndex = (optionsCount - (normalizedAngle / anglePerItem).floor() - 1) % optionsCount;
    
    _controller.reset();
    _controller.forward();
  }

  void _openHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HistoryScreen(
          historyItems: _history,
          favorites: _favorites,
          onToggleFavorite: _toggleFavorite,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('ОбедРулетка'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _history.isEmpty ? null : _openHistory,
            tooltip: 'История выборов',
          ),
        ],
      ),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
            margin: const EdgeInsets.symmetric(horizontal: 32.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              _isSpinning 
                  ? 'Выбираем...' 
                  : _controller.value > 0 
                      ? 'Ваш выбор: ${_lunchOptions[_selectedIndex]}' 
                      : 'Крути рулетку, чтобы выбрать обед!',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 40),
          Center(
            child: SizedBox(
              width: 300,
              height: 300,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Внешний круг (декоративный элемент)
                  Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                      color: Theme.of(context).colorScheme.primaryContainer,
                    ),
                  ),
                  // Колесо рулетки
                  Transform.rotate(
                    angle: _controller.value > 0 ? _animation.value : 0,
                    child: Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.primary,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: CustomPaint(
                        painter: WheelPainter(
                          _lunchOptions,
                          textColor: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                  // Центральная круглая кнопка
                  GestureDetector(
                    onTap: _spinWheel,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.secondary,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 2,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.rotate_right,
                        color: Theme.of(context).colorScheme.onSecondary,
                        size: 30,
                      ),
                    ),
                  ),
                  // Треугольник-указатель
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: 30,
                      height: 30,
                      transform: Matrix4.translationValues(0, -15, 0),
                      child: CustomPaint(
                        painter: PointerPainter(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: _isSpinning ? null : _spinWheel,
            icon: const Icon(Icons.casino),
            label: Text(_isSpinning ? 'Крутится...' : 'Крутить рулетку'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              textStyle: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

// Обновленный класс для отрисовки колеса
class WheelPainter extends CustomPainter {
  final List<String> options;
  final Color textColor;

  WheelPainter(this.options, {this.textColor = Colors.white});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final optionsCount = options.length;
    final sweepAngle = 2 * pi / optionsCount;

    // Рисуем сектора
    for (int i = 0; i < optionsCount; i++) {
      final startAngle = i * sweepAngle;
      final Paint sectorPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = i % 2 == 0 
            ? Colors.orange.shade500  
            : Colors.orange.shade300;
      
      canvas.drawArc(
        rect,
        startAngle,
        sweepAngle,
        true,
        sectorPaint,
      );
      
      // Рисуем границы секторов
      final Paint linePaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      
      canvas.drawLine(
        center,
        Offset(
          center.dx + radius * cos(startAngle),
          center.dy + radius * sin(startAngle),
        ),
        linePaint,
      );
    }

    // Добавляем текст для каждого сектора
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i < optionsCount; i++) {
      textPainter.text = TextSpan(
        text: options[i],
        style: TextStyle(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      );
      
      textPainter.layout();
      
      final angle = i * sweepAngle + sweepAngle / 2;
      final double textRadius = radius * 0.7; // Немного внутрь от края
      
      final textX = center.dx + textRadius * cos(angle) - textPainter.width / 2;
      final textY = center.dy + textRadius * sin(angle) - textPainter.height / 2;
      
      canvas.save();
      canvas.translate(textX, textY);
      canvas.rotate(angle + pi / 2); // Поворачиваем текст, чтобы он был читаемым
      canvas.translate(-textPainter.width / 2, -textPainter.height / 2);
      textPainter.paint(canvas, Offset.zero);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Обновленный класс для отрисовки указателя
class PointerPainter extends CustomPainter {
  final Color color;
  
  PointerPainter({this.color = Colors.red});
  
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.close();
    
    canvas.drawPath(path, paint);
    
    // Добавляем обводку
    final Paint strokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
