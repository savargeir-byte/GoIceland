import 'package:cloud_firestore/cloud_firestore.dart';

/// 📍 Enhanced Place model for admin management
class AdminPlace {
  final String id;
  final String name;
  final String category;
  final double lat;
  final double lng;

  // Multi-language content
  final Map<String, PlaceContent> content;

  // Media
  final PlaceImages images;

  // Metadata
  final List<String> services;
  final List<String> tags;
  final String? region;
  final double? rating;

  // Audit trail
  final DateTime? updatedAt;
  final String? updatedBy;

  const AdminPlace({
    required this.id,
    required this.name,
    required this.category,
    required this.lat,
    required this.lng,
    this.content = const {},
    this.images = const PlaceImages(),
    this.services = const [],
    this.tags = const [],
    this.region,
    this.rating,
    this.updatedAt,
    this.updatedBy,
  });

  factory AdminPlace.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Parse content
    Map<String, PlaceContent> contentMap = {};
    final contentData = data['content'] as Map<String, dynamic>?;
    if (contentData != null) {
      contentData.forEach((lang, value) {
        if (value is Map) {
          contentMap[lang] =
              PlaceContent.fromMap(value as Map<String, dynamic>);
        }
      });
    }

    // Parse images
    final images = data['images'] != null
        ? PlaceImages.fromMap(data['images'] as Map<String, dynamic>)
        : const PlaceImages();

    return AdminPlace(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? data['type'] ?? 'unknown',
      lat: (data['lat'] ?? data['latitude'] ?? 0).toDouble(),
      lng: (data['lng'] ?? data['lon'] ?? data['longitude'] ?? 0).toDouble(),
      content: contentMap,
      images: images,
      services: List<String>.from(data['services'] ?? []),
      tags: List<String>.from(data['tags'] ?? []),
      region: data['region'],
      rating: (data['rating'] as num?)?.toDouble(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      updatedBy: data['updatedBy'],
    );
  }

  Map<String, dynamic> toFirestore() {
    final contentMap = <String, dynamic>{};
    content.forEach((lang, value) {
      contentMap[lang] = value.toMap();
    });

    return {
      'name': name,
      'category': category,
      'type': category,
      'lat': lat,
      'lng': lng,
      'lon': lng,
      'latitude': lat,
      'longitude': lng,
      'content': contentMap,
      'images': images.toMap(),
      'services': services,
      'tags': tags,
      if (region != null) 'region': region,
      if (rating != null) 'rating': rating,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  AdminPlace copyWith({
    String? name,
    String? category,
    double? lat,
    double? lng,
    Map<String, PlaceContent>? content,
    PlaceImages? images,
    List<String>? services,
    List<String>? tags,
    String? region,
    double? rating,
  }) {
    return AdminPlace(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      content: content ?? this.content,
      images: images ?? this.images,
      services: services ?? this.services,
      tags: tags ?? this.tags,
      region: region ?? this.region,
      rating: rating ?? this.rating,
      updatedAt: updatedAt,
      updatedBy: updatedBy,
    );
  }
}

/// 📝 Multi-language content for a place
class PlaceContent {
  final String? description;
  final String? history;
  final String? tips;
  final String? warnings;

  const PlaceContent({
    this.description,
    this.history,
    this.tips,
    this.warnings,
  });

  factory PlaceContent.fromMap(Map<String, dynamic> map) {
    return PlaceContent(
      description: map['description'],
      history: map['history'],
      tips: map['tips'],
      warnings: map['warnings'],
    );
  }

  Map<String, dynamic> toMap() => {
        if (description != null) 'description': description,
        if (history != null) 'history': history,
        if (tips != null) 'tips': tips,
        if (warnings != null) 'warnings': warnings,
      };
}

/// 🖼️ Place images
class PlaceImages {
  final String? cover;
  final List<String> gallery;

  const PlaceImages({
    this.cover,
    this.gallery = const [],
  });

  factory PlaceImages.fromMap(Map<String, dynamic> map) {
    return PlaceImages(
      cover: map['cover'] ?? map['hero_image'],
      gallery: List<String>.from(map['gallery'] ?? map['images'] ?? []),
    );
  }

  Map<String, dynamic> toMap() => {
        if (cover != null) 'cover': cover,
        'gallery': gallery,
        // Backward compatibility
        if (cover != null) 'hero_image': cover,
        if (gallery.isNotEmpty) 'images': gallery,
      };
}
