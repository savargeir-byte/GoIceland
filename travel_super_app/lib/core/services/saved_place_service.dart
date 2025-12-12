import 'package:cloud_firestore/cloud_firestore.dart';

/// Service for managing saved places in Firebase Firestore.
class SavedPlaceService {
  SavedPlaceService({required this.uid});

  final String uid;

  CollectionReference _col() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('saved_places');
  }

  /// Add a place to saved collection.
  Future<void> addPlace({
    required String poiId,
    required String name,
    required String location,
    String? imageUrl,
    String? category,
    double? latitude,
    double? longitude,
  }) async {
    await _col().doc(poiId).set({
      'poi_id': poiId,
      'name': name,
      'location': location,
      'image_url': imageUrl,
      'category': category,
      'latitude': latitude,
      'longitude': longitude,
      'added_at': FieldValue.serverTimestamp(),
    });
  }

  /// Remove a place from saved collection.
  Future<void> removePlace(String poiId) async {
    await _col().doc(poiId).delete();
  }

  /// Check if a place is saved.
  Future<bool> isSaved(String poiId) async {
    final doc = await _col().doc(poiId).get();
    return doc.exists;
  }

  /// Stream of saved places, ordered by most recent first.
  Stream<QuerySnapshot> streamSavedPlaces() {
    return _col().orderBy('added_at', descending: true).snapshots();
  }

  /// Get all saved places as a future.
  Future<List<Map<String, dynamic>>> getSavedPlaces() async {
    final snapshot = await _col().orderBy('added_at', descending: true).get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  /// Toggle save/unsave for a place.
  Future<void> toggleSave({
    required String poiId,
    required String name,
    required String location,
    String? imageUrl,
    String? category,
    double? latitude,
    double? longitude,
  }) async {
    final isSavedNow = await isSaved(poiId);
    if (isSavedNow) {
      await removePlace(poiId);
    } else {
      await addPlace(
        poiId: poiId,
        name: name,
        location: location,
        imageUrl: imageUrl,
        category: category,
        latitude: latitude,
        longitude: longitude,
      );
    }
  }
}
