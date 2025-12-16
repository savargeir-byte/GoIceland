import 'package:equatable/equatable.dart';

/// 🌟 FULLUR POI MODEL með öllum upplýsingum
/// - Description (short, history, geology, culture)
/// - Services (parking, toilet, wheelchair, etc.)
/// - Visit info (best time, crowds, duration)
/// - Media (images, thumbnail, hero)
/// - Ratings (Google, TripAdvisor)

class PoiModelFull extends Equatable {
  const PoiModelFull({
    required this.id,
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    this.description,
    this.services,
    this.visitInfo,
    this.media,
    this.rating,
    this.ratings,
    this.country,
    this.open,
    this.sources,
    this.wikipediaUrl,
  });

  final String id;
  final String name;
  final String type;
  final double latitude;
  final double longitude;
  final PoiDescription? description;
  final PoiServices? services;
  final VisitInfo? visitInfo;
  final PoiMedia? media;
  final double? rating;
  final Ratings? ratings;
  final String? country;
  final String? open;
  final List<String>? sources;
  final String? wikipediaUrl;

  // Quick access to image
  String? get image => media?.heroImage ?? media?.images?.first;
  List<String>? get images => media?.images;

  factory PoiModelFull.fromJson(Map<String, dynamic> json) {
    // Handle coordinates
    final coords = json['coordinates'] as Map<String, dynamic>?;
    final lat = coords?['lat'] ?? json['lat'] ?? json['latitude'];
    final lng = coords?['lng'] ??
        coords?['lon'] ??
        json['lon'] ??
        json['lng'] ??
        json['longitude'];

    if (lat == null || lng == null) {
      throw FormatException('Missing coordinates for POI: ${json['name']}');
    }

    // Handle description from both old and new format
    PoiDescription? description;
    if (json['description'] != null && json['description'] is Map) {
      description = PoiDescription.fromJson(json['description']);
    } else if (json['content'] != null && json['content'] is Map) {
      // New format: content.en.description, content.en.history, etc.
      description = PoiDescription.fromContent(json['content']);
    }

    return PoiModelFull(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
      type: json['category'] as String? ?? json['type'] as String? ?? 'unknown',
      latitude: (lat as num).toDouble(),
      longitude: (lng as num).toDouble(),
      description: description,
      services: json['services'] != null && json['services'] is Map
          ? PoiServices.fromJson(json['services'])
          : null,
      visitInfo: json['visit_info'] != null && json['visit_info'] is Map
          ? VisitInfo.fromJson(json['visit_info'])
          : null,
      media: json['media'] != null && json['media'] is Map
          ? PoiMedia.fromJson(json['media'])
          : PoiMedia.fromLegacy(json), // Fallback for old format
      rating: (json['rating'] as num?)?.toDouble(),
      ratings: json['ratings'] != null && json['ratings'] is Map
          ? Ratings.fromJson(json['ratings'])
          : null,
      country: json['country'] as String?,
      open: json['open'] as String?,
      sources: (json['sources'] as List?)?.map((e) => e.toString()).toList(),
      wikipediaUrl: json['wikipedia_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'lat': latitude,
        'lon': longitude,
        'description': description?.toJson(),
        'services': services?.toJson(),
        'visit_info': visitInfo?.toJson(),
        'media': media?.toJson(),
        'rating': rating,
        'ratings': ratings?.toJson(),
        'country': country,
        'open': open,
        'sources': sources,
        'wikipedia_url': wikipediaUrl,
      };

  @override
  List<Object?> get props => [id, name, type, latitude, longitude];
}

/// 📝 Lýsingar og sögulegar upplýsingar
class PoiDescription extends Equatable {
  const PoiDescription({
    this.short,
    this.history,
    this.geology,
    this.culture,
  });

  final String? short;
  final String? history;
  final String? geology;
  final String? culture;

  factory PoiDescription.fromJson(Map<String, dynamic> json) => PoiDescription(
        short: json['short'] as String?,
        history: json['history'] as String?,
        geology: json['geology'] as String?,
        culture: json['culture'] as String?,
      );

  /// Parse from new content.en structure
  factory PoiDescription.fromContent(Map<String, dynamic> content) {
    final en = content['en'] as Map<String, dynamic>?;
    if (en == null) return const PoiDescription();

    return PoiDescription(
      short: en['description'] as String?,
      history: en['history'] as String?,
      geology: en['geology'] as String?,
      culture: en['culture'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'short': short,
        'history': history,
        'geology': geology,
        'culture': culture,
      };

  @override
  List<Object?> get props => [short, history, geology, culture];
}

/// 🛠️ Þjónusta og aðstaða
class PoiServices extends Equatable {
  const PoiServices({
    this.parking = false,
    this.toilet = false,
    this.restaurantNearby = false,
    this.wheelchairAccess = false,
    this.guidedTours = false,
    this.camping = false,
    this.wifi = false,
    this.atm = false,
    this.information = false,
    this.shelter = false,
  });

  final bool parking;
  final bool toilet;
  final bool restaurantNearby;
  final bool wheelchairAccess;
  final bool guidedTours;
  final bool camping;
  final bool wifi;
  final bool atm;
  final bool information;
  final bool shelter;

  factory PoiServices.fromJson(Map<String, dynamic> json) => PoiServices(
        parking: json['parking'] as bool? ?? false,
        toilet: json['toilet'] as bool? ?? false,
        restaurantNearby: json['restaurant_nearby'] as bool? ?? false,
        wheelchairAccess: json['wheelchair_access'] as bool? ?? false,
        guidedTours: json['guided_tours'] as bool? ?? false,
        camping: json['camping'] as bool? ?? false,
        wifi: json['wifi'] as bool? ?? false,
        atm: json['atm'] as bool? ?? false,
        information: json['information'] as bool? ?? false,
        shelter: json['shelter'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'parking': parking,
        'toilet': toilet,
        'restaurant_nearby': restaurantNearby,
        'wheelchair_access': wheelchairAccess,
        'guided_tours': guidedTours,
        'camping': camping,
        'wifi': wifi,
        'atm': atm,
        'information': information,
        'shelter': shelter,
      };

  int get availableCount => [
        parking,
        toilet,
        restaurantNearby,
        wheelchairAccess,
        guidedTours,
        camping,
        wifi,
        atm,
        information,
        shelter
      ].where((e) => e).length;

  @override
  List<Object?> get props => [
        parking,
        toilet,
        restaurantNearby,
        wheelchairAccess,
        guidedTours,
        camping,
        wifi,
        atm,
        information,
        shelter
      ];
}

/// ⏰ Upplýsingar um heimsókn
class VisitInfo extends Equatable {
  const VisitInfo({
    this.bestTime,
    this.crowds,
    this.entryFee = false,
    this.suggestedDuration,
  });

  final String? bestTime;
  final String? crowds;
  final bool entryFee;
  final String? suggestedDuration;

  factory VisitInfo.fromJson(Map<String, dynamic> json) => VisitInfo(
        bestTime: json['best_time'] as String?,
        crowds: json['crowds'] as String?,
        entryFee: json['entry_fee'] as bool? ?? false,
        suggestedDuration: json['suggested_duration'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'best_time': bestTime,
        'crowds': crowds,
        'entry_fee': entryFee,
        'suggested_duration': suggestedDuration,
      };

  @override
  List<Object?> get props => [bestTime, crowds, entryFee, suggestedDuration];
}

/// 🖼️ Myndir og media
class PoiMedia extends Equatable {
  const PoiMedia({
    this.images,
    this.thumbnail,
    this.heroImage,
  });

  final List<String>? images;
  final String? thumbnail;
  final String? heroImage;

  factory PoiMedia.fromJson(Map<String, dynamic> json) => PoiMedia(
        images: (json['images'] as List?)?.map((e) => e.toString()).toList(),
        thumbnail: json['thumbnail'] as String?,
        heroImage: json['hero_image'] as String?,
      );

  // Fallback for old format (image, images fields at root)
  factory PoiMedia.fromLegacy(Map<String, dynamic> json) {
    final images = (json['images'] as List?)?.map((e) => e.toString()).toList();
    final image = json['image'] as String?;

    return PoiMedia(
      images: images ?? (image != null ? [image] : null),
      heroImage: images?.isNotEmpty == true ? images!.first : image,
      thumbnail: image,
    );
  }

  Map<String, dynamic> toJson() => {
        'images': images,
        'thumbnail': thumbnail,
        'hero_image': heroImage,
      };

  @override
  List<Object?> get props => [images, thumbnail, heroImage];
}

/// ⭐ Ratings frá mismunandi heimild
class Ratings extends Equatable {
  const Ratings({
    this.google,
    this.tripadvisor,
  });

  final double? google;
  final double? tripadvisor;

  double? get average {
    final ratings = [google, tripadvisor].whereType<double>().toList();
    if (ratings.isEmpty) return null;
    return ratings.reduce((a, b) => a + b) / ratings.length;
  }

  factory Ratings.fromJson(Map<String, dynamic> json) => Ratings(
        google: (json['google'] as num?)?.toDouble(),
        tripadvisor: (json['tripadvisor'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'google': google,
        'tripadvisor': tripadvisor,
      };

  @override
  List<Object?> get props => [google, tripadvisor];
}
