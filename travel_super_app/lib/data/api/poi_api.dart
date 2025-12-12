import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/poi_model.dart';

class PoiApi {
  PoiApi({FirebaseFirestore? firestore}) : _firestore = firestore;

  final FirebaseFirestore? _firestore;

  FirebaseFirestore get _db => _firestore ?? FirebaseFirestore.instance;

  Future<List<PoiModel>> fetchFeatured() async {
    if (Firebase.apps.isEmpty && _firestore == null) {
      return _fallback;
    }
    try {
      final snapshot = await _db.collection('pois').limit(10).get();
      return snapshot.docs.map((doc) => PoiModel.fromJson(doc.data())).toList();
    } catch (_) {
      return _fallback;
    }
  }

  Future<List<PoiModel>> fetchByCategory(String category) async {
    if (Firebase.apps.isEmpty && _firestore == null) {
      return _fallback.where((poi) => poi.type == category).toList();
    }
    try {
      final snapshot = await _db
          .collection('pois')
          .where('type', isEqualTo: category)
          .orderBy('rating', descending: true)
          .limit(10)
          .get();
      return snapshot.docs.map((doc) => PoiModel.fromJson(doc.data())).toList();
    } catch (_) {
      return _fallback.where((poi) => poi.type == category).toList();
    }
  }

  List<PoiModel> get _fallback => const [
        PoiModel(
          id: 'seljalandsfoss',
          name: 'Seljalandsfoss',
          type: 'waterfall',
          latitude: 63.6156,
          longitude: -19.9929,
          rating: 4.8,
          country: 'IS',
          open: '24/7',
          image: 'https://images.unsplash.com/photo-1469474968028-56623f02e42e',
        ),
        PoiModel(
          id: 'sky-lagoon',
          name: 'Sky Lagoon',
          type: 'spa',
          latitude: 64.0841,
          longitude: -22.0081,
          rating: 4.6,
          country: 'IS',
          open: '09:00-22:00',
          image: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb',
        ),
      ];
}
