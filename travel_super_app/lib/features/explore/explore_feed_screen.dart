import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/animations/micro_animations.dart';
import '../../core/widgets/trail_cards.dart';
import '../../data/models/place_model.dart';
import '../../data/models/trail_model.dart';

/// Explore feed with curated content sections - Today's Picks, Collections, Trails
class ExploreFeedScreen extends StatefulWidget {
  const ExploreFeedScreen({super.key});

  @override
  State<ExploreFeedScreen> createState() => _ExploreFeedScreenState();
}

class _ExploreFeedScreenState extends State<ExploreFeedScreen> {
  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Kannaðu Ísland'),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Today's Picks - Large cards
          SliverToBoxAdapter(
            child: _buildTodaysPicks(),
          ),
          // Nearby Wonders - Small cards
          SliverToBoxAdapter(
            child: _buildCollectionRow(
                'Náttúruperlu í nágrenninu', 'nearby_wonders'),
          ),
          // Trending
          SliverToBoxAdapter(
            child: _buildCollectionRow('Vinsælt núna', 'trending'),
          ),
          // Hidden Gems
          SliverToBoxAdapter(
            child: _buildCollectionRow('Faldar perlur', 'hidden_gems'),
          ),
          // Hotels Section - NEW
          SliverToBoxAdapter(
            child: _buildHotelsSection(),
          ),
          // Restaurants Section - NEW
          SliverToBoxAdapter(
            child: _buildRestaurantsSection(),
          ),
          // Hiking Trails
          SliverToBoxAdapter(
            child: _buildTrailsSection(),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }

  Widget _buildTodaysPicks() {
    return StreamBuilder<DocumentSnapshot>(
      stream:
          _firestore.collection('collections').doc('todays_picks').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 260,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final collection = snapshot.data!;
        final placeIds = List<String>.from(collection['placeIds'] ?? []);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Text(
                'Val dagsins',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            SizedBox(
              height: 260,
              child: FutureBuilder<List<PlaceModel>>(
                future: _fetchPlacesByIds(placeIds),
                builder: (context, placeSnapshot) {
                  if (!placeSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final places = placeSnapshot.data!;
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: places.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      return SlideInAnimation(
                        delay: Duration(milliseconds: 100 * index),
                        offset: const Offset(30, 0),
                        child: LargePlaceCard(
                          place: places[index],
                          onTap: () => _openPlaceDetails(places[index]),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCollectionRow(String title, String collectionId) {
    return StreamBuilder<DocumentSnapshot>(
      stream:
          _firestore.collection('collections').doc(collectionId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final collection = snapshot.data!;
        final placeIds = List<String>.from(collection['placeIds'] ?? []);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(
              height: 180,
              child: FutureBuilder<List<PlaceModel>>(
                future: _fetchPlacesByIds(placeIds),
                builder: (context, placeSnapshot) {
                  if (!placeSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final places = placeSnapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: places.length,
                    itemBuilder: (context, index) {
                      return SlideInAnimation(
                        delay: Duration(milliseconds: 100 * index),
                        offset: const Offset(20, 0),
                        child: SmallPlaceCard(
                          place: places[index],
                          onTap: () => _openPlaceDetails(places[index]),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHotelsSection() {
    return FutureBuilder<QuerySnapshot>(
      future: _firestore
          .collection('places')
          .where('category', whereIn: ['hotel', 'guesthouse', 'hostel'])
          .limit(10)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final hotels = snapshot.data!.docs
            .map(
                (doc) => PlaceModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList();

        if (hotels.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Row(
                children: [
                  const Icon(Icons.hotel, color: Color(0xFF3F51B5)),
                  const SizedBox(width: 8),
                  Text(
                    'Hótel og gistiaðstaða',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 180,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: hotels.length,
                itemBuilder: (context, index) {
                  return SlideInAnimation(
                    delay: Duration(milliseconds: 100 * index),
                    offset: const Offset(20, 0),
                    child: SmallPlaceCard(
                      place: hotels[index],
                      onTap: () => _openPlaceDetails(hotels[index]),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRestaurantsSection() {
    return FutureBuilder<QuerySnapshot>(
      future: _firestore
          .collection('places')
          .where('category', whereIn: ['restaurant', 'cafe', 'bar'])
          .limit(10)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final restaurants = snapshot.data!.docs
            .map(
                (doc) => PlaceModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList();

        if (restaurants.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Row(
                children: [
                  const Icon(Icons.restaurant, color: Color(0xFFFF9800)),
                  const SizedBox(width: 8),
                  Text(
                    'Veitingastaðir',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 180,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: restaurants.length,
                itemBuilder: (context, index) {
                  return SlideInAnimation(
                    delay: Duration(milliseconds: 100 * index),
                    offset: const Offset(20, 0),
                    child: SmallPlaceCard(
                      place: restaurants[index],
                      onTap: () => _openPlaceDetails(restaurants[index]),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTrailsSection() {
    return StreamBuilder<DocumentSnapshot>(
      stream:
          _firestore.collection('collections').doc('hiking_trails').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final collection = snapshot.data!;
        final trailIds = List<String>.from(collection['trailIds'] ?? []);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Row(
                children: [
                  const Icon(Icons.hiking, color: Color(0xFF00D4AA)),
                  const SizedBox(width: 8),
                  Text(
                    'Gönguleiðir í nágrenninu',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
            FutureBuilder<List<TrailModel>>(
              future: _fetchTrailsByIds(trailIds),
              builder: (context, trailSnapshot) {
                if (!trailSnapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final trails = trailSnapshot.data!;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: trails
                        .map((trail) => SlideInAnimation(
                              delay: Duration(
                                  milliseconds: 100 * trails.indexOf(trail)),
                              offset: const Offset(0, 20),
                              child: TrailListTile(trail: trail),
                            ))
                        .toList(),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<List<PlaceModel>> _fetchPlacesByIds(List<String> ids) async {
    if (ids.isEmpty) return [];

    final places = <PlaceModel>[];
    for (final id in ids) {
      try {
        final doc = await _firestore.collection('places').doc(id).get();
        if (doc.exists) {
          places.add(PlaceModel.fromMap(doc.data()!));
        }
      } catch (e) {
        debugPrint('Error fetching place $id: $e');
      }
    }
    return places;
  }

  Future<List<TrailModel>> _fetchTrailsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];

    final trails = <TrailModel>[];
    for (final id in ids) {
      try {
        final doc = await _firestore.collection('trails').doc(id).get();
        if (doc.exists) {
          trails.add(TrailModel.fromMap(doc.data()!));
        }
      } catch (e) {
        debugPrint('Error fetching trail $id: $e');
      }
    }
    return trails;
  }

  void _openPlaceDetails(PlaceModel place) {
    // TODO: Navigate to place detail screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opnar ${place.name}')),
    );
  }
}
