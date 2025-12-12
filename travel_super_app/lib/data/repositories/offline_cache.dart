import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/place.dart';
import '../models/trail.dart';

/// 💾 Offline Cache - Local storage for offline access
class OfflineCache {
  static const String _placesKey = 'offline_places';
  static const String _trailsKey = 'offline_trails';
  static const String _lastSyncKey = 'last_sync_timestamp';

  final SharedPreferences _prefs;

  OfflineCache(this._prefs);

  /// Initialize offline cache
  static Future<OfflineCache> init() async {
    final prefs = await SharedPreferences.getInstance();
    return OfflineCache(prefs);
  }

  // ============================================================
  // PLACES CACHE
  // ============================================================

  /// Save places to local cache
  Future<void> savePlaces(List<Place> places) async {
    try {
      final jsonList = places.map((p) => p.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await _prefs.setString(_placesKey, jsonString);
      await _updateLastSync();
      print('✅ Cached ${places.length} places offline');
    } catch (e) {
      print('❌ Error saving places to cache: $e');
    }
  }

  /// Load places from local cache
  Future<List<Place>> loadPlaces() async {
    try {
      final jsonString = _prefs.getString(_placesKey);
      if (jsonString == null) return [];

      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => Place.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ Error loading places from cache: $e');
      return [];
    }
  }

  /// Check if places are cached
  bool get hasPlacesCache => _prefs.containsKey(_placesKey);

  /// Get cached places count
  Future<int> getPlacesCount() async {
    final places = await loadPlaces();
    return places.length;
  }

  // ============================================================
  // TRAILS CACHE
  // ============================================================

  /// Save trails to local cache
  Future<void> saveTrails(List<Trail> trails) async {
    try {
      final jsonList = trails.map((t) => t.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await _prefs.setString(_trailsKey, jsonString);
      await _updateLastSync();
      print('✅ Cached ${trails.length} trails offline');
    } catch (e) {
      print('❌ Error saving trails to cache: $e');
    }
  }

  /// Load trails from local cache
  Future<List<Trail>> loadTrails() async {
    try {
      final jsonString = _prefs.getString(_trailsKey);
      if (jsonString == null) return [];

      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => Trail.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ Error loading trails from cache: $e');
      return [];
    }
  }

  /// Check if trails are cached
  bool get hasTrailsCache => _prefs.containsKey(_trailsKey);

  /// Get cached trails count
  Future<int> getTrailsCount() async {
    final trails = await loadTrails();
    return trails.length;
  }

  // ============================================================
  // SYNC MANAGEMENT
  // ============================================================

  /// Update last sync timestamp
  Future<void> _updateLastSync() async {
    await _prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Get last sync time
  DateTime? get lastSyncTime {
    final timestamp = _prefs.getInt(_lastSyncKey);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  /// Check if cache is stale (older than 7 days)
  bool get isCacheStale {
    final lastSync = lastSyncTime;
    if (lastSync == null) return true;
    
    final daysSinceSync = DateTime.now().difference(lastSync).inDays;
    return daysSinceSync > 7;
  }

  /// Get formatted last sync time
  String get lastSyncFormatted {
    final lastSync = lastSyncTime;
    if (lastSync == null) return 'Never';
    
    final now = DateTime.now();
    final diff = now.difference(lastSync);
    
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} minutes ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} hours ago';
    } else {
      return '${diff.inDays} days ago';
    }
  }

  // ============================================================
  // CACHE MANAGEMENT
  // ============================================================

  /// Clear all cached data
  Future<void> clearCache() async {
    try {
      await _prefs.remove(_placesKey);
      await _prefs.remove(_trailsKey);
      await _prefs.remove(_lastSyncKey);
      print('✅ Cleared offline cache');
    } catch (e) {
      print('❌ Error clearing cache: $e');
    }
  }

  /// Get cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    final placesCount = await getPlacesCount();
    final trailsCount = await getTrailsCount();
    final lastSync = lastSyncTime;
    
    return {
      'placesCount': placesCount,
      'trailsCount': trailsCount,
      'lastSync': lastSync?.toIso8601String(),
      'lastSyncFormatted': lastSyncFormatted,
      'isCacheStale': isCacheStale,
      'hasPlacesCache': hasPlacesCache,
      'hasTrailsCache': hasTrailsCache,
    };
  }

  /// Check if offline mode is available
  bool get isOfflineAvailable => hasPlacesCache || hasTrailsCache;
}
