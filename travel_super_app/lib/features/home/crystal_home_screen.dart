import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/services/distance_service.dart';
import '../../core/theme/crystal_theme.dart';
import '../../core/widgets/crystal_place_card.dart';
import '../../core/widgets/crystal_search_bar.dart';
import '../../data/api/poi_api.dart';
import '../../data/models/poi_model.dart';

class CrystalHomeScreen extends StatefulWidget {
  const CrystalHomeScreen({super.key});

  @override
  State<CrystalHomeScreen> createState() => _CrystalHomeScreenState();
}

class _CrystalHomeScreenState extends State<CrystalHomeScreen> {
  final _poiApi = PoiApi();
  final _distanceService = DistanceService();
  late Future<List<PoiModel>> _featuredFuture;
  String _selectedCategory = 'all';
  
  final _categories = [
    {'id': 'all', 'label': 'All', 'icon': Icons.apps},
    {'id': 'restaurant', 'label': 'Food', 'icon': Icons.restaurant},
    {'id': 'viewpoint', 'label': 'Photo', 'icon': Icons.camera_alt},
    {'id': 'peak', 'label': 'Nature', 'icon': Icons.terrain},
    {'id': 'hot_spring', 'label': 'Wellness', 'icon': Icons.spa},
    {'id': 'hotel', 'label': 'Hotel', 'icon': Icons.hotel},
    {'id': 'cave', 'label': 'Cave', 'icon': Icons.landscape},
    {'id': 'volcano', 'label': 'Volcano', 'icon': Icons.whatshot},
  ];

  @override
  void initState() {
    super.initState();
    _featuredFuture = _loadFeatured();
  }

  Future<List<PoiModel>> _loadFeatured() async {
    return _selectedCategory == 'all'
        ? await _poiApi.fetchFeatured()
        : await _poiApi.fetchByCategory(_selectedCategory);
  }

  void _onCategoryChanged(String category) {
    setState(() {
      _selectedCategory = category;
      _featuredFuture = _loadFeatured();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFF0F4FF),
            const Color(0xFFFFFFFF),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => CrystalTheme.crystalGradient.createShader(bounds),
                          child: const Text(
                            'GO ICELAND',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        const Spacer(),
                        CrystalContainer(
                          padding: const EdgeInsets.all(12),
                          borderRadius: 20,
                          blur: CrystalTheme.blurLight,
                          child: const Icon(
                            Icons.notifications_outlined,
                            color: CrystalTheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Crystal Search Bar
                    CrystalSearchBar(
                      onFilterTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Filters coming soon!')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            // Weather Banner
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: CrystalContainer(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: CrystalTheme.crystalGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: CrystalTheme.glowShadow,
                        ),
                        child: const Icon(
                          Icons.wb_sunny,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '12°C',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Partly cloudy • Reykjavik',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Category Filters
            SliverToBoxAdapter(
              child: SizedBox(
                height: 90,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = _selectedCategory == cat['id'];
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: CrystalButton(
                        onTap: () => _onCategoryChanged(cat['id'] as String),
                        isSelected: isSelected,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              cat['icon'] as IconData,
                              color: isSelected ? Colors.white : CrystalTheme.primary,
                              size: 22,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              cat['label'] as String,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : const Color(0xFF1A202C),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            
            // Section Header
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => CrystalTheme.crystalGradient.createShader(bounds),
                      child: const Text(
                        'Today\'s picks',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        appShellKey.currentState?.switchToTab(3);
                      },
                      child: const Text(
                        'See all',
                        style: TextStyle(color: CrystalTheme.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Featured Places - Horizontal Scroll
            SliverToBoxAdapter(
              child: SizedBox(
                height: 340,
                child: FutureBuilder<List<PoiModel>>(
                  future: _featuredFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: CrystalTheme.primary,
                        ),
                      );
                    }
                    
                    final pois = snapshot.data!;
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: pois.length,
                      itemBuilder: (context, index) {
                        final poi = pois[index];
                        return CrystalPlaceCard(
                          poi: poi,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Selected: ${poi.name}')),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}
