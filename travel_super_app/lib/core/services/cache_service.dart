import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// 📦 CACHE SERVICE - Local database caching for Firebase data
/// Reduces Firebase reads, improves performance, enables offline mode
class CacheService {
  static Database? _database;
  static const String _dbName = 'go_iceland_cache.db';
  static const int _cacheVersion = 1;

  // Cache expiration times
  static const Duration placesExpiration = Duration(hours: 24);
  static const Duration trailsExpiration = Duration(hours: 24);
  static const Duration gpsExpiration = Duration(minutes: 5);

  /// Initialize database
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _cacheVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    // Places cache table
    await db.execute('''
      CREATE TABLE places_cache (
        id TEXT PRIMARY KEY,
        data TEXT NOT NULL,
        cached_at INTEGER NOT NULL
      )
    ''');

    // Trails cache table
    await db.execute('''
      CREATE TABLE trails_cache (
        id TEXT PRIMARY KEY,
        data TEXT NOT NULL,
        cached_at INTEGER NOT NULL
      )
    ''');

    // GPS cache table
    await db.execute('''
      CREATE TABLE gps_cache (
        id TEXT PRIMARY KEY,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        accuracy REAL,
        cached_at INTEGER NOT NULL
      )
    ''');

    print('✅ Cache database created');
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
    if (oldVersion < newVersion) {
      print('⬆️ Upgrading cache database from v$oldVersion to v$newVersion');
    }
  }

  // ========== PLACES CACHE ==========

  /// Cache all places from Firebase
  static Future<void> cachePlaces(List<Map<String, dynamic>> places) async {
    final db = await database;
    final batch = db.batch();
    final now = DateTime.now().millisecondsSinceEpoch;

    for (var place in places) {
      final id = place['id'] ?? place['name'] ?? 'unknown';
      batch.insert(
        'places_cache',
        {
          'id': id,
          'data': jsonEncode(place),
          'cached_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
    print('📦 Cached ${places.length} places');
  }

  /// Get cached places if not expired
  static Future<List<Map<String, dynamic>>?> getCachedPlaces() async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final expirationTime = now - placesExpiration.inMilliseconds;

    final results = await db.query(
      'places_cache',
      where: 'cached_at > ?',
      whereArgs: [expirationTime],
    );

    if (results.isEmpty) {
      print('❌ No cached places or cache expired');
      return null;
    }

    final places = results.map((row) {
      return jsonDecode(row['data'] as String) as Map<String, dynamic>;
    }).toList();

    print('✅ Retrieved ${places.length} places from cache');
    return places;
  }

  /// Clear places cache
  static Future<void> clearPlacesCache() async {
    final db = await database;
    await db.delete('places_cache');
    print('🗑️ Cleared places cache');
  }

  // ========== TRAILS CACHE ==========

  /// Cache all trails from Firebase
  static Future<void> cacheTrails(List<Map<String, dynamic>> trails) async {
    final db = await database;
    final batch = db.batch();
    final now = DateTime.now().millisecondsSinceEpoch;

    for (var trail in trails) {
      final id = trail['id'] ?? trail['name'] ?? 'unknown';
      batch.insert(
        'trails_cache',
        {
          'id': id,
          'data': jsonEncode(trail),
          'cached_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
    print('📦 Cached ${trails.length} trails');
  }

  /// Get cached trails if not expired
  static Future<List<Map<String, dynamic>>?> getCachedTrails() async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final expirationTime = now - trailsExpiration.inMilliseconds;

    final results = await db.query(
      'trails_cache',
      where: 'cached_at > ?',
      whereArgs: [expirationTime],
    );

    if (results.isEmpty) {
      print('❌ No cached trails or cache expired');
      return null;
    }

    final trails = results.map((row) {
      return jsonDecode(row['data'] as String) as Map<String, dynamic>;
    }).toList();

    print('✅ Retrieved ${trails.length} trails from cache');
    return trails;
  }

  /// Clear trails cache
  static Future<void> clearTrailsCache() async {
    final db = await database;
    await db.delete('trails_cache');
    print('🗑️ Cleared trails cache');
  }

  // ========== GPS CACHE ==========

  /// Cache GPS location
  static Future<void> cacheGPSLocation({
    required double latitude,
    required double longitude,
    double? accuracy,
  }) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.insert(
      'gps_cache',
      {
        'id': 'current_location',
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': accuracy,
        'cached_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    print('📍 Cached GPS: $latitude, $longitude');
  }

  /// Get cached GPS location if not expired
  static Future<Map<String, dynamic>?> getCachedGPSLocation() async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final expirationTime = now - gpsExpiration.inMilliseconds;

    final results = await db.query(
      'gps_cache',
      where: 'id = ? AND cached_at > ?',
      whereArgs: ['current_location', expirationTime],
    );

    if (results.isEmpty) {
      print('❌ No cached GPS or cache expired');
      return null;
    }

    final location = results.first;
    print('✅ Retrieved GPS from cache: ${location['latitude']}, ${location['longitude']}');
    return {
      'latitude': location['latitude'] as double,
      'longitude': location['longitude'] as double,
      'accuracy': location['accuracy'] as double?,
    };
  }

  // ========== UTILITY ==========

  /// Clear all caches
  static Future<void> clearAllCache() async {
    await clearPlacesCache();
    await clearTrailsCache();
    final db = await database;
    await db.delete('gps_cache');
    print('🗑️ Cleared all caches');
  }

  /// Get cache statistics
  static Future<Map<String, int>> getCacheStats() async {
    final db = await database;
    
    final placesCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM places_cache'),
    ) ?? 0;
    
    final trailsCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM trails_cache'),
    ) ?? 0;
    
    final gpsCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM gps_cache'),
    ) ?? 0;

    return {
      'places': placesCount,
      'trails': trailsCount,
      'gps': gpsCount,
    };
  }

  /// Close database
  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      print('🔒 Cache database closed');
    }
  }
}
