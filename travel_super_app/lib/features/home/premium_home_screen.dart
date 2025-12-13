import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/animations/micro_animations.dart';
import '../../core/animations/scroll_effects.dart';
import '../../core/services/distance_service.dart';
import '../../core/widgets/animated_category_chip.dart';
import '../../core/widgets/bottom_sheet.dart';
import '../../core/widgets/premium_place_card.dart';
import '../../data/api/poi_api.dart';
import '../../data/api/trail_api.dart';
import '../../data/models/poi_model.dart';
import '../../data/models/trail_model.dart';
import '../map/pin_details_sheet.dart';
import '../weather/premium_weather_banner.dart';
import '../weather/weather_banner.dart';
import '../widgets/trail_card.dart';

class PremiumHomeScreen extends StatefulWidget {
  const PremiumHomeScreen({super.key});

  @override
  State<PremiumHomeScreen> createState() => _PremiumHomeScreenState();
}

class _PremiumHomeScreenState extends State<PremiumHomeScreen> {
  final _poiApi = PoiApi();
  final _trailApi = TrailApi();
  final _distanceService = DistanceService();
  late Future<List<PoiModel>> _featuredFuture;
  late Future<List<TrailModel>> _trailsFuture;
  Map<String, PoiDistanceInfo> _distanceInfo = {};
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    _featuredFuture = _loadFeatured();
    _trailsFuture = _trailApi.fetchPopular();
  }

  Future<List<PoiModel>> _loadFeatured() async {
    final pois = _selectedCategory == 'all'
        ? await _poiApi.fetchFeatured()
        : await _poiApi.fetchByCategory(_selectedCategory);
    _distanceInfo = await _distanceService.getMultiplePoiDistances(pois);
    return pois;
  }

  void _onCategoryChanged(String category) {
    setState(() {
      _selectedCategory = category;
      _featuredFuture = _loadFeatured();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        physics: const PremiumScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: true,
            elevation: 0,
            title: Text(
              'GO ICELAND',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            actions: const [
              Padding(
                padding: EdgeInsets.only(right: 16),
                child: CircleAvatar(child: Icon(Icons.person)),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: FadeInAnimation(
              duration: const Duration(milliseconds: 800),
              child: FutureBuilder<_WeatherModel?>(
                future: _loadWeather(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const WeatherBanner();
                  }
                  final weather = snapshot.data!;
                  return PremiumWeatherBanner(
                    temperature: weather.temperature,
                    description: weather.description,
                    location: weather.location,
                    onRefresh: () => setState(() {}),
                  );
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 8),
          ),
          SliverToBoxAdapter(
            child: SlideInAnimation(
              delay: const Duration(milliseconds: 200),
              offset: const Offset(0, 20),
              child: CategoryChipList(
                onCategorySelected: _onCategoryChanged,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
            sliver: SliverToBoxAdapter(
              child: SlideInAnimation(
                delay: const Duration(milliseconds: 400),
                offset: const Offset(0, 15),
                child: Row(
                  children: [
                    Text(
                      'Today\'s picks',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        // Navigate to Explore tab (index 3)
                        appShellKey.currentState?.switchToTab(3);
                      },
                      child: const Text('See all'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 300,
              child: FutureBuilder<List<PoiModel>>(
                future: _featuredFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final pois = snapshot.data!;
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (_, index) {
                      final poi = pois[index];
                      final info = _distanceInfo[poi.id];
                      return SlideInAnimation(
                        delay: Duration(milliseconds: 500 + (index * 100)),
                        offset: const Offset(30, 0),
                        child: PremiumPlaceCard(
                          poi: poi,
                          distance: info?.distance,
                          travelTime: info?.travelTime,
                          onTap: () => _openPoi(poi),
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemCount: pois.length,
                  );
                },
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
            sliver: SliverToBoxAdapter(
              child: SlideInAnimation(
                delay: const Duration(milliseconds: 600),
                offset: const Offset(0, 15),
                child: Row(
                  children: [
                    const Icon(Icons.terrain, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Popular Trails',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {},
                      child: const Text('See all'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 220,
              child: FutureBuilder<List<TrailModel>>(
                future: _trailsFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final trails = snapshot.data!;
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (_, index) {
                      return SlideInAnimation(
                        delay: Duration(milliseconds: 700 + (index * 100)),
                        offset: const Offset(30, 0),
                        child: TrailCard(trail: trails[index]),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemCount: trails.length,
                  );
                },
              ),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }

  Future<_WeatherModel?> _loadWeather() async {
    // Stub: integrate with WeatherService
    // For now return fallback data
    return const _WeatherModel(
      temperature: 8,
      description: 'Partly cloudy',
      location: 'Reykjavík',
    );
  }

  void _openPoi(PoiModel poi) {
    AppBottomSheet.show(
      context: context,
      child: PinDetailsSheet(poi: poi),
    );
  }
}

class _WeatherModel {
  const _WeatherModel({
    required this.temperature,
    required this.description,
    required this.location,
  });
  final double temperature;
  final String description;
  final String location;
}
