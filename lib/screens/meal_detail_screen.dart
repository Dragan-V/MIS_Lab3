import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/api_service.dart';
import '../services/favorites_service.dart';
import '../models/meal.dart';

class MealDetailScreen extends StatefulWidget {
  final String mealId;
  const MealDetailScreen({super.key, required this.mealId});

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  final ApiService api = ApiService();
  late final FavoritesService favoritesService;
  Meal? meal;
  bool loading = true;
  bool isFav = false;

  @override
  void initState() {
    super.initState();
  favoritesService = FavoritesService(userId: 'demo-user');
    _load();
  }

  Future<void> _load() async {
    try {
      final m = await api.lookupMealById(widget.mealId);
      setState(() {
        meal = m;
        loading = false;
      });
      if (m != null) {
        final fav = await favoritesService.isFavorite(m.idMeal);
        if (mounted) setState(() => isFav = fav);
      }
    } catch (e) {
      setState(() => loading = false);
    }
  }

  void _openYoutube() async {
    if (meal?.strYoutube == null) return;
    final uri = Uri.parse(meal!.strYoutube!);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(meal?.strMeal ?? 'Recipe'),
        actions: [
          if (!loading && meal != null)
            IconButton(
              icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: Colors.red),
              onPressed: () async {
                if (meal == null) return;
                setState(() => isFav = !isFav);
                try {
                  if (!isFav) {
                    await favoritesService.removeFavorite(meal!.idMeal);
                  } else {
                    final mealMap = {
                      'idMeal': meal!.idMeal,
                      'strMeal': meal!.strMeal,
                      'strMealThumb': meal!.strMealThumb ?? '',
                      'addedAt': FieldValue.serverTimestamp(),
                    };
                    await favoritesService.addFavorite(mealMap);
                  }
                } catch (_) {
                  if (mounted) setState(() => isFav = !isFav);
                }
              },
            ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : meal == null
          ? const Center(child: Text('Meal not found'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (meal!.strMealThumb != null)
              Image.network(meal!.strMealThumb!),
            const SizedBox(height: 8),
            Text(meal!.strMeal, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (meal!.strCategory != null)
              Text('Category: ${meal!.strCategory}'),
            if (meal!.strArea != null)
              Text('Area: ${meal!.strArea}'),
            const SizedBox(height: 12),
            Text('Ingredients', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            ...meal!.ingredients.map((map) {
              final k = map.keys.first;
              final v = map.values.first;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Text('- $k ${v.isNotEmpty ? ' — $v' : ''}'),
              );
            }).toList(),
            const SizedBox(height: 12),
            Text('Instructions', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(meal!.strInstructions ?? ''),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
