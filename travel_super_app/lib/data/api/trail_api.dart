import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/trail_model.dart';

class TrailApi {
  TrailApi({FirebaseFirestore? firestore}) : _firestore = firestore;

  final FirebaseFirestore? _firestore;

  FirebaseFirestore get _db => _firestore ?? FirebaseFirestore.instance;

  Future<List<TrailModel>> fetchAllTrails() async {
    if (Firebase.apps.isEmpty && _firestore == null) {
      print('⚠️ Firebase not initialized - using mock trails');
      return _fallbackTrails;
    }
    try {
      print('🔥 Fetching trails from Firebase');
      final snapshot = await _db.collection('trails').get();
      print('✅ Got ${snapshot.docs.length} trails from Firebase');
      
      final trails = <TrailModel>[];
      for (var doc in snapshot.docs) {
        try {
          trails.add(TrailModel.fromMap(doc.data()));
        } catch (e) {
          print('⚠️ Skipped trail ${doc.id}: $e');
        }
      }
      return trails;
    } catch (e) {
      print('❌ Firebase fetch error: $e');
      return _fallbackTrails;
    }
  }

  Future<List<TrailModel>> fetchByDifficulty(String difficulty) async {
    if (Firebase.apps.isEmpty && _firestore == null) {
      return _fallbackTrails
          .where((trail) => trail.difficulty.toLowerCase() == difficulty.toLowerCase())
          .toList();
    }
    try {
      final snapshot = await _db
          .collection('trails')
          .where('difficulty', isEqualTo: difficulty)
          .get();
      
      final trails = <TrailModel>[];
      for (var doc in snapshot.docs) {
        try {
          trails.add(TrailModel.fromMap(doc.data()));
        } catch (e) {
          print('⚠️ Skipped trail ${doc.id}: $e');
        }
      }
      return trails;
    } catch (e) {
      print('❌ Firebase fetch error: $e');
      return _fallbackTrails
          .where((trail) => trail.difficulty.toLowerCase() == difficulty.toLowerCase())
          .toList();
    }
  }

  List<TrailModel> get _fallbackTrails => [
        TrailModel(
          id: 'laugavegur',
          name: 'Laugavegurinn',
          difficulty: 'Hard',
          lengthKm: 55,
          durationMin: 240,
          elevationGain: 1200,
          startLat: 63.9903,
          startLng: -19.0612,
          region: 'Hálendi Íslands',
        ),
        TrailModel(
          id: 'fimmvorduhals',
          name: 'Fimmvörðuháls',
          difficulty: 'Expert',
          lengthKm: 25,
          durationMin: 720,
          elevationGain: 1000,
          startLat: 63.6325,
          startLng: -19.4672,
          region: 'Suðurland',
        ),
        TrailModel(
          id: 'glymur',
          name: 'Glymur',
          difficulty: 'Moderate',
          lengthKm: 7,
          durationMin: 180,
          elevationGain: 350,
          startLat: 64.3908,
          startLng: -21.2667,
          region: 'Vesturland',
        ),
      ];
}