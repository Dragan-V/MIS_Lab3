import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/category.dart';
import '../services/favorites_service.dart';
import 'favorites_screen.dart';
import '../widgets/category_card.dart';
import 'random_meal_screen.dart';
import 'meals_by_category_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final ApiService api = ApiService();
  List<Category> categories = [];
  List<Category> filtered = [];
  bool loading = true;
  late final FavoritesService favoritesService;

  @override
  void initState() {
    super.initState();
  favoritesService = FavoritesService(userId: 'demo-user');
    _load();
  }

  Future<void> _load() async {
    try {
      final cats = await api.fetchCategories();
      setState(() {
        categories = cats;
        filtered = cats;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  void _onSearch(String q) {
    setState(() {
      filtered = categories.where((c) =>
          c.strCategory.toLowerCase().contains(q.toLowerCase())
      ).toList();
    });
  }

  void _openRandom() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RandomMealScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Категории'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: 'Омилени',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => FavoritesScreen(favoritesService: favoritesService),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.shuffle),
            onPressed: _openRandom,
            tooltip: 'Random meal',
          )
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          SearchBar(
            onChanged: _onSearch,
            hintText: 'Пребарај категорија',
          ),

          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.9,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8
              ),
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final c = filtered[i];
                return CategoryCard(
                  category: c,
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => MealsByCategoryScreen(category: c.strCategory, favoritesService: favoritesService),
                    ));
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
