import 'package:hive_flutter/hive_flutter.dart';

/// 📦 OFFLINE SERVICE - Cache places & trails for offline use
/// Uses Hive for local storage
class OfflineService {
  static const String _placesBox = 'places';
  static const String _trailsBox = 'trails';
  static const String _settingsBox = 'settings';

  /// Initialize Hive
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_placesBox);
    await Hive.openBox(_trailsBox);
    await Hive.openBox(_settingsBox);
  }

  // ==================== PLACES ====================

  /// Save places to local cache
  static Future<void> savePlaces(List<Map<String, dynamic>> places) async {
    final box = await Hive.openBox(_placesBox);
    for (var place in places) {
      final id = place['id'] ?? place['name'];
      await box.put(id, place);
    }
  }

  /// Save single place
  static Future<void> savePlace(Map<String, dynamic> place) async {
    final box = await Hive.openBox(_placesBox);
    final id = place['id'] ?? place['name'];
    await box.put(id, place);
  }

  /// Load all cached places
  static Future<List<Map<String, dynamic>>> loadPlaces() async {
    final box = await Hive.openBox(_placesBox);
    return box.values.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  /// Get single place by ID
  static Future<Map<String, dynamic>?> getPlace(String id) async {
    final box = await Hive.openBox(_placesBox);
    final data = box.get(id);
    return data != null ? Map<String, dynamic>.from(data as Map) : null;
  }

  /// Check if place is cached
  static Future<bool> isPlaceCached(String id) async {
    final box = await Hive.openBox(_placesBox);
    return box.containsKey(id);
  }

  /// Delete place from cache
  static Future<void> deletePlace(String id) async {
    final box = await Hive.openBox(_placesBox);
    await box.delete(id);
  }

  /// Clear all places
  static Future<void> clearPlaces() async {
    final box = await Hive.openBox(_placesBox);
    await box.clear();
  }

  // ==================== TRAILS ====================

  /// Save trails to local cache
  static Future<void> saveTrails(List<Map<String, dynamic>> trails) async {
    final box = await Hive.openBox(_trailsBox);
    for (var trail in trails) {
      final id = trail['id'] ?? trail['name'];
      await box.put(id, trail);
    }
  }

  /// Save single trail
  static Future<void> saveTrail(Map<String, dynamic> trail) async {
    final box = await Hive.openBox(_trailsBox);
    final id = trail['id'] ?? trail['name'];
    await box.put(id, trail);
  }

  /// Load all cached trails
  static Future<List<Map<String, dynamic>>> loadTrails() async {
    final box = await Hive.openBox(_trailsBox);
    return box.values.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  /// Get single trail by ID
  static Future<Map<String, dynamic>?> getTrail(String id) async {
    final box = await Hive.openBox(_trailsBox);
    final data = box.get(id);
    return data != null ? Map<String, dynamic>.from(data as Map) : null;
  }

  /// Check if trail is cached
  static Future<bool> isTrailCached(String id) async {
    final box = await Hive.openBox(_trailsBox);
    return box.containsKey(id);
  }

  /// Delete trail from cache
  static Future<void> deleteTrail(String id) async {
    final box = await Hive.openBox(_trailsBox);
    await box.delete(id);
  }

  /// Clear all trails
  static Future<void> clearTrails() async {
    final box = await Hive.openBox(_trailsBox);
    await box.clear();
  }

  // ==================== SETTINGS ====================

  /// Save last sync timestamp
  static Future<void> setLastSyncTime(DateTime time) async {
    final box = await Hive.openBox(_settingsBox);
    await box.put('last_sync', time.toIso8601String());
  }

  /// Get last sync timestamp
  static Future<DateTime?> getLastSyncTime() async {
    final box = await Hive.openBox(_settingsBox);
    final timeStr = box.get('last_sync') as String?;
    return timeStr != null ? DateTime.parse(timeStr) : null;
  }

  /// Mark region as downloaded
  static Future<void> markRegionDownloaded(String region) async {
    final box = await Hive.openBox(_settingsBox);
    final regions =
        box.get('downloaded_regions', defaultValue: <String>[]) as List;
    if (!regions.contains(region)) {
      regions.add(region);
      await box.put('downloaded_regions', regions);
    }
  }

  /// Get downloaded regions
  static Future<List<String>> getDownloadedRegions() async {
    final box = await Hive.openBox(_settingsBox);
    final regions =
        box.get('downloaded_regions', defaultValue: <String>[]) as List;
    return regions.cast<String>();
  }

  /// Check if region is downloaded
  static Future<bool> isRegionDownloaded(String region) async {
    final regions = await getDownloadedRegions();
    return regions.contains(region);
  }

  // ==================== STATS ====================

  /// Get cache statistics
  static Future<Map<String, int>> getCacheStats() async {
    final placesBox = await Hive.openBox(_placesBox);
    final trailsBox = await Hive.openBox(_trailsBox);

    return {
      'places': placesBox.length,
      'trails': trailsBox.length,
      'total': placesBox.length + trailsBox.length,
    };
  }

  /// Calculate cache size (approximate)
  static Future<String> getCacheSize() async {
    final stats = await getCacheStats();
    final totalItems = stats['total'] ?? 0;
    // Rough estimate: ~5KB per item
    final sizeKB = totalItems * 5;
    if (sizeKB < 1024) {
      return '$sizeKB KB';
    } else {
      return '${(sizeKB / 1024).toStringAsFixed(1)} MB';
    }
  }

  /// Clear all offline data
  static Future<void> clearAll() async {
    await clearPlaces();
    await clearTrails();
    final settingsBox = await Hive.openBox(_settingsBox);
    await settingsBox.clear();
  }
}
