import 'package:flutter/material.dart';

import '../../core/widgets/premium_place_card.dart';
import '../../data/api/poi_api.dart';
import '../../data/models/poi_model.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  static const _sections = [
    _ExploreItem(
      title: 'Photo Spots',
      subtitle: 'Curated scenic frames by Ellie',
      icon: Icons.camera_alt_outlined,
    ),
    _ExploreItem(
      title: 'Food Radar',
      subtitle: 'Veg-friendly tracker powered by Ellie',
      icon: Icons.restaurant,
    ),
    _ExploreItem(
      title: 'Hidden Gems',
      subtitle: 'Crowdsourced by the Firestore community',
      icon: Icons.park,
    ),
    _ExploreItem(
      title: 'Ellie • AI trip concierge',
      subtitle: 'Ask for hyper-local plans & Mapbox routes',
      icon: Icons.auto_awesome,
      highlight: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explore')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemBuilder: (_, index) => _ExploreSection(item: _sections[index]),
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemCount: _sections.length,
      ),
    );
  }
}

class _ExploreItem {
  const _ExploreItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.highlight = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool highlight;
}

class _ExploreSection extends StatelessWidget {
  const _ExploreSection({required this.item});

  final _ExploreItem item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleTap(context),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: item.highlight
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
                offset: Offset(0, 8), blurRadius: 20, color: Colors.black12),
          ],
        ),
        child: Row(
          children: [
            Icon(item.icon, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title,
                      style: Theme.of(context).textTheme.titleMedium),
                  Text(item.subtitle,
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  void _handleTap(BuildContext context) {
    // Navigate to category-specific screens
    switch (item.title) {
      case 'Photo Spots':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const _CategoryDetailScreen(
              title: 'Photo Spots',
              categories: ['viewpoint', 'waterfall', 'beach'],
            ),
          ),
        );
        break;
      case 'Food Radar':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const _CategoryDetailScreen(
              title: 'Food Radar',
              categories: ['restaurant', 'cafe'],
            ),
          ),
        );
        break;
      case 'Hidden Gems':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const _CategoryDetailScreen(
              title: 'Hidden Gems',
              categories: ['cave', 'hot_spring', 'camping'],
            ),
          ),
        );
        break;
      case 'Ellie • AI trip concierge':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🤖 AI trip planner coming soon!'),
            duration: Duration(seconds: 2),
          ),
        );
        break;
    }
  }
}

// New category detail screen
class _CategoryDetailScreen extends StatefulWidget {
  final String title;
  final List<String> categories;

  const _CategoryDetailScreen({
    required this.title,
    required this.categories,
  });

  @override
  State<_CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<_CategoryDetailScreen> {
  final _poiApi = PoiApi();
  List<PoiModel> _pois = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPois();
  }

  Future<void> _loadPois() async {
    setState(() => _loading = true);
    
    final allPois = <PoiModel>[];
    for (final category in widget.categories) {
      final pois = await _poiApi.fetchByCategory(category);
      allPois.addAll(pois);
    }
    
    setState(() {
      _pois = allPois;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _pois.isEmpty
              ? const Center(child: Text('No places found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _pois.length,
                  itemBuilder: (context, index) {
                    final poi = _pois[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: SizedBox(
                        height: 280,
                        child: PremiumPlaceCard(
                          poi: poi,
                          onTap: () {
                            // TODO: Navigate to detail screen
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Selected: ${poi.name}')),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
