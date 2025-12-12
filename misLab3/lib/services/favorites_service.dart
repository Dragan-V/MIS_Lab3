import 'package:cloud_firestore/cloud_firestore.dart';

class FavoritesService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String userId;

  FavoritesService({required this.userId});

  CollectionReference get _favoritesColl => _db.collection('users').doc(userId).collection('favorites');

  Future<void> addFavorite(Map<String, dynamic> mealData) async {
    final id = mealData['idMeal'];
    await _favoritesColl.doc(id.toString()).set(mealData);
  }

  Future<void> removeFavorite(String idMeal) async {
    await _favoritesColl.doc(idMeal).delete();
  }

  Future<bool> isFavorite(String idMeal) async {
    final doc = await _favoritesColl.doc(idMeal).get();
    return doc.exists;
  }

  Stream<List<Map<String, dynamic>>> favoritesStream() {
    return _favoritesColl.snapshots().map((snap) =>
        snap.docs.map((d) => {...d.data() as Map<String, dynamic>}).toList()
    );
  }

  Future<List<Map<String, dynamic>>> getFavoritesOnce() async {
    final snap = await _favoritesColl.get();
    return snap.docs.map((d) => {...d.data() as Map<String, dynamic>}).toList();
  }
}
