/// Data model for hiking trails in Iceland with polyline geometry and difficulty ratings
class TrailModel {
  final String id;
  final String name;
  final String difficulty; // Easy, Moderate, Hard, Expert
  final double lengthKm;
  final int durationMin;
  final int elevationGain; // meters
  final double startLat;
  final double startLng;
  final String? gpxUrl; // optional hosted GPX file URL
  final List<Map<String, double>> polyline; // list of {lat, lng} coordinates
  final List<String> images;
  final String region;

  TrailModel({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.lengthKm,
    required this.durationMin,
    required this.elevationGain,
    required this.startLat,
    required this.startLng,
    this.gpxUrl,
    this.polyline = const [],
    this.images = const [],
    this.region = '',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'difficulty': difficulty,
        'lengthKm': lengthKm,
        'durationMin': durationMin,
        'elevationGain': elevationGain,
        'startLat': startLat,
        'startLng': startLng,
        'gpxUrl': gpxUrl,
        'polyline':
            polyline.map((p) => {'lat': p['lat'], 'lng': p['lng']}).toList(),
        'images': images,
        'region': region,
      };

  factory TrailModel.fromMap(Map<String, dynamic> m) => TrailModel(
        id: m['id'],
        name: m['name'],
        difficulty: m['difficulty'],
        lengthKm: (m['lengthKm'] as num).toDouble(),
        durationMin: m['durationMin'],
        elevationGain: m['elevationGain'],
        startLat: (m['startLat'] as num).toDouble(),
        startLng: (m['startLng'] as num).toDouble(),
        gpxUrl: m['gpxUrl'],
        polyline: m['polyline'] != null
            ? List<Map<String, double>>.from(m['polyline'].map((p) => {
                  'lat': (p['lat'] as num).toDouble(),
                  'lng': (p['lng'] as num).toDouble()
                }))
            : [],
        images: List<String>.from(m['images'] ?? []),
        region: m['region'] ?? '',
      );

  /// Helper to get difficulty color for UI badges
  String get difficultyColor {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return '#4CAF50';
      case 'moderate':
        return '#FF9800';
      case 'hard':
        return '#F44336';
      case 'expert':
        return '#9C27B0';
      default:
        return '#757575';
    }
  }

  /// Formatted duration for display (e.g., "2h 30m")
  String get formattedDuration {
    final hours = durationMin ~/ 60;
    final minutes = durationMin % 60;
    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }
}
