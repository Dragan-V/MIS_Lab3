import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category.dart';
import '../models/meal.dart';

class ApiService {
  static const _base = 'https://www.themealdb.com/api/json/v1/1';

  Future<List<Category>> fetchCategories() async {
    final url = Uri.parse('$_base/categories.php');
    final resp = await http.get(url);
    if (resp.statusCode == 200) {
      final json = jsonDecode(resp.body);
      final List cats = json['categories'] ?? [];
      return cats.map((c) => Category.fromJson(c)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<List<Meal>> fetchMealsByCategory(String category) async {
    final url = Uri.parse('$_base/filter.php?c=$category');
    final resp = await http.get(url);
    if (resp.statusCode == 200) {
      final json = jsonDecode(resp.body);
      final List meals = json['meals'] ?? [];
      return meals.map((m) => Meal.fromShortJson(m)).toList();
    } else {
      throw Exception('Failed to load meals');
    }
  }

  Future<List<Meal>> searchMeals(String query) async {
    final url = Uri.parse('$_base/search.php?s=${Uri.encodeComponent(query)}');
    final resp = await http.get(url);
    if (resp.statusCode == 200) {
      final json = jsonDecode(resp.body);
      final List? meals = json['meals'];
      if (meals == null) return [];
      return meals.map((m) => Meal.fromJson(m)).toList();
    } else {
      throw Exception('Failed to search meals');
    }
  }

  Future<Meal?> lookupMealById(String id) async {
    final url = Uri.parse('$_base/lookup.php?i=$id');
    final resp = await http.get(url);
    if (resp.statusCode == 200) {
      final json = jsonDecode(resp.body);
      final List? meals = json['meals'];
      if (meals == null || meals.isEmpty) return null;
      return Meal.fromJson(meals.first);
    } else {
      throw Exception('Failed to lookup meal');
    }
  }

  Future<Meal?> randomMeal() async {
    final url = Uri.parse('$_base/random.php');
    final resp = await http.get(url);
    if (resp.statusCode == 200) {
      final json = jsonDecode(resp.body);
      final List? meals = json['meals'];
      if (meals == null || meals.isEmpty) return null;
      return Meal.fromJson(meals.first);
    } else {
      throw Exception('Failed to get random meal');
    }
  }
}
