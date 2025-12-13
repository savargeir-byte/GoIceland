import 'models/poi_model.dart';

/// 🇮🇸 Mock Iceland POI data for UI testing
/// This will be replaced with real Firebase data from the Iceland Data Engine
final List<PoiModel> mockPlaces = [
  // Waterfalls
  const PoiModel(
    id: 'mock_skogafoss',
    name: 'Skógafoss',
    type: 'waterfall',
    latitude: 63.5321,
    longitude: -19.5117,
    rating: 4.9,
    country: 'Iceland',
    image: 'https://images.unsplash.com/photo-1520208422220-d12a3c588e6c?w=800',
  ),
  const PoiModel(
    id: 'mock_gullfoss',
    name: 'Gullfoss',
    type: 'waterfall',
    latitude: 64.3271,
    longitude: -20.1211,
    rating: 4.9,
    country: 'Iceland',
    image: 'https://images.unsplash.com/photo-1504893524553-b855bce32c67?w=800',
  ),
  const PoiModel(
    id: 'mock_seljalandsfoss',
    name: 'Seljalandsfoss',
    type: 'waterfall',
    latitude: 63.6156,
    longitude: -19.9889,
    rating: 4.8,
    country: 'Iceland',
    image: 'https://images.unsplash.com/photo-1531366936337-7c912a4589a7?w=800',
  ),
  const PoiModel(
    id: 'mock_dettifoss',
    name: 'Dettifoss',
    type: 'waterfall',
    latitude: 65.8144,
    longitude: -16.3847,
    rating: 4.8,
    country: 'Iceland',
    image: 'https://images.unsplash.com/photo-1533738363-b7f9aef128ce?w=800',
  ),

  // Hot Springs & Geothermal
  const PoiModel(
    id: 'mock_blue_lagoon',
    name: 'Blue Lagoon',
    type: 'hot_spring',
    latitude: 63.8799,
    longitude: -22.4495,
    rating: 4.7,
    country: 'Iceland',
    image: 'https://images.unsplash.com/photo-1578271887552-5ac3a72752bc?w=800',
  ),
  const PoiModel(
    id: 'mock_geysir',
    name: 'Geysir',
    type: 'geyser',
    latitude: 64.3103,
    longitude: -20.3031,
    rating: 4.6,
    country: 'Iceland',
    image: 'https://images.unsplash.com/photo-1551632436-cbf8dd35adfa?w=800',
  ),
  const PoiModel(
    id: 'mock_strokkur',
    name: 'Strokkur',
    type: 'geyser',
    latitude: 64.3114,
    longitude: -20.3028,
    rating: 4.8,
    country: 'Iceland',
    image: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
  ),

  // Glaciers & Nature
  const PoiModel(
    id: 'mock_jokulsarlon',
    name: 'Jökulsárlón Glacier Lagoon',
    type: 'glacier_lagoon',
    latitude: 64.0486,
    longitude: -16.1799,
    rating: 4.9,
    country: 'Iceland',
    image: 'https://images.unsplash.com/photo-1531366936337-7c912a4589a7?w=800',
  ),
  const PoiModel(
    id: 'mock_vatnajokull',
    name: 'Vatnajökull National Park',
    type: 'national_park',
    latitude: 64.4167,
    longitude: -16.8333,
    rating: 4.9,
    country: 'Iceland',
    image: 'https://images.unsplash.com/photo-1483683804023-6ccdb62f86ef?w=800',
  ),

  // Black Sand Beaches
  const PoiModel(
    id: 'mock_reynisfjara',
    name: 'Reynisfjara Black Sand Beach',
    type: 'beach',
    latitude: 63.4045,
    longitude: -19.0447,
    rating: 4.8,
    country: 'Iceland',
    image: 'https://images.unsplash.com/photo-1520208422220-d12a3c588e6c?w=800',
  ),
  const PoiModel(
    id: 'mock_diamond_beach',
    name: 'Diamond Beach',
    type: 'beach',
    latitude: 64.0425,
    longitude: -16.1764,
    rating: 4.9,
    country: 'Iceland',
    image: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
  ),

  // Canyons & Cliffs
  const PoiModel(
    id: 'mock_fjadrargljufur',
    name: 'Fjaðrárgljúfur Canyon',
    type: 'canyon',
    latitude: 63.7731,
    longitude: -18.1781,
    rating: 4.7,
    country: 'Iceland',
    image: 'https://images.unsplash.com/photo-1504893524553-b855bce32c67?w=800',
  ),

  // Restaurants - Reykjavik
  const PoiModel(
    id: 'mock_dill',
    name: 'Dill Restaurant',
    type: 'restaurant',
    latitude: 64.1465,
    longitude: -21.9426,
    rating: 4.6,
    country: 'Iceland',
    open: '18:00-22:00',
  ),
  const PoiModel(
    id: 'mock_grillmarkadurinn',
    name: 'Grillmarkaðurinn',
    type: 'restaurant',
    latitude: 64.1475,
    longitude: -21.9403,
    rating: 4.5,
    country: 'Iceland',
    open: '17:30-23:00',
  ),
  const PoiModel(
    id: 'mock_fish_market',
    name: 'Fiskmarkaðurinn',
    type: 'restaurant',
    latitude: 64.1480,
    longitude: -21.9440,
    rating: 4.4,
    country: 'Iceland',
    open: '11:30-22:00',
  ),

  // Cafes
  const PoiModel(
    id: 'mock_reykjavik_roasters',
    name: 'Reykjavík Roasters',
    type: 'cafe',
    latitude: 64.1466,
    longitude: -21.9350,
    rating: 4.7,
    country: 'Iceland',
    open: '08:00-17:00',
  ),
  const PoiModel(
    id: 'mock_sandholt',
    name: 'Sandholt Bakery',
    type: 'cafe',
    latitude: 64.1477,
    longitude: -21.9390,
    rating: 4.6,
    country: 'Iceland',
    open: '06:30-18:00',
  ),

  // Hotels
  const PoiModel(
    id: 'mock_ion_adventure',
    name: 'ION Adventure Hotel',
    type: 'hotel',
    latitude: 64.0597,
    longitude: -21.3233,
    rating: 4.8,
    country: 'Iceland',
  ),
  const PoiModel(
    id: 'mock_hotel_ranga',
    name: 'Hotel Rangá',
    type: 'hotel',
    latitude: 63.8525,
    longitude: -20.4425,
    rating: 4.9,
    country: 'Iceland',
  ),

  // Museums & Culture
  const PoiModel(
    id: 'mock_hallgrimskirkja',
    name: 'Hallgrímskirkja',
    type: 'church',
    latitude: 64.1426,
    longitude: -21.9266,
    rating: 4.7,
    country: 'Iceland',
    image: 'https://images.unsplash.com/photo-1551632436-cbf8dd35adfa?w=800',
  ),
  const PoiModel(
    id: 'mock_perlan',
    name: 'Perlan Museum',
    type: 'museum',
    latitude: 64.1303,
    longitude: -21.9177,
    rating: 4.6,
    country: 'Iceland',
    open: '09:00-19:00',
  ),
];

/// Categories for filtering
final List<String> mockCategories = [
  'waterfall',
  'hot_spring',
  'geyser',
  'glacier_lagoon',
  'national_park',
  'beach',
  'canyon',
  'restaurant',
  'cafe',
  'hotel',
  'church',
  'museum',
];

/// Featured collections
final Map<String, List<PoiModel>> mockCollections = {
  'Golden Circle': [
    mockPlaces[1], // Gullfoss
    mockPlaces[5], // Geysir
    mockPlaces[6], // Strokkur
  ],
  'South Coast': [
    mockPlaces[0], // Skógafoss
    mockPlaces[2], // Seljalandsfoss
    mockPlaces[9], // Reynisfjara
  ],
  'Reykjavik': [
    mockPlaces[12], // Dill
    mockPlaces[13], // Grillmarkaðurinn
    mockPlaces[15], // Reykjavík Roasters
    mockPlaces[18], // Hallgrímskirkja
  ],
  'Nature Wonders': [
    mockPlaces[7], // Jökulsárlón
    mockPlaces[8], // Vatnajökull
    mockPlaces[10], // Diamond Beach
  ],
};
