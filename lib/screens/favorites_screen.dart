import 'package:flutter/material.dart';
import '../services/favorites_service.dart';
import 'meal_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  final FavoritesService favoritesService;
  const FavoritesScreen({super.key, required this.favoritesService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Омилени рецепти')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: favoritesService.favoritesStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final favs = snapshot.data!;
          if (favs.isEmpty) return const Center(child: Text('Нема омилени'));
          return ListView.builder(
            itemCount: favs.length,
            itemBuilder: (context, i) {
              final item = favs[i];
              return ListTile(
                leading: item['strMealThumb'] != null && item['strMealThumb'] != ''
                    ? Image.network(item['strMealThumb'], width: 56, fit: BoxFit.cover)
                    : const Icon(Icons.fastfood),
                title: Text(item['strMeal'] ?? ''),
                onTap: () {
                  final id = item['idMeal']?.toString();
                  if (id != null && id.isNotEmpty) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MealDetailScreen(mealId: id),
                      ),
                    );
                  }
                },
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => favoritesService.removeFavorite(item['idMeal']),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
