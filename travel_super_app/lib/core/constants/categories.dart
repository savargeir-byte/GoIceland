/// 🗂️ Place Categories - Shared between main app and admin panel
/// This ensures consistency across the entire application
library;

class PlaceCategories {
  static const List<CategoryInfo> all = [
    // 🏞️ NATURE - Náttúra
    CategoryInfo(
      id: 'waterfall',
      label: 'Waterfall',
      labelIs: 'Foss',
      emoji: '💧',
      group: 'nature',
    ),
    CategoryInfo(
      id: 'glacier',
      label: 'Glacier',
      labelIs: 'Jökull',
      emoji: '🧊',
      group: 'nature',
    ),
    CategoryInfo(
      id: 'glacier_lagoon',
      label: 'Glacier Lagoon',
      labelIs: 'Jökulsárlón',
      emoji: '🌊',
      group: 'nature',
    ),
    CategoryInfo(
      id: 'hot_spring',
      label: 'Hot Spring',
      labelIs: 'Heitur lind',
      emoji: '♨️',
      group: 'nature',
    ),
    CategoryInfo(
      id: 'geothermal',
      label: 'Geothermal Area',
      labelIs: 'Jarðhitasvæði',
      emoji: '💨',
      group: 'nature',
    ),
    CategoryInfo(
      id: 'beach',
      label: 'Beach',
      labelIs: 'Strönd',
      emoji: '🏖️',
      group: 'nature',
    ),
    CategoryInfo(
      id: 'canyon',
      label: 'Canyon',
      labelIs: 'Gljúfur',
      emoji: '🏔️',
      group: 'nature',
    ),
    CategoryInfo(
      id: 'cave',
      label: 'Cave',
      labelIs: 'Hellir',
      emoji: '🕳️',
      group: 'nature',
    ),
    CategoryInfo(
      id: 'lake',
      label: 'Lake',
      labelIs: 'Vatn',
      emoji: '🏞️',
      group: 'nature',
    ),
    CategoryInfo(
      id: 'peak',
      label: 'Mountain Peak',
      labelIs: 'Fjallstindur',
      emoji: '⛰️',
      group: 'nature',
    ),
    CategoryInfo(
      id: 'volcano',
      label: 'Volcano',
      labelIs: 'Eldfjall',
      emoji: '🌋',
      group: 'nature',
    ),

    // 🗿 ÁHUGAVERÐIR STAÐIR - Points of Interest
    CategoryInfo(
      id: 'viewpoint',
      label: 'Viewpoint',
      labelIs: 'Útsýnisstaður',
      emoji: '👁️',
      group: 'poi',
    ),
    CategoryInfo(
      id: 'landmark',
      label: 'Landmark',
      labelIs: 'Kennileiti',
      emoji: '🗿',
      group: 'poi',
    ),
    CategoryInfo(
      id: 'museum',
      label: 'Museum',
      labelIs: 'Safn',
      emoji: '🏛️',
      group: 'poi',
    ),
    CategoryInfo(
      id: 'church',
      label: 'Church',
      labelIs: 'Kirkja',
      emoji: '⛪',
      group: 'poi',
    ),
    CategoryInfo(
      id: 'hiking_route',
      label: 'Hiking Route',
      labelIs: 'Gönguleið',
      emoji: '🥾',
      group: 'poi',
    ),

    // 🍽️ VEITINGASTAÐIR - Restaurants & Food
    CategoryInfo(
      id: 'restaurant',
      label: 'Restaurant',
      labelIs: 'Veitingastaður',
      emoji: '🍽️',
      group: 'food',
    ),
    CategoryInfo(
      id: 'restaurants',
      label: 'Restaurants',
      labelIs: 'Veitingastaðir',
      emoji: '🍽️',
      group: 'food',
    ),
    CategoryInfo(
      id: 'cafe',
      label: 'Café',
      labelIs: 'Kaffihús',
      emoji: '☕',
      group: 'food',
    ),
    CategoryInfo(
      id: 'bar',
      label: 'Bar',
      labelIs: 'Bar',
      emoji: '🍺',
      group: 'food',
    ),

    // 🏨 GISTING - Accommodation
    CategoryInfo(
      id: 'hotel',
      label: 'Hotel',
      labelIs: 'Hótel',
      emoji: '🏨',
      group: 'accommodation',
    ),
    CategoryInfo(
      id: 'guesthouse',
      label: 'Guesthouse',
      labelIs: 'Gistiheimili',
      emoji: '🏡',
      group: 'accommodation',
    ),
    CategoryInfo(
      id: 'hostel',
      label: 'Hostel',
      labelIs: 'Farfuglaheimili',
      emoji: '🏠',
      group: 'accommodation',
    ),
    CategoryInfo(
      id: 'camping',
      label: 'Camping',
      labelIs: 'Tjaldsvæði',
      emoji: '⛺',
      group: 'accommodation',
    ),
    CategoryInfo(
      id: 'accommodation',
      label: 'Accommodation',
      labelIs: 'Gisting',
      emoji: '🛏️',
      group: 'accommodation',
    ),

    // ⚙️ ÞJÓNUSTA - Services
    CategoryInfo(
      id: 'info_center',
      label: 'Info Center',
      labelIs: 'Upplýsingamiðstöð',
      emoji: 'ℹ️',
      group: 'services',
    ),
    CategoryInfo(
      id: 'parking',
      label: 'Parking',
      labelIs: 'Bílastæði',
      emoji: '🅿️',
      group: 'services',
    ),
    CategoryInfo(
      id: 'shopping',
      label: 'Shopping',
      labelIs: 'Verslun',
      emoji: '🛒',
      group: 'services',
    ),
    CategoryInfo(
      id: 'gas_station',
      label: 'Gas Station',
      labelIs: 'Bensínstöð',
      emoji: '⛽',
      group: 'services',
    ),

    // 📍 OTHER
    CategoryInfo(
      id: 'other',
      label: 'Other',
      labelIs: 'Annað',
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

  // Group info for UI
  static const Map<String, GroupInfo> groups = {
    'nature': GroupInfo(
      id: 'nature',
      label: 'Nature',
      labelIs: 'Náttúra',
      emoji: '🏞️',
    ),
    'poi': GroupInfo(
      id: 'poi',
      label: 'Points of Interest',
      labelIs: 'Áhugaverðir staðir',
      emoji: '🗿',
    ),
    'food': GroupInfo(
      id: 'food',
      label: 'Food & Drink',
      labelIs: 'Veitingastaðir',
      emoji: '🍽️',
    ),
    'accommodation': GroupInfo(
      id: 'accommodation',
      label: 'Accommodation',
      labelIs: 'Gisting',
      emoji: '🏨',
    ),
    'services': GroupInfo(
      id: 'services',
      label: 'Services',
      labelIs: 'Þjónusta',
      emoji: '⚙️',
    ),
    'other': GroupInfo(
      id: 'other',
      label: 'Other',
      labelIs: 'Annað',
      emoji: '📍',
    ),
  };
}

class CategoryInfo {
  final String id;
  final String label;
  final String? labelIs; // Icelandic label
  final String emoji;
  final String group;

  const CategoryInfo({
    required this.id,
    required this.label,
    this.labelIs,
    required this.emoji,
    required this.group,
  });
}

class GroupInfo {
  final String id;
  final String label;
  final String labelIs;
  final String emoji;

  const GroupInfo({
    required this.id,
    required this.label,
    required this.labelIs,
    required this.emoji,
  });
}
