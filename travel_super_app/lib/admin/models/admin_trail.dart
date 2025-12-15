import 'package:cloud_firestore/cloud_firestore.dart';

/// Trail content for multi-language support
class TrailContent {
  final String? description;
  final String? history;
  final String? tips;
  final String? safety;

  TrailContent({
    this.description,
    this.history,
    this.tips,
    this.safety,
  });

  factory TrailContent.fromMap(Map<String, dynamic> map) {
    return TrailContent(
      description: map['description'],
      history: map['history'],
      tips: map['tips'],
      safety: map['safety'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (description != null) 'description': description,
      if (history != null) 'history': history,
      if (tips != null) 'tips': tips,
      if (safety != null) 'safety': safety,
    };
  }
}

/// 🥾 Trail model for admin panel
class AdminTrail {
  final String id;
  final String name;
  final String? difficulty;
  final double? lengthKm;
  final int? durationMin;
  final int? elevationGain;
  final String? region;
  final Map<String, TrailContent> content;
  final List<String> images;
  final String? coverImage;
  final String? mapImage; // OpenStreetMap embed URL
  final double? startLat;
  final double? startLng;
  final String? gpxUrl;
  final bool? hasCamping;
  final List<dynamic>? polyline;

  AdminTrail({
    required this.id,
    required this.name,
    this.difficulty,
    this.lengthKm,
    this.durationMin,
    this.elevationGain,
    this.region,
    Map<String, TrailContent>? content,
    List<String>? images,
    this.coverImage,
    this.mapImage,
    this.startLat,
    this.startLng,
    this.gpxUrl,
    this.hasCamping,
    this.polyline,
  })  : content = content ?? {},
        images = images ?? [];

  factory AdminTrail.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Parse content (multi-language)
    final contentMap = <String, TrailContent>{};
    if (data['content'] != null) {
      (data['content'] as Map<String, dynamic>).forEach((lang, content) {
        if (content is Map<String, dynamic>) {
          contentMap[lang] = TrailContent.fromMap(content);
        }
      });
    }

    // Parse images
    List<String> imagesList = [];
    if (data['images'] is List) {
      imagesList = (data['images'] as List).map((e) => e.toString()).toList();
    } else if (data['images'] is Map && data['images']['gallery'] is List) {
      imagesList =
          (data['images']['gallery'] as List).map((e) => e.toString()).toList();
    }

    return AdminTrail(
      id: doc.id,
      name: data['name'] ?? '',
      difficulty: data['difficulty'],
      lengthKm: (data['lengthKm'] ?? data['length_km'])?.toDouble(),
      durationMin: data['durationMin'] ?? data['duration_min'],
      elevationGain: data['elevationGain'] ?? data['elevation_gain'],
      region: data['region'],
      content: contentMap,
      images: imagesList,
      coverImage: data['images'] is Map
          ? data['images']['cover']
          : (imagesList.isNotEmpty ? imagesList.first : null),
      mapImage:
          data['mapImage'] ?? data['map_preview'], // Support both field names
      startLat: data['startLat']?.toDouble() ?? data['start_lat']?.toDouble(),
      startLng: data['startLng']?.toDouble() ?? data['start_lng']?.toDouble(),
      gpxUrl: data['gpxUrl'] ?? data['gpx_url'],
      hasCamping: data['hasCamping'] ?? data['has_camping'],
      polyline: data['polyline'],
    );
  }

  String get displayLength {
    if (lengthKm == null) return 'N/A';
    return '${lengthKm!.toStringAsFixed(1)} km';
  }

  String get displayDuration {
    if (durationMin == null) return 'N/A';
    final hours = durationMin! ~/ 60;
    final minutes = durationMin! % 60;
    if (hours == 0) return '${minutes}m';
    if (minutes == 0) return '${hours}h';
    return '${hours}h ${minutes}m';
  }

  String get displayElevation {
    if (elevationGain == null) return 'N/A';
    return '${elevationGain}m';
  }

  String get difficultyEmoji {
    switch (difficulty?.toLowerCase()) {
      case 'easy':
        return '🟢';
      case 'moderate':
        return '🟡';
      case 'hard':
        return '🟠';
      case 'expert':
        return '🔴';
      default:
        return '⚪';
    }
  }
}
