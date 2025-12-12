import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/meal.dart';
import '../services/favorites_service.dart';

class MealCard extends StatefulWidget {
  final Meal meal;
  final VoidCallback onTap;
  final FavoritesService favoritesService;

  const MealCard({
    super.key,
    required this.meal,
    required this.onTap,
    required this.favoritesService,
  });

  @override
  State<MealCard> createState() => _MealCardState();
}

class _MealCardState extends State<MealCard> {
  bool isFav = false;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _checkFav();
  }

  Future<void> _checkFav() async {
    try {
      final fav = await widget.favoritesService.isFavorite(widget.meal.idMeal).timeout(const Duration(seconds: 2), onTimeout: () => false);
      if (mounted) {
        setState(() {
          isFav = fav;
          loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _toggleFav() async {
    setState(() {
      isFav = !isFav;
      loading = false;
    });
    try {
      if (!isFav) {
        await widget.favoritesService.removeFavorite(widget.meal.idMeal);
      } else {
        final mealMap = {
          'idMeal': widget.meal.idMeal,
          'strMeal': widget.meal.strMeal,
          'strMealThumb': widget.meal.strMealThumb ?? '',
          'addedAt': FieldValue.serverTimestamp(),
        };
        await widget.favoritesService.addFavorite(mealMap);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          isFav = !isFav;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: CachedNetworkImage(
                    imageUrl: widget.meal.strMealThumb ?? '',
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(widget.meal.strMeal, textAlign: TextAlign.center),
                ),
              ],
            ),
            Positioned(
              top: 6,
              right: 6,
              child: loading
                  ? const CircularProgressIndicator(strokeWidth: 2)
                  : IconButton(
                icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: Colors.red),
                onPressed: _toggleFav,
              ),
            )
          ],
        ),
      ),
    );
  }
}
