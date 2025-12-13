import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/models/place_model.dart';

/// Service fyrir að sækja POI gögn frá Firestore
///
/// Dæmi:
/// ```dart
/// // Sækja alla staði
/// final places = await PoiDataService.getAllPlaces();
///
/// // Sækja hótels
/// final hotels = await PoiDataService.getPlacesByCategory('hotel');
///
/// // Sækja staði á Suðurlandi
/// final south = await PoiDataService.getPlacesByRegion('South');
/// ```
class PoiDataService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Sækir alla staði úr Firestore
  static Future<List<PlaceModel>> getAllPlaces({int? limit}) async {
    try {
      Query query = _db.collection('places');

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return PlaceModel.fromFirestore(data);
      }).toList();
    } catch (e) {
      print('Error fetching all places: $e');
      return [];
    }
  }

  /// Sækir staði eftir category
  ///
  /// Categories: waterfall, hot_spring, hotel, restaurant, cafe, bar, etc.
  static Future<List<PlaceModel>> getPlacesByCategory(
    String category, {
    int? limit,
  }) async {
    try {
      Query query =
          _db.collection('places').where('category', isEqualTo: category);

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return PlaceModel.fromFirestore(data);
      }).toList();
    } catch (e) {
      print('Error fetching places by category: $e');
      return [];
    }
  }

  /// Sækir staði eftir region
  ///
  /// Regions: Capital Region, South, Southeast, East, North, etc.
  static Future<List<PlaceModel>> getPlacesByRegion(
    String region, {
    int? limit,
  }) async {
    try {
      Query query = _db.collection('places').where('region', isEqualTo: region);

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return PlaceModel.fromFirestore(data);
      }).toList();
    } catch (e) {
      print('Error fetching places by region: $e');
      return [];
    }
  }

  /// Sækir hótels með filter
  static Future<List<PlaceModel>> getHotels({
    String? region,
    int? minStars,
    int? limit = 20,
  }) async {
    try {
      Query query = _db.collection('places');

      // Filter by accommodation types
      query =
          query.where('category', whereIn: ['hotel', 'guesthouse', 'hostel']);

      if (region != null) {
        query = query.where('region', isEqualTo: region);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();

      var results = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return PlaceModel.fromFirestore(data);
      }).toList();

      // Client-side filter for stars (if stars field exists)
      if (minStars != null) {
        results = results.where((place) {
          final stars = int.tryParse(place.meta?['stars'] ?? '0');
          return stars != null && stars >= minStars;
        }).toList();
      }

      return results;
    } catch (e) {
      print('Error fetching hotels: $e');
      return [];
    }
  }

  /// Sækir veitingastaði
  static Future<List<PlaceModel>> getRestaurants({
    String? region,
    String? cuisine,
    int? limit = 50,
  }) async {
    try {
      Query query = _db.collection('places');

      // Filter by food/drink categories
      query = query.where('category', whereIn: ['restaurant', 'cafe', 'bar']);

      if (region != null) {
        query = query.where('region', isEqualTo: region);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();

      var results = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return PlaceModel.fromFirestore(data);
      }).toList();

      // Client-side filter for cuisine
      if (cuisine != null) {
        results = results.where((place) {
          final placeCuisine = place.meta?['cuisine']?.toLowerCase();
          return placeCuisine?.contains(cuisine.toLowerCase()) ?? false;
        }).toList();
      }

      return results;
    } catch (e) {
      print('Error fetching restaurants: $e');
      return [];
    }
  }

  /// Sækir stað eftir ID
  static Future<PlaceModel?> getPlaceById(String placeId) async {
    try {
      final doc = await _db.collection('places').doc(placeId).get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return PlaceModel.fromFirestore(data);
    } catch (e) {
      print('Error fetching place by ID: $e');
      return null;
    }
  }

  /// Sækir staði með pagination
  static Future<List<PlaceModel>> getPlacesPaginated({
    DocumentSnapshot? lastDoc,
    int limit = 20,
    String? category,
    String? region,
  }) async {
    try {
      Query query = _db.collection('places');

      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }

      if (region != null) {
        query = query.where('region', isEqualTo: region);
      }

      query = query.limit(limit);

      if (lastDoc != null) {
        query = query.startAfterDocument(lastDoc);
      }

      final snapshot = await query.get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return PlaceModel.fromFirestore(data);
      }).toList();
    } catch (e) {
      print('Error fetching paginated places: $e');
      return [];
    }
  }

  /// Stream af öllum stöðum (real-time)
  static Stream<List<PlaceModel>> placesStream({
    String? category,
    String? region,
    int? limit,
  }) {
    Query query = _db.collection('places');

    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }

    if (region != null) {
      query = query.where('region', isEqualTo: region);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return PlaceModel.fromFirestore(data);
      }).toList();
    });
  }

  /// Leita að stöðum
  static Future<List<PlaceModel>> searchPlaces(String searchTerm) async {
    try {
      // Firestore doesn't support full-text search natively
      // We fetch all places and filter client-side
      // For production, use Algolia or similar

      final snapshot = await _db.collection('places').get();

      final lowerSearch = searchTerm.toLowerCase();

      return snapshot.docs.where((doc) {
        final data = doc.data();
        final name = (data['name'] as String?)?.toLowerCase() ?? '';
        final description =
            (data['description'] as String?)?.toLowerCase() ?? '';

        return name.contains(lowerSearch) || description.contains(lowerSearch);
      }).map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return PlaceModel.fromFirestore(data);
      }).toList();
    } catch (e) {
      print('Error searching places: $e');
      return [];
    }
  }
}
