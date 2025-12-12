import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/poi_model.dart';

class PoiApi {
  PoiApi({FirebaseFirestore? firestore}) : _firestore = firestore;

  final FirebaseFirestore? _firestore;

  // Cache to avoid repeated queries
  static final Map<String, List<PoiModel>> _cache = {};
  static DateTime? _lastFetch;

  FirebaseFirestore get _db => _firestore ?? FirebaseFirestore.instance;

  Future<List<PoiModel>> fetchFeatured() async {
    // Check cache first (valid for 5 minutes)
    if (_cache.containsKey('featured') &&
        _lastFetch != null &&
        DateTime.now().difference(_lastFetch!).inMinutes < 5) {
      print('✅ Using cached featured data');
      return _cache['featured']!;
    }

    if (Firebase.apps.isEmpty && _firestore == null) {
      print('⚠️ Firebase not initialized - using mock data');
      return _fallback;
    }
    try {
      print('🔥 Fetching from Firebase collection: places');
      final snapshot =
          await _db.collection('places').limit(20).get(); // Reduced from 50
      print('✅ Got ${snapshot.docs.length} documents from Firebase');
      final pois = <PoiModel>[];
      for (var doc in snapshot.docs) {
        try {
          pois.add(PoiModel.fromJson(doc.data()));
        } catch (e) {
          print('⚠️ Skipped document ${doc.id}: $e');
        }
      }
      _cache['featured'] = pois;
      _lastFetch = DateTime.now();
      return pois;
    } catch (e) {
      print('❌ Firebase fetch error: $e');
      return _fallback;
    }
  }

  Future<List<PoiModel>> fetchByCategory(String category) async {
    // Check cache first
    final cacheKey = 'category_$category';
    if (_cache.containsKey(cacheKey) &&
        _lastFetch != null &&
        DateTime.now().difference(_lastFetch!).inMinutes < 5) {
      print('✅ Using cached $category data');
      return _cache[cacheKey]!;
    }

    if (Firebase.apps.isEmpty && _firestore == null) {
      // Map UI categories to database categories
      final dbCategory = _mapCategory(category);
      return _fallback.where((poi) => poi.type == dbCategory).toList();
    }
    try {
      final dbCategory = _mapCategory(category);
      print('🔍 Fetching category: $dbCategory');

      // Fetch without orderBy to avoid index requirements - reduced limit
      final snapshot = await _db
          .collection('places')
          .where('category', isEqualTo: dbCategory)
          .limit(30) // Reduced from 100
          .get();

      print('✅ Got ${snapshot.docs.length} $dbCategory POIs');

      final pois = <PoiModel>[];
      for (var doc in snapshot.docs) {
        try {
          pois.add(PoiModel.fromJson(doc.data()));
        } catch (e) {
          print('⚠️ Skipped document ${doc.id}: $e');
        }
      }

      // Sort by rating in memory
      pois.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));

      _cache[cacheKey] = pois;
      _lastFetch = DateTime.now();
      return pois;
    } catch (e) {
      print('❌ Firebase fetch error: $e');
      final dbCategory = _mapCategory(category);
      return _fallback.where((poi) => poi.type == dbCategory).toList();
    }
  }

  String _mapCategory(String uiCategory) {
    switch (uiCategory.toLowerCase()) {
      case 'food':
        return 'restaurant'; // 410 restaurants + 187 cafes
      case 'photo':
        return 'viewpoint'; // 121 viewpoints
      case 'nature':
        return 'waterfall'; // waterfalls, peaks, beaches
      case 'wellness':
        return 'hot_spring'; // 48 hot springs
      case 'adventure':
        return 'peak'; // 2656 peaks for hiking
      case 'hiking':
        return 'peak'; // Same as adventure
      case 'hotel':
        return 'hotel'; // 187 hotels
      case 'museum':
        return 'museum'; // 100 museums
      case 'cave':
        return 'cave'; // 46 caves
      case 'volcano':
        return 'volcano'; // 72 volcanoes
      default:
        return uiCategory;
    }
  }

  List<PoiModel> get _fallback => const [
        // Restaurants & Food
        PoiModel(
          id: '01caaad25998',
          name: 'Stúkuhúsið',
          type: 'restaurant',
          latitude: 65.5967832,
          longitude: -23.9902555,
          rating: 4.5,
          country: 'IS',
          open: '12:00-22:00',
          image: 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0',
        ),
        PoiModel(
          id: '025f6200762d',
          name: 'Tjöruhúsið',
          type: 'restaurant',
          latitude: 66.0681835,
          longitude: -23.1266894,
          rating: 4.7,
          country: 'IS',
          open: '12:00-14:00',
          image: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4',
        ),
        PoiModel(
          id: '02c0a033b55a',
          name: 'Loving Hut',
          type: 'restaurant',
          latitude: 64.1486314,
          longitude: -21.9420647,
          rating: 4.3,
          country: 'IS',
          open: '11:00-21:00',
          image: 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1',
        ),
        PoiModel(
          id: '031716b58e28',
          name: 'Mýrin Brassiere',
          type: 'restaurant',
          latitude: 64.1517286,
          longitude: -21.9524762,
          rating: 4.6,
          country: 'IS',
          open: '11:30-22:00',
          image: 'https://images.unsplash.com/photo-1552566626-52f8b828add9',
        ),
        PoiModel(
          id: '0150bc1b36db',
          name: 'Illy Café',
          type: 'cafe',
          latitude: 63.9971775,
          longitude: -21.1897254,
          rating: 4.2,
          country: 'IS',
          open: '08:00-18:00',
          image: 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085',
        ),
        PoiModel(
          id: 'grillmarket',
          name: 'Grillmarkaðurinn',
          type: 'restaurant',
          latitude: 64.1466,
          longitude: -21.9426,
          rating: 4.7,
          country: 'IS',
          open: '17:00-23:00',
          image: 'https://images.unsplash.com/photo-1544148103-0773bf10d330',
        ),

        // Viewpoints & Photo spots
        PoiModel(
          id: '003355e3c6e2',
          name: 'Svarta ströndin í Vík',
          type: 'viewpoint',
          latitude: 63.4142817,
          longitude: -19.0103136,
          rating: 4.9,
          country: 'IS',
          open: '24/7',
          image: 'https://images.unsplash.com/photo-1483354483454-4cd359948304',
        ),
        PoiModel(
          id: '0045c15b2322',
          name: 'Hengifoss',
          type: 'viewpoint',
          latitude: 65.091364,
          longitude: -14.887536,
          rating: 4.8,
          country: 'IS',
          open: '24/7',
          image: 'https://images.unsplash.com/photo-1531366936337-7c912a4589a7',
        ),
        PoiModel(
          id: '01f79ed00b7e',
          name: 'Borgarnes Viewpoint',
          type: 'viewpoint',
          latitude: 65.3328264,
          longitude: -13.7232366,
          rating: 4.5,
          country: 'IS',
          open: '24/7',
          image: 'https://images.unsplash.com/photo-1504893524553-b855bce32c67',
        ),
        PoiModel(
          id: '01fe49430fdd',
          name: 'Kirkjufjara Beach',
          type: 'viewpoint',
          latitude: 63.4027258,
          longitude: -19.1050512,
          rating: 4.7,
          country: 'IS',
          open: '24/7',
          image: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4',
        ),
        PoiModel(
          id: 'kirkjufell',
          name: 'Kirkjufell Mountain',
          type: 'viewpoint',
          latitude: 64.9242,
          longitude: -23.3122,
          rating: 4.8,
          country: 'IS',
          open: '24/7',
          image: 'https://images.unsplash.com/photo-1504893524553-b855bce32c67',
        ),

        // Waterfalls & Nature
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
          id: 'gullfoss',
          name: 'Gullfoss Waterfall',
          type: 'waterfall',
          latitude: 64.3271,
          longitude: -20.1211,
          rating: 4.9,
          country: 'IS',
          open: '24/7',
          image: 'https://images.unsplash.com/photo-1531366936337-7c912a4589a7',
        ),
        PoiModel(
          id: 'skogafoss',
          name: 'Skógafoss',
          type: 'waterfall',
          latitude: 63.5320,
          longitude: -19.5114,
          rating: 4.9,
          country: 'IS',
          open: '24/7',
          image: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4',
        ),

        // Spas & Wellness
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
        PoiModel(
          id: 'blue-lagoon',
          name: 'Blue Lagoon',
          type: 'spa',
          latitude: 63.8804,
          longitude: -22.4495,
          rating: 4.5,
          country: 'IS',
          open: '08:00-22:00',
          image: 'https://images.unsplash.com/photo-1578307985320-9c246eda01a1',
        ),
        PoiModel(
          id: '033d0c3fde0e',
          name: 'Retreat Spa',
          type: 'spa',
          latitude: 63.8797272,
          longitude: -22.4511796,
          rating: 4.7,
          country: 'IS',
          open: '09:00-20:00',
          image: 'https://images.unsplash.com/photo-1540555700478-4be289fbecef',
        ),

        // Hiking & Adventure
        PoiModel(
          id: 'thorsmork',
          name: 'Þórsmörk Valley',
          type: 'hiking',
          latitude: 63.6833,
          longitude: -19.5167,
          rating: 4.8,
          country: 'IS',
          open: '24/7',
          image: 'https://images.unsplash.com/photo-1531366936337-7c912a4589a7',
        ),
        PoiModel(
          id: '02e1491c4ef2',
          name: 'Eiríksjökull Glacier',
          type: 'hiking',
          latitude: 64.7723182,
          longitude: -20.3988842,
          rating: 4.6,
          country: 'IS',
          open: '24/7',
          image: 'https://images.unsplash.com/photo-1486870591958-9b9d0d1dda99',
        ),

        // Museums
        PoiModel(
          id: '01a27104d5bb',
          name: 'Ljósmyndasafn Reykjavíkur',
          type: 'museum',
          latitude: 64.1494664,
          longitude: -21.9413926,
          rating: 4.4,
          country: 'IS',
          open: '10:00-18:00',
          image: 'https://images.unsplash.com/photo-1564399579883-451a5d44ec08',
        ),
      ];
}
