/// 🗂️ Place Categories - Shared between main app and admin panel
/// This ensures consistency across the entire application
library;

class PlaceCategories {
  static const List<CategoryInfo> all = [
    // Nature & Landscapes
    CategoryInfo(
      id: 'waterfall',
      label: 'Waterfall',
      emoji: '💧',
      group: 'nature',
    ),
    CategoryInfo(
      id: 'glacier',
      label: 'Glacier',
      emoji: '🧊',
      group: 'nature',
    ),
    CategoryInfo(
      id: 'glacier_lagoon',
      label: 'Glacier Lagoon',
      emoji: '🌊',
      group: 'nature',
    ),
    CategoryInfo(
      id: 'volcano',
      label: 'Volcano',
      emoji: '🌋',
      group: 'nature',
    ),
    CategoryInfo(
      id: 'hot_spring',
      label: 'Hot Spring',
      emoji: '♨️',
      group: 'nature',
    ),
    CategoryInfo(
      id: 'geothermal',
      label: 'Geothermal Area',
      emoji: '💨',
      group: 'nature',
    ),
    CategoryInfo(
      id: 'beach',
      label: 'Beach',
      emoji: '🏖️',
      group: 'nature',
    ),
    CategoryInfo(
      id: 'canyon',
      label: 'Canyon',
      emoji: '🏔️',
      group: 'nature',
    ),
    CategoryInfo(
      id: 'cave',
      label: 'Cave',
      emoji: '🕳️',
      group: 'nature',
    ),
    CategoryInfo(
      id: 'lake',
      label: 'Lake',
      emoji: '🏞️',
      group: 'nature',
    ),
    CategoryInfo(
      id: 'peak',
      label: 'Mountain Peak',
      emoji: '⛰️',
      group: 'nature',
    ),
    CategoryInfo(
      id: 'viewpoint',
      label: 'Viewpoint',
      emoji: '👁️',
      group: 'nature',
    ),

    // Cultural & Historical
    CategoryInfo(
      id: 'museum',
      label: 'Museum',
      emoji: '🏛️',
      group: 'culture',
    ),
    CategoryInfo(
      id: 'landmark',
      label: 'Landmark',
      emoji: '🗿',
      group: 'culture',
    ),
    CategoryInfo(
      id: 'church',
      label: 'Church',
      emoji: '⛪',
      group: 'culture',
    ),

    // Accommodation
    CategoryInfo(
      id: 'hotel',
      label: 'Hotel',
      emoji: '🏨',
      group: 'accommodation',
    ),
    CategoryInfo(
      id: 'hostel',
      label: 'Hostel',
      emoji: '🏠',
      group: 'accommodation',
    ),
    CategoryInfo(
      id: 'camping',
      label: 'Camping',
      emoji: '⛺',
      group: 'accommodation',
    ),

    // Food & Drink
    CategoryInfo(
      id: 'restaurant',
      label: 'Restaurant',
      emoji: '🍽️',
      group: 'food',
    ),
    CategoryInfo(
      id: 'cafe',
      label: 'Café',
      emoji: '☕',
      group: 'food',
    ),
    CategoryInfo(
      id: 'bar',
      label: 'Bar',
      emoji: '🍺',
      group: 'food',
    ),

    // Services
    CategoryInfo(
      id: 'info_center',
      label: 'Info Center',
      emoji: 'ℹ️',
      group: 'services',
    ),
    CategoryInfo(
      id: 'parking',
      label: 'Parking',
      emoji: '🅿️',
      group: 'services',
    ),
    CategoryInfo(
      id: 'shopping',
      label: 'Shopping',
      emoji: '🛒',
      group: 'services',
    ),
    CategoryInfo(
      id: 'gas_station',
      label: 'Gas Station',
      emoji: '⛽',
      group: 'services',
    ),

    // Other
    CategoryInfo(
      id: 'other',
      label: 'Other',
      emoji: '📍',
      group: 'other',
    ),
  ];

  static CategoryInfo? findById(String id) {
    try {
      return all.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }

  static String getLabel(String id) {
    return findById(id)?.label ?? id;
  }

  static String getEmoji(String id) {
    return findById(id)?.emoji ?? '📍';
  }

  static List<CategoryInfo> byGroup(String group) {
    return all.where((cat) => cat.group == group).toList();
  }

  static List<String> get allIds => all.map((cat) => cat.id).toList();
}

class CategoryInfo {
  final String id;
  final String label;
  final String emoji;
  final String group;

  const CategoryInfo({
    required this.id,
    required this.label,
    required this.emoji,
    required this.group,
  });
}
