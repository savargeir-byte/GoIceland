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
    return PoiModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
      type: json['type'] as String? ?? 'unknown',
      latitude: (json['lat'] as num).toDouble(),
      longitude: (json['lon'] as num).toDouble(),
      rating: (json['rating'] as num?)?.toDouble(),
      country: json['country'] as String?,
      open: json['open'] as String?,
      image: json['image'] as String?,
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
