import 'package:equatable/equatable.dart';

class PoiModel extends Equatable {
  const PoiModel({
    required this.id,
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    this.rating,
    this.country,
    this.open,
    this.image,
  });

  final String id;
  final String name;
  final String type;
  final double latitude;
  final double longitude;
  final double? rating;
  final String? country;
  final String? open;
  final String? image;

  factory PoiModel.fromJson(Map<String, dynamic> json) {
    // Handle different coordinate formats
    final coords = json['coordinates'] as Map<String, dynamic>?;
    final lat = coords?['lat'] ?? json['lat'] ?? json['latitude'];
    final lng = coords?['lng'] ?? coords?['lon'] ?? json['lon'] ?? json['lng'] ?? json['longitude'];
    
    // Skip if no valid coordinates
    if (lat == null || lng == null) {
      throw FormatException('Missing coordinates for POI: ${json['name']}');
    }
    
    return PoiModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
      type: json['category'] as String? ?? json['type'] as String? ?? 'unknown',
      latitude: (lat as num).toDouble(),
      longitude: (lng as num).toDouble(),
      rating: (json['rating'] as num?)?.toDouble(),
      country: json['country'] as String?,
      open: json['open'] as String?,
      image: (json['images'] as List?)?.isNotEmpty == true
          ? json['images'][0]
          : json['image'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'lat': latitude,
        'lon': longitude,
        'rating': rating,
        'country': country,
        'open': open,
        'image': image,
      };

  @override
  List<Object?> get props => [id, name, type, latitude, longitude];
}
