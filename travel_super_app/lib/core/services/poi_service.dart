import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';

/// Service for fetching POIs (Places of Interest) from Firestore
/// Supports geolocation queries, filtering, and caching
class PoiService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get all places with optional filters
  Future<List<Map<String, dynamic>>> getPlaces({
    String? type,
    String? subtype,
    String? region,
    int limit = 20,
  }) async {
    Query query = _firestore.collection('places');

    if (type != null) {
      query = query.where('type', isEqualTo: type);
    }

    if (subtype != null) {
      query = query.where('subtype', isEqualTo: subtype);
    }

    if (region != null) {
      query = query.where('region', isEqualTo: region);
    }

    query = query.orderBy('popularity', descending: true).limit(limit);

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => {
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            })
        .toList();
  }

  /// Get places near a location using geohash
  Stream<List<DocumentSnapshot>> getPlacesNearby({
    required double lat,
    required double lng,
    required double radiusInKm,
    String? type,
    int limit = 50,
  }) {
    final geo = GeoCollectionReference(_firestore.collection('places'));

    return geo.subscribeWithin(
      center: GeoFirePoint(GeoPoint(lat, lng)),
      radiusInKm: radiusInKm,
      field: 'location.geopoint',
      geopointFrom: (data) => (data['location'] as Map)['geopoint'] as GeoPoint,
      strictMode: true,
    );
  }

  /// Get a single place by ID
  Future<Map<String, dynamic>?> getPlace(String placeId) async {
    final doc = await _firestore.collection('places').doc(placeId).get();

    if (!doc.exists) return null;

    return {
      'id': doc.id,
      ...doc.data() as Map<String, dynamic>,
    };
  }

  /// Get all trails with optional filters
  Future<List<Map<String, dynamic>>> getTrails({
    String? difficulty,
    String? region,
    int limit = 20,
  }) async {
    Query query = _firestore.collection('trails');

    if (difficulty != null) {
      query = query.where('difficulty', isEqualTo: difficulty);
    }

    if (region != null) {
      query = query.where('region', isEqualTo: region);
    }

    query = query.orderBy('popularity', descending: true).limit(limit);

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => {
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            })
        .toList();
  }

  /// Get a curated collection (e.g., Today's Picks)
  Future<Map<String, dynamic>?> getCollection(String collectionId) async {
    final doc =
        await _firestore.collection('collections').doc(collectionId).get();

    if (!doc.exists) return null;

    return {
      'id': doc.id,
      ...doc.data() as Map<String, dynamic>,
    };
  }

  /// Get Today's Picks with full place data
  Future<List<Map<String, dynamic>>> getTodaysPicks() async {
    final collection = await getCollection('todays_picks');
    if (collection == null) return [];

    final placeIds = List<String>.from(collection['placeIds'] ?? []);

    // Fetch all places in parallel
    final places = await Future.wait(placeIds.map((id) => getPlace(id)));

    return places.whereType<Map<String, dynamic>>().toList();
  }

  /// Search places by name
  Future<List<Map<String, dynamic>>> searchPlaces(String query) async {
    // Note: This is a simple implementation. For production, use Algolia or similar
    final snapshot = await _firestore
        .collection('places')
        .orderBy('name')
        .startAt([query])
        .endAt(['$query\uf8ff'])
        .limit(20)
        .get();

    return snapshot.docs
        .map((doc) => {
              'id': doc.id,
              ...doc.data(),
            })
        .toList();
  }

  /// Save a place to user's saved list
  Future<void> savePlace(String userId, String placeId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('saved_places')
        .doc(placeId)
        .set({
      'savedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Remove a place from user's saved list
  Future<void> unsavePlace(String userId, String placeId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('saved_places')
        .doc(placeId)
        .delete();
  }

  /// Get user's saved places
  Stream<List<Map<String, dynamic>>> getSavedPlaces(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('saved_places')
        .orderBy('savedAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      // Fetch full place data for each saved place
      final placeIds = snapshot.docs.map((doc) => doc.id).toList();
      final places = await Future.wait(placeIds.map((id) => getPlace(id)));

      return places.whereType<Map<String, dynamic>>().toList();
    });
  }

  /// Get places by multiple IDs (for collections)
  Future<List<Map<String, dynamic>>> getPlacesByIds(
      List<String> placeIds) async {
    if (placeIds.isEmpty) return [];

    // Firestore 'in' query limit is 10, so we batch
    final batches = <Future<List<Map<String, dynamic>>>>[];

    for (var i = 0; i < placeIds.length; i += 10) {
      final batch = placeIds.skip(i).take(10).toList();
      batches.add(_firestore
          .collection('places')
          .where(FieldPath.documentId, whereIn: batch)
          .get()
          .then((snapshot) => snapshot.docs
              .map((doc) => {
                    'id': doc.id,
                    ...doc.data(),
                  })
              .toList()));
    }

    final results = await Future.wait(batches);
    return results.expand((batch) => batch).toList();
  }
}
