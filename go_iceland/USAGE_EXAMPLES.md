# 🌋 GO ICELAND - Usage Examples

## 📱 Flutter Integration

### 1. Basic Usage - Sækja alla staði

```dart
import 'package:travel_super_app/core/services/poi_data_service.dart';

// Í StatefulWidget eða FutureBuilder
Future<void> loadPlaces() async {
  final places = await PoiDataService.getAllPlaces(limit: 100);

  for (var place in places) {
    print('${place.name} - ${place.category}');
  }
}
```

### 2. Sækja eftir category

```dart
// Waterfalls
final waterfalls = await PoiDataService.getPlacesByCategory('waterfall');

// Hotels
final hotels = await PoiDataService.getHotels(region: 'South', minStars: 3);

// Restaurants
final restaurants = await PoiDataService.getRestaurants(
  region: 'Capital Region',
  cuisine: 'seafood',
);

// Cafes & Bars
final cafes = await PoiDataService.getPlacesByCategory('cafe');
final bars = await PoiDataService.getPlacesByCategory('bar');
```

### 3. Real-time Stream (notendur sjá updates)

```dart
StreamBuilder<List<PlaceModel>>(
  stream: PoiDataService.placesStream(
    category: 'waterfall',
    region: 'South',
    limit: 20,
  ),
  builder: (context, snapshot) {
    if (!snapshot.hasData) {
      return CircularProgressIndicator();
    }

    final places = snapshot.data!;

    return ListView.builder(
      itemCount: places.length,
      itemBuilder: (context, index) {
        final place = places[index];
        return ListTile(
          title: Text(place.name),
          subtitle: Text(place.region ?? ''),
          trailing: Text(place.category),
        );
      },
    );
  },
)
```

### 4. Pagination fyrir lista

```dart
class PlacesListScreen extends StatefulWidget {
  @override
  _PlacesListScreenState createState() => _PlacesListScreenState();
}

class _PlacesListScreenState extends State<PlacesListScreen> {
  List<PlaceModel> places = [];
  DocumentSnapshot? lastDoc;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadMore();
  }

  Future<void> loadMore() async {
    if (isLoading) return;

    setState(() => isLoading = true);

    final newPlaces = await PoiDataService.getPlacesPaginated(
      lastDoc: lastDoc,
      limit: 20,
      category: 'restaurant',
    );

    if (newPlaces.isNotEmpty) {
      // Get lastDoc from Firestore query (you'll need to modify service)
      setState(() {
        places.addAll(newPlaces);
      });
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: places.length + 1,
      itemBuilder: (context, index) {
        if (index == places.length) {
          // Load more button
          return ElevatedButton(
            onPressed: loadMore,
            child: isLoading
              ? CircularProgressIndicator()
              : Text('Load More'),
          );
        }

        final place = places[index];
        return PlaceCard(place: place);
      },
    );
  }
}
```

### 5. Search með debouncing

```dart
import 'dart:async';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<PlaceModel> results = [];
  Timer? _debounce;

  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(Duration(milliseconds: 500), () async {
      if (query.length >= 2) {
        final places = await PoiDataService.searchPlaces(query);
        setState(() => results = places);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          onChanged: onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Search places...',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              return PlaceCard(place: results[index]);
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
```

### 6. Filter með multiple conditions

```dart
// Combine filters
Future<List<PlaceModel>> getFilteredPlaces({
  List<String>? categories,
  List<String>? regions,
  bool hasWebsite = false,
  bool hasPhone = false,
  bool isOpen247 = false,
}) async {
  var places = await PoiDataService.getAllPlaces();

  if (categories != null) {
    places = places.where((p) =>
      categories.contains(p.category)
    ).toList();
  }

  if (regions != null) {
    places = places.where((p) =>
      regions.contains(p.region)
    ).toList();
  }

  if (hasWebsite) {
    places = places.where((p) =>
      p.metadata?['website'] != null
    ).toList();
  }

  if (hasPhone) {
    places = places.where((p) =>
      p.metadata?['phone'] != null
    ).toList();
  }

  if (isOpen247) {
    places = places.where((p) {
      final hours = p.metadata?['opening_hours'];
      return hours is Map && hours['type'] == '24/7';
    }).toList();
  }

  return places;
}
```

### 7. Map integration með clusters

```dart
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapboxMap? mapboxMap;
  List<PlaceModel> places = [];

  @override
  void initState() {
    super.initState();
    loadPlaces();
  }

  Future<void> loadPlaces() async {
    final data = await PoiDataService.getAllPlaces(limit: 500);
    setState(() => places = data);
    addMarkersToMap();
  }

  void addMarkersToMap() {
    if (mapboxMap == null) return;

    for (var place in places) {
      // Add marker for each place
      mapboxMap!.style.addLayer(/* marker layer */);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MapWidget(
      onMapCreated: (map) {
        setState(() => mapboxMap = map);
        addMarkersToMap();
      },
    );
  }
}
```

---

## 🔥 Firestore Console

Opna: https://console.firebase.google.com/project/go-iceland/firestore

Þú sérð:

- `/places` collection með 2000+ POIs
- Hver place hefur: id, name, lat, lng, category, region, opening_hours, etc.

---

## 📊 Useful Queries

### By Category

```dart
final waterfalls = await getPlacesByCategory('waterfall');
final hotSprings = await getPlacesByCategory('hot_spring');
final hotels = await getHotels();
final restaurants = await getRestaurants();
```

### By Region

```dart
final capitalRegion = await getPlacesByRegion('Capital Region');
final south = await getPlacesByRegion('South');
final north = await getPlacesByRegion('North');
```

### Combined

```dart
// Hotels in South
final southHotels = await getHotels(region: 'South');

// Restaurants in Capital Region
final capitalRestaurants = await getRestaurants(region: 'Capital Region');
```

---

## 🎯 Next Steps

1. **Run the pipeline** - `.\run_full_pipeline.ps1`
2. **Test queries** - Use Flutter app to fetch data
3. **Add UI** - Create beautiful place cards
4. **Add filters** - Category, region, rating, etc.
5. **Add map** - Show all places on Mapbox map
