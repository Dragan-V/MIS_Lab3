import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/meal.dart';
import 'meal_detail_screen.dart';

class RandomMealScreen extends StatefulWidget {
  const RandomMealScreen({super.key});

  @override
  State<RandomMealScreen> createState() => _RandomMealScreenState();
}

class _RandomMealScreenState extends State<RandomMealScreen> {
  final ApiService api = ApiService();
  Meal? meal;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadRandom();
  }

  Future<void> _loadRandom() async {
    setState(() => loading = true);
    final m = await api.randomMeal();
    setState(() {
      meal = m;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Random meal'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : meal == null
          ? const Center(child: Text('No random meal'))
          : Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            if (meal!.strMealThumb != null)
              Image.network(meal!.strMealThumb!),
            const SizedBox(height: 8),
            Text(meal!.strMeal, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(meal!.strInstructions != null && meal!.strInstructions!.length > 200
                ? '${meal!.strInstructions!.substring(0, 200)}...'
                : (meal!.strInstructions ?? '')),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => MealDetailScreen(mealId: meal!.idMeal)));
              },
              child: const Text('Open full recipe'),
            ),
            TextButton(onPressed: _loadRandom, child: const Text('New random')),
          ],
        ),
      ),
    );
  }
}
