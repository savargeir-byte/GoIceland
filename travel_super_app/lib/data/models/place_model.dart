/// Data model for places (POIs) in Iceland - waterfalls, hot springs, viewpoints, restaurants, etc.
class PlaceModel {
  final String id;
  final String name;
  final String
      type; // waterfall, hot_spring, viewpoint, restaurant, trail_head, etc.
  final double lat;
  final double lng;
  final double? rating;
  final List<String> images;
  final String? description;
  final Map<String, dynamic>? meta; // openHours, fees, region, etc.

  PlaceModel({
    required this.id,
    required this.name,
    required this.type,
    required this.lat,
    required this.lng,
    this.rating,
    this.images = const [],
    this.description,
    this.meta,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'type': type,
        'lat': lat,
        'lng': lng,
        'rating': rating,
        'images': images,
        'description': description,
        'meta': meta,
      };

  factory PlaceModel.fromMap(Map<String, dynamic> m) => PlaceModel(
        id: m['id'],
        name: m['name'],
        type: m['type'],
        lat: (m['lat'] as num).toDouble(),
        lng: (m['lng'] as num).toDouble(),
        rating: m['rating'] != null ? (m['rating'] as num).toDouble() : null,
        images: List<String>.from(m['images'] ?? []),
        description: m['description'],
        meta: m['meta'] != null ? Map<String, dynamic>.from(m['meta']) : null,
      );

  /// Create PlaceModel from Firestore document data
  factory PlaceModel.fromFirestore(Map<String, dynamic> data) =>
      PlaceModel.fromMap(data);

  /// Converts PlaceModel to PoiModel for backward compatibility with existing code
  /// Remove this once all code is migrated to use PlaceModel
  Map<String, dynamic> toPoiModel() => {
        'id': id,
        'name': name,
        'latitude': lat,
        'longitude': lng,
        'image': images.isNotEmpty ? images.first : '',
        'rating': rating,
      };
}
