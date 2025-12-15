import 'package:flutter/material.dart';

/// 🗂️ POI Category - Types of places in Iceland
class PoiCategory {
  final String id;
  final String name;
  final String displayName;
  final IconData icon;
  final Color color;
  final String? emoji;

  const PoiCategory({
    required this.id,
    required this.name,
    required this.displayName,
    required this.icon,
    required this.color,
    this.emoji,
  });

  factory PoiCategory.fromJson(Map<String, dynamic> json) {
    return PoiCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      displayName: json['displayName'] as String,
      icon: _getIconData(json['icon'] as String?),
      color: _getColor(json['color'] as String?),
      emoji: json['emoji'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'displayName': displayName,
      'icon': icon.codePoint.toString(),
      'color': color.value.toString(),
      if (emoji != null) 'emoji': emoji,
    };
  }

  static IconData _getIconData(String? iconName) {
    switch (iconName) {
      case 'waterfall':
        return Icons.water_drop;
      case 'hot_spring':
        return Icons.hot_tub;
      case 'geyser':
        return Icons.whatshot;
      case 'glacier':
        return Icons.ac_unit;
      case 'glacier_lagoon':
        return Icons.water;
      case 'volcano':
        return Icons.terrain;
      case 'beach':
        return Icons.beach_access;
      case 'restaurant':
        return Icons.restaurant;
      case 'cafe':
        return Icons.local_cafe;
      case 'bar':
        return Icons.local_bar;
      case 'hotel':
        return Icons.hotel;
      case 'museum':
        return Icons.museum;
      case 'church':
        return Icons.church;
      case 'hiking':
        return Icons.hiking;
      case 'peak':
        return Icons.terrain;
      case 'cave':
        return Icons.explore;
      case 'viewpoint':
        return Icons.visibility;
      case 'lighthouse':
        return Icons.lightbulb_outline;
      case 'pool':
        return Icons.pool;
      case 'camping':
        return Icons.deck;
      case 'shop':
        return Icons.shopping_bag;
      case 'attraction':
        return Icons.star;
      case 'park':
      case 'national_park':
        return Icons.park;
      case 'canyon':
        return Icons.landscape;
      default:
        return Icons.place;
    }
  }

  static Color _getColor(String? colorName) {
    switch (colorName) {
      case 'blue':
        return Colors.blue;
      case 'red':
        return Colors.red;
      case 'orange':
        return Colors.orange;
      case 'green':
        return Colors.green;
      case 'purple':
        return Colors.purple;
      case 'amber':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }
}

/// 🗺️ Predefined Iceland POI categories
class IcelandCategories {
  static const all = PoiCategory(
    id: 'all',
    name: 'all',
    displayName: 'All Places',
    icon: Icons.apps,
    color: Colors.grey,
    emoji: '🇮🇸',
  );

  static const waterfall = PoiCategory(
    id: 'waterfall',
    name: 'waterfall',
    displayName: 'Waterfalls',
    icon: Icons.water_drop,
    color: Colors.blue,
    emoji: '💧',
  );

  static const hotSpring = PoiCategory(
    id: 'hot_spring',
    name: 'hot_spring',
    displayName: 'Hot Springs',
    icon: Icons.hot_tub,
    color: Colors.orange,
    emoji: '♨️',
  );

  static const geyser = PoiCategory(
    id: 'geyser',
    name: 'geyser',
    displayName: 'Geysers',
    icon: Icons.whatshot,
    color: Colors.deepOrange,
    emoji: '💨',
  );

  static const glacier = PoiCategory(
    id: 'glacier',
    name: 'glacier_lagoon',
    displayName: 'Glaciers',
    icon: Icons.ac_unit,
    color: Colors.lightBlue,
    emoji: '🧊',
  );

  static const volcano = PoiCategory(
    id: 'volcano',
    name: 'volcano',
    displayName: 'Volcanoes',
    icon: Icons.terrain,
    color: Colors.red,
    emoji: '🌋',
  );

  static const beach = PoiCategory(
    id: 'beach',
    name: 'beach',
    displayName: 'Beaches',
    icon: Icons.beach_access,
    color: Colors.brown,
    emoji: '🏖️',
  );

  static const restaurant = PoiCategory(
    id: 'restaurant',
    name: 'restaurant',
    displayName: 'Restaurants',
    icon: Icons.restaurant,
    color: Colors.green,
    emoji: '🍽️',
  );

  static const cafe = PoiCategory(
    id: 'cafe',
    name: 'cafe',
    displayName: 'Cafés',
    icon: Icons.local_cafe,
    color: Colors.brown,
    emoji: '☕',
  );

  static const hotel = PoiCategory(
    id: 'hotel',
    name: 'hotel',
    displayName: 'Hotels',
    icon: Icons.hotel,
    color: Colors.purple,
    emoji: '🏨',
  );

  static const museum = PoiCategory(
    id: 'museum',
    name: 'museum',
    displayName: 'Museums',
    icon: Icons.museum,
    color: Colors.indigo,
    emoji: '🏛️',
  );

  static const church = PoiCategory(
    id: 'church',
    name: 'church',
    displayName: 'Churches',
    icon: Icons.church,
    color: Colors.blueGrey,
    emoji: '⛪',
  );

  static const hiking = PoiCategory(
    id: 'hiking',
    name: 'hiking',
    displayName: 'Hiking',
    icon: Icons.hiking,
    color: Colors.teal,
    emoji: '🥾',
  );

  static const canyon = PoiCategory(
    id: 'canyon',
    name: 'canyon',
    displayName: 'Canyons',
    icon: Icons.landscape,
    color: Colors.deepOrange,
    emoji: '🏜️',
  );

  static const nationalPark = PoiCategory(
    id: 'national_park',
    name: 'national_park',
    displayName: 'National Parks',
    icon: Icons.park,
    color: Colors.green,
    emoji: '🏞️',
  );

  static const peak = PoiCategory(
    id: 'peak',
    name: 'peak',
    displayName: 'Peaks',
    icon: Icons.terrain,
    color: Colors.blueGrey,
    emoji: '⛰️',
  );

  static const cave = PoiCategory(
    id: 'cave',
    name: 'cave',
    displayName: 'Caves',
    icon: Icons.explore,
    color: Colors.grey,
    emoji: '🕳️',
  );

  static const viewpoint = PoiCategory(
    id: 'viewpoint',
    name: 'viewpoint',
    displayName: 'Viewpoints',
    icon: Icons.visibility,
    color: Colors.blue,
    emoji: '👁️',
  );

  static const lighthouse = PoiCategory(
    id: 'lighthouse',
    name: 'lighthouse',
    displayName: 'Lighthouses',
    icon: Icons.lightbulb_outline,
    color: Colors.amber,
    emoji: '🗼',
  );

  static const pool = PoiCategory(
    id: 'pool',
    name: 'pool',
    displayName: 'Pools',
    icon: Icons.pool,
    color: Colors.blue,
    emoji: '🏊',
  );

  static const camping = PoiCategory(
    id: 'camping',
    name: 'camping',
    displayName: 'Camping',
    icon: Icons.deck,
    color: Colors.green,
    emoji: '⛺',
  );

  static const bar = PoiCategory(
    id: 'bar',
    name: 'bar',
    displayName: 'Bars',
    icon: Icons.local_bar,
    color: Colors.amber,
    emoji: '🍺',
  );

  static const shop = PoiCategory(
    id: 'shop',
    name: 'shop',
    displayName: 'Shops',
    icon: Icons.shopping_bag,
    color: Colors.pink,
    emoji: '🛍️',
  );

  static const attraction = PoiCategory(
    id: 'attraction',
    name: 'attraction',
    displayName: 'Attractions',
    icon: Icons.star,
    color: Colors.orange,
    emoji: '🎯',
  );

  static const glacierLagoon = PoiCategory(
    id: 'glacier_lagoon',
    name: 'glacier_lagoon',
    displayName: 'Glacier Lagoons',
    icon: Icons.water,
    color: Colors.cyan,
    emoji: '🌊',
  );

  static const park = PoiCategory(
    id: 'park',
    name: 'park',
    displayName: 'Parks',
    icon: Icons.park,
    color: Colors.lightGreen,
    emoji: '🌳',
  );

  static const other = PoiCategory(
    id: 'other',
    name: 'other',
    displayName: 'Other',
    icon: Icons.place,
    color: Colors.grey,
    emoji: '📍',
  );

  /// Get all categories as a list
  static List<PoiCategory> get allCategories => [
        all,
        waterfall,
        hotSpring,
        geyser,
        glacier,
        glacierLagoon,
        volcano,
        beach,
        restaurant,
        cafe,
        bar,
        hotel,
        museum,
        church,
        hiking,
        canyon,
        nationalPark,
        peak,
        cave,
        viewpoint,
        lighthouse,
        pool,
        camping,
        shop,
        attraction,
        park,
        other,
      ];

  /// Get category by ID
  static PoiCategory? getById(String id) {
    try {
      return allCategories.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get category by name
  static PoiCategory? getByName(String name) {
    try {
      return allCategories.firstWhere(
        (c) => c.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }
}
