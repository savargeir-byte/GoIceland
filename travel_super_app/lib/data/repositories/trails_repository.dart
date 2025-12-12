import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/trail.dart';

/// 🥾 Trails Repository - Firebase Firestore integration
class TrailsRepository {
  final FirebaseFirestore _db;

  TrailsRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  /// Get all trails as stream
  Stream<List<Trail>> getAllTrails() {
    return _db.collection('trails').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        try {
          final data = doc.data();
          data['id'] = doc.id;
          return Trail.fromJson(data);
        } catch (e) {
          print('⚠️ Error parsing trail ${doc.id}: $e');
          rethrow;
        }
      }).toList();
    });
  }

  /// Get trails by difficulty
  Stream<List<Trail>> getTrailsByDifficulty(String difficulty) {
    return _db
        .collection('trails')
        .where('difficulty', isEqualTo: difficulty)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Trail.fromJson(data);
      }).toList();
    });
  }

  /// Get trails by region
  Stream<List<Trail>> getTrailsByRegion(String region) {
    return _db
        .collection('trails')
        .where('region', isEqualTo: region)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Trail.fromJson(data);
      }).toList();
    });
  }

  /// Get featured trails (top rated)
  Future<List<Trail>> getFeaturedTrails({int limit = 20}) async {
    try {
      final snapshot = await _db
          .collection('trails')
          .orderBy('rating', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Trail.fromJson(data);
      }).toList();
    } catch (e) {
      print('❌ Error fetching featured trails: $e');
      return [];
    }
  }

  /// Get trail by ID
  Future<Trail?> getTrailById(String id) async {
    try {
      final doc = await _db.collection('trails').doc(id).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      data['id'] = doc.id;
      return Trail.fromJson(data);
    } catch (e) {
      print('❌ Error fetching trail $id: $e');
      return null;
    }
  }

  /// Search trails by name
  Stream<List<Trail>> searchTrails(String query) {
    final lowerQuery = query.toLowerCase();
    
    return _db.collection('trails').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return Trail.fromJson(data);
          })
          .where((trail) =>
              trail.name.toLowerCase().contains(lowerQuery) ||
              trail.description.toLowerCase().contains(lowerQuery))
          .toList();
    });
  }

  /// Get trails by distance range
  Stream<List<Trail>> getTrailsByDistance({
    double minKm = 0,
    double maxKm = 100,
  }) {
    return _db
        .collection('trails')
        .where('distance', isGreaterThanOrEqualTo: minKm)
        .where('distance', isLessThanOrEqualTo: maxKm)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Trail.fromJson(data);
      }).toList();
    });
  }

  /// Add new trail
  Future<String> addTrail(Trail trail) async {
    try {
      final docRef = await _db.collection('trails').add(trail.toJson());
      return docRef.id;
    } catch (e) {
      print('❌ Error adding trail: $e');
      rethrow;
    }
  }

  /// Update trail
  Future<void> updateTrail(String id, Trail trail) async {
    try {
      await _db.collection('trails').doc(id).update(trail.toJson());
    } catch (e) {
      print('❌ Error updating trail $id: $e');
      rethrow;
    }
  }

  /// Delete trail
  Future<void> deleteTrail(String id) async {
    try {
      await _db.collection('trails').doc(id).delete();
    } catch (e) {
      print('❌ Error deleting trail $id: $e');
      rethrow;
    }
  }

  /// Batch upload trails (for import)
  Future<void> batchUploadTrails(List<Trail> trails) async {
    try {
      final batch = _db.batch();
      
      for (final trail in trails) {
        final docRef = _db.collection('trails').doc(trail.id);
        batch.set(docRef, trail.toJson());
      }

      await batch.commit();
      print('✅ Batch uploaded ${trails.length} trails');
    } catch (e) {
      print('❌ Error batch uploading trails: $e');
      rethrow;
    }
  }

  /// Get trails statistics
  Future<Map<String, dynamic>> getTrailsStats() async {
    try {
      final snapshot = await _db.collection('trails').get();
      
      int easy = 0, moderate = 0, hard = 0;
      double totalDistance = 0;
      
      for (final doc in snapshot.docs) {
        final difficulty = doc.data()['difficulty'] as String? ?? 'moderate';
        final distance = (doc.data()['distance'] as num?)?.toDouble() ?? 0;
        
        if (difficulty == 'easy') easy++;
        else if (difficulty == 'moderate') moderate++;
        else if (difficulty == 'hard') hard++;
        
        totalDistance += distance;
      }

      return {
        'total': snapshot.docs.length,
        'easy': easy,
        'moderate': moderate,
        'hard': hard,
        'totalDistance': totalDistance,
        'averageDistance': snapshot.docs.isEmpty ? 0 : totalDistance / snapshot.docs.length,
      };
    } catch (e) {
      print('❌ Error getting trails stats: $e');
      return {};
    }
  }
}
