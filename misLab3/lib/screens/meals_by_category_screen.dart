import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/meal.dart';
import '../widgets/meal_card.dart';
import '../services/favorites_service.dart';
import 'meal_detail_screen.dart';

class MealsByCategoryScreen extends StatefulWidget {
  final String category;
  final FavoritesService favoritesService;
  const MealsByCategoryScreen({super.key, required this.category, required this.favoritesService});

  @override
  State<MealsByCategoryScreen> createState() => _MealsByCategoryScreenState();
}

class _MealsByCategoryScreenState extends State<MealsByCategoryScreen> {
  final ApiService api = ApiService();
  List<Meal> meals = [];
  List<Meal> filtered = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final m = await api.fetchMealsByCategory(widget.category);
      setState(() {
        meals = m;
        filtered = m;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  Future<void> _search(String q) async {
    if (q.trim().isEmpty) {
      setState(() => filtered = meals);
      return;
    }
    final results = await api.searchMeals(q);
    setState(() {
      filtered = results.where((r) => r.strCategory == null || r.strCategory == widget.category ? true : false).toList()
        ..addAll(results.where((r) => r.strMeal.toLowerCase().contains(q.toLowerCase()) && !results.contains(r)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          SearchBar(
            onChanged: _search,
            hintText: 'Пребарај храна',
          ),

          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, childAspectRatio: 0.9, mainAxisSpacing: 8, crossAxisSpacing: 8),
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final m = filtered[i];
                return MealCard(
                  meal: m,
                  onTap: () async {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => MealDetailScreen(mealId: m.idMeal)));
                  },
                  favoritesService: widget.favoritesService,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
