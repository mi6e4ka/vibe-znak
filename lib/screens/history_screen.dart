import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class HistoryScreen extends StatefulWidget {
  final List<String> historyItems;
  final Function(int) onToggleFavorite;
  final List<bool> favorites;

  const HistoryScreen({
    super.key,
    required this.historyItems,
    required this.onToggleFavorite,
    required this.favorites,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // Добавляем управление сортировкой
  bool _showOnlyFavorites = false;
  bool _sortByNewest = true;

  @override
  Widget build(BuildContext context) {
    // Фильтруем и сортируем элементы истории
    List<int> displayedIndices = [];
    
    for (int i = 0; i < widget.historyItems.length; i++) {
      if (!_showOnlyFavorites || widget.favorites[i]) {
        displayedIndices.add(i);
      }
    }
    
    // Сортировка
    if (_sortByNewest) {
      displayedIndices.sort((a, b) => b.compareTo(a)); // От новых к старым
    } else {
      displayedIndices.sort(); // От старых к новым
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('История выборов'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Кнопка переключения сортировки
          IconButton(
            icon: Icon(_sortByNewest 
                ? Icons.arrow_downward 
                : Icons.arrow_upward),
            onPressed: () {
              setState(() {
                _sortByNewest = !_sortByNewest;
              });
            },
            tooltip: _sortByNewest 
                ? 'Сначала новые' 
                : 'Сначала старые',
          ),
          // Кнопка фильтрации избранного
          IconButton(
            icon: Icon(
              Icons.favorite,
              color: _showOnlyFavorites 
                  ? Colors.red 
                  : Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _showOnlyFavorites = !_showOnlyFavorites;
              });
            },
            tooltip: _showOnlyFavorites 
                ? 'Показать все' 
                : 'Только избранное',
          ),
        ],
      ),
      body: displayedIndices.isEmpty
          ? _buildEmptyState()
          : _buildHistoryList(displayedIndices),
    );
  }
  
  Widget _buildEmptyState() {
    return FadeIn(
      duration: const Duration(milliseconds: 400),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _showOnlyFavorites ? Icons.favorite : Icons.history,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              _showOnlyFavorites 
                  ? 'Нет избранных блюд'
                  : 'История пуста',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              _showOnlyFavorites 
                  ? 'Добавьте блюда в избранное, нажав на значок сердечка'
                  : 'Покрутите рулетку, чтобы добавить блюда в историю',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHistoryList(List<int> indices) {
    return ListView.builder(
      itemCount: indices.length,
      itemBuilder: (context, index) {
        final itemIndex = indices[index];
        final item = widget.historyItems[itemIndex];
        final isFavorite = widget.favorites[itemIndex];
        
        return FadeInLeft(
          delay: Duration(milliseconds: index * 50),
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isFavorite 
                        ? [Colors.red.shade300, Colors.red.shade600]
                        : [
                            Theme.of(context).colorScheme.primary.withOpacity(0.6),
                            Theme.of(context).colorScheme.primary
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    item.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              title: Text(
                item,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Выбрано ${DateTime.now().subtract(Duration(minutes: itemIndex * 30)).toString().substring(0, 16)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(50),
                  onTap: () {
                    widget.onToggleFavorite(itemIndex);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        key: ValueKey<bool>(isFavorite),
                        color: isFavorite ? Colors.red : Colors.grey,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
} 