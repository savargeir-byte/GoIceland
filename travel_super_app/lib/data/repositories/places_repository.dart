import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/place.dart';

/// 📍 Places Repository - Firebase Firestore integration
class PlacesRepository {
  final FirebaseFirestore _db;

  PlacesRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  /// Get all places as stream
  Stream<List<Place>> getAllPlaces() {
    return _db.collection('places').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        try {
          final data = doc.data();
          data['id'] = doc.id; // Ensure ID is included
          return Place.fromJson(data);
        } catch (e) {
          print('⚠️ Error parsing place ${doc.id}: $e');
          rethrow;
        }
      }).toList();
    });
  }

  /// Get places by category
  Stream<List<Place>> getPlacesByCategory(String category) {
    return _db
        .collection('places')
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Place.fromJson(data);
      }).toList();
    });
  }

  /// Get featured places (limited to 50)
  Future<List<Place>> getFeaturedPlaces({int limit = 50}) async {
    try {
      final snapshot = await _db
          .collection('places')
          .orderBy('rating', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Place.fromJson(data);
      }).toList();
    } catch (e) {
      print('❌ Error fetching featured places: $e');
      return [];
    }
  }

  /// Get place by ID
  Future<Place?> getPlaceById(String id) async {
    try {
      final doc = await _db.collection('places').doc(id).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      data['id'] = doc.id;
      return Place.fromJson(data);
    } catch (e) {
      print('❌ Error fetching place $id: $e');
      return null;
    }
  }

  /// Search places by name
  Stream<List<Place>> searchPlaces(String query) {
    final lowerQuery = query.toLowerCase();
    
    return _db.collection('places').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return Place.fromJson(data);
          })
          .where((place) =>
              place.name.toLowerCase().contains(lowerQuery) ||
              place.category.toLowerCase().contains(lowerQuery))
          .toList();
    });
  }

  /// Get nearby places (using bounding box)
  Stream<List<Place>> getNearbyPlaces({
    required double lat,
    required double lng,
    double radiusKm = 50,
  }) {
    // Simple bounding box calculation (1 degree ≈ 111 km)
    final latDelta = radiusKm / 111;
    final lngDelta = radiusKm / (111 * 0.7); // Approximate for Iceland latitude

    final minLat = lat - latDelta;
    final maxLat = lat + latDelta;
    final minLng = lng - lngDelta;
    final maxLng = lng + lngDelta;

    return _db
        .collection('places')
        .where('lat', isGreaterThanOrEqualTo: minLat)
        .where('lat', isLessThanOrEqualTo: maxLat)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return Place.fromJson(data);
          })
          .where((place) => place.lng >= minLng && place.lng <= maxLng)
          .toList();
    });
  }

  /// Add new place
  Future<String> addPlace(Place place) async {
    try {
      final docRef = await _db.collection('places').add(place.toJson());
      return docRef.id;
    } catch (e) {
      print('❌ Error adding place: $e');
      rethrow;
    }
  }

  /// Update place
  Future<void> updatePlace(String id, Place place) async {
    try {
      await _db.collection('places').doc(id).update(place.toJson());
    } catch (e) {
      print('❌ Error updating place $id: $e');
      rethrow;
    }
  }

  /// Delete place
  Future<void> deletePlace(String id) async {
    try {
      await _db.collection('places').doc(id).delete();
    } catch (e) {
      print('❌ Error deleting place $id: $e');
      rethrow;
    }
  }

  /// Batch upload places (for import)
  Future<void> batchUploadPlaces(List<Place> places) async {
    try {
      final batch = _db.batch();
      
      for (final place in places) {
        final docRef = _db.collection('places').doc(place.id);
        batch.set(docRef, place.toJson());
      }

      await batch.commit();
      print('✅ Batch uploaded ${places.length} places');
    } catch (e) {
      print('❌ Error batch uploading places: $e');
      rethrow;
    }
  }

  /// Get places count by category
  Future<Map<String, int>> getPlacesCountByCategory() async {
    try {
      final snapshot = await _db.collection('places').get();
      final counts = <String, int>{};

      for (final doc in snapshot.docs) {
        final category = doc.data()['category'] as String? ?? 'unknown';
        counts[category] = (counts[category] ?? 0) + 1;
      }

      return counts;
    } catch (e) {
      print('❌ Error getting places count: $e');
      return {};
    }
  }
}
