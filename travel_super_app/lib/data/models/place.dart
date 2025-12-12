import 'package:cloud_firestore/cloud_firestore.dart';

/// 🏔️ Place Model - Iceland POI
class Place {
  final String id;
  final String name;
  final String category;
  final double lat;
  final double lng;
  final String description;
  final double? rating;
  final String? imageUrl;
  final String? country;
  final String? open;
  final List<String>? images;
  final String? source;
  final Map<String, dynamic>? metadata;

  const Place({
    required this.id,
    required this.name,
    required this.category,
    required this.lat,
    required this.lng,
    required this.description,
    this.rating,
    this.imageUrl,
    this.country,
    this.open,
    this.images,
    this.source,
    this.metadata,
  });

  /// Create Place from Firestore document
  factory Place.fromJson(Map<String, dynamic> json) {
    // Handle different coordinate formats
    final lat = json['lat'] ?? json['latitude'];
    final lng = json['lng'] ?? json['lon'] ?? json['longitude'];

    if (lat == null || lng == null) {
      throw FormatException('Missing coordinates for place: ${json['name']}');
    }

    return Place(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
      category: json['category'] as String? ?? json['type'] as String? ?? 'unknown',
      lat: (lat as num).toDouble(),
      lng: (lng as num).toDouble(),
      description: json['description'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble(),
      imageUrl: _extractImageUrl(json),
      country: json['country'] as String? ?? 'Iceland',
      open: json['open'] as String?,
      images: (json['images'] as List<dynamic>?)?.cast<String>(),
      source: json['source'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert Place to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'lat': lat,
      'lng': lng,
      'description': description,
      if (rating != null) 'rating': rating,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (country != null) 'country': country,
      if (open != null) 'open': open,
      if (images != null) 'images': images,
      if (source != null) 'source': source,
      if (metadata != null) 'metadata': metadata,
    };
  }

  /// Extract primary image URL from various formats
  static String? _extractImageUrl(Map<String, dynamic> json) {
    // Try direct imageUrl field
    if (json['imageUrl'] != null) return json['imageUrl'] as String;
    if (json['image'] != null) return json['image'] as String;
    
    // Try images array
    final images = json['images'] as List<dynamic>?;
    if (images != null && images.isNotEmpty) {
      return images.first as String;
    }
    
    return null;
  }

  /// Create copy with updated fields
  Place copyWith({
    String? id,
    String? name,
    String? category,
    double? lat,
    double? lng,
    String? description,
    double? rating,
    String? imageUrl,
    String? country,
    String? open,
    List<String>? images,
    String? source,
    Map<String, dynamic>? metadata,
  }) {
    return Place(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      imageUrl: imageUrl ?? this.imageUrl,
      country: country ?? this.country,
      open: open ?? this.open,
      images: images ?? this.images,
      source: source ?? this.source,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() => 'Place(name: $name, category: $category, lat: $lat, lng: $lng)';
}
