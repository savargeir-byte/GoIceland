import 'package:flutter/material.dart';
import 'package:travel_super_app/core/services/poi_data_service.dart';
import 'package:travel_super_app/data/models/place_model.dart';

/// Quick test screen to verify hotels and restaurants are loaded
class TestPOIScreen extends StatefulWidget {
  const TestPOIScreen({super.key});

  @override
  State<TestPOIScreen> createState() => _TestPOIScreenState();
}

class _TestPOIScreenState extends State<TestPOIScreen> {
  List<PlaceModel>? hotels;
  List<PlaceModel>? restaurants;
  List<PlaceModel>? allPlaces;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);

    try {
      final hotelsData = await PoiDataService.getHotels(limit: 20);
      final restaurantsData = await PoiDataService.getRestaurants(limit: 20);
      final allData = await PoiDataService.getAllPlaces(limit: 50);

      setState(() {
        hotels = hotelsData;
        restaurants = restaurantsData;
        allPlaces = allData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('POI Test'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadData,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error: $error'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: loadData,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildStatsCard(),
                    const SizedBox(height: 16),
                    _buildSection('Hotels (${hotels?.length ?? 0})', hotels),
                    const SizedBox(height: 16),
                    _buildSection('Restaurants (${restaurants?.length ?? 0})',
                        restaurants),
                    const SizedBox(height: 16),
                    _buildSection(
                        'All Places (${allPlaces?.length ?? 0})', allPlaces),
                  ],
                ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📊 Database Stats',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _statRow('Total Places', allPlaces?.length.toString() ?? '0'),
            _statRow('Hotels', hotels?.length.toString() ?? '0'),
            _statRow('Restaurants', restaurants?.length.toString() ?? '0'),
            const Divider(),
            Text(
              'Expected: ~4972 total POIs (265 hotels)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<PlaceModel>? places) {
    if (places == null || places.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('No data'),
            ],
          ),
        ),
      );
    }

    return Card(
      child: ExpansionTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        children: places.take(10).map((place) {
          return ListTile(
            leading: CircleAvatar(
              child: Text(place.category[0].toUpperCase()),
            ),
            title: Text(place.name),
            subtitle: Text(
              '${place.category} • ${place.region ?? "Unknown"}',
            ),
            trailing: place.metadata?['stars'] != null
                ? Text('⭐ ${place.metadata!['stars']}')
                : null,
          );
        }).toList(),
      ),
    );
  }
}
