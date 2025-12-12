/// 🥾 Trail Model - Hiking routes in Iceland
class Trail {
  final String id;
  final String name;
  final String difficulty; // 'easy', 'moderate', 'hard'
  final double distance; // km
  final int duration; // minutes
  final double? elevation; // meters
  final String description;
  final String? imageUrl;
  final List<String>? images;
  final List<TrailPoint> route;
  final double? rating;
  final String? region;
  final bool isCircular;
  final String? trailhead;
  final Map<String, dynamic>? metadata;

  const Trail({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.distance,
    required this.duration,
    required this.description,
    required this.route,
    this.elevation,
    this.imageUrl,
    this.images,
    this.rating,
    this.region,
    this.isCircular = false,
    this.trailhead,
    this.metadata,
  });

  /// Create Trail from Firestore document
  factory Trail.fromJson(Map<String, dynamic> json) {
    final routeData = json['route'] as List<dynamic>? ?? [];
    final route = routeData
        .map((point) => TrailPoint.fromJson(point as Map<String, dynamic>))
        .toList();

    return Trail(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown Trail',
      difficulty: json['difficulty'] as String? ?? 'moderate',
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      duration: json['duration'] as int? ?? 0,
      elevation: (json['elevation'] as num?)?.toDouble(),
      description: json['description'] as String? ?? '',
      imageUrl: _extractImageUrl(json),
      images: (json['images'] as List<dynamic>?)?.cast<String>(),
      route: route,
      rating: (json['rating'] as num?)?.toDouble(),
      region: json['region'] as String?,
      isCircular: json['isCircular'] as bool? ?? false,
      trailhead: json['trailhead'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert Trail to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'difficulty': difficulty,
      'distance': distance,
      'duration': duration,
      'description': description,
      'route': route.map((p) => p.toJson()).toList(),
      if (elevation != null) 'elevation': elevation,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (images != null) 'images': images,
      if (rating != null) 'rating': rating,
      if (region != null) 'region': region,
      'isCircular': isCircular,
      if (trailhead != null) 'trailhead': trailhead,
      if (metadata != null) 'metadata': metadata,
    };
  }

  static String? _extractImageUrl(Map<String, dynamic> json) {
    if (json['imageUrl'] != null) return json['imageUrl'] as String;
    if (json['image'] != null) return json['image'] as String;
    
    final images = json['images'] as List<dynamic>?;
    if (images != null && images.isNotEmpty) {
      return images.first as String;
    }
    
    return null;
  }

  /// Get formatted duration string (e.g., "2h 30min")
  String get formattedDuration {
    final hours = duration ~/ 60;
    final minutes = duration % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}min';
    }
    return '${minutes}min';
  }

  /// Get formatted distance string (e.g., "5.2 km")
  String get formattedDistance => '${distance.toStringAsFixed(1)} km';

  @override
  String toString() => 'Trail(name: $name, difficulty: $difficulty, distance: ${formattedDistance})';
}

/// 📍 Trail Point - GPS coordinate on a trail route
class TrailPoint {
  final double lat;
  final double lng;
  final double? elevation;
  final String? name; // Optional waypoint name

  const TrailPoint({
    required this.lat,
    required this.lng,
    this.elevation,
    this.name,
  });

  factory TrailPoint.fromJson(Map<String, dynamic> json) {
    return TrailPoint(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      elevation: (json['elevation'] as num?)?.toDouble(),
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
      if (elevation != null) 'elevation': elevation,
      if (name != null) 'name': name,
    };
  }

  @override
  String toString() => 'TrailPoint(lat: $lat, lng: $lng)';
}
