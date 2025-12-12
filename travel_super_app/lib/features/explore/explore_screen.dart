import 'package:flutter/material.dart';

import '../../data/models/place.dart';
import '../../data/models/poi_category.dart';
import '../../data/repositories/places_repository.dart';
import '../widgets/place_card.dart';
import '../detail/place_detail_screen.dart';

/// 🗺️ Explore Screen - Browse all Iceland POIs from Firebase
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final PlacesRepository _repository = PlacesRepository();
  String? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Iceland'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: _PlaceSearchDelegate(_repository),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Filter Chips
          _buildCategoryFilters(),
          
          // Places Grid from Firebase
          Expanded(
            child: StreamBuilder<List<Place>>(
              stream: _selectedCategory == null
                  ? _repository.getAllPlaces()
                  : _repository.getPlacesByCategory(_selectedCategory!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error: ${snapshot.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => setState(() {}),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                
                final places = snapshot.data ?? [];
                
                if (places.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.explore_off, size: 64),
                        const SizedBox(height: 16),
                        Text(
                          _selectedCategory == null
                              ? 'No places found'
                              : 'No $_selectedCategory places found',
                        ),
                      ],
                    ),
                  );
                }
                
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: places.length,
                  itemBuilder: (context, index) {
                    return PlaceCard(
                      place: places[index],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PlaceDetailScreen(place: places[index]),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Build category filter chips
  Widget _buildCategoryFilters() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildCategoryChip('All', null),
          const SizedBox(width: 8),
          ...IcelandCategories.allCategories.map((cat) =>
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildCategoryChip(cat.displayName, cat.id),
            ),
          ),
        ],
      ),
    );
  }

  /// Build individual category chip
  Widget _buildCategoryChip(String label, String? categoryId) {
    final isSelected = _selectedCategory == categoryId;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedCategory = selected ? categoryId : null;
        });
      },
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
    );
  }
}

/// Search delegate for places
class _PlaceSearchDelegate extends SearchDelegate<Place?> {
  final PlacesRepository _repository;

  _PlaceSearchDelegate(this._repository);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    if (query.isEmpty) {
      return const Center(
        child: Text('Enter a search query'),
      );
    }

    return StreamBuilder<List<Place>>(
      stream: _repository.searchPlaces(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final places = snapshot.data ?? [];

        if (places.isEmpty) {
          return const Center(
            child: Text('No results found'),
          );
        }

        return ListView.builder(
          itemCount: places.length,
          itemBuilder: (context, index) {
            final place = places[index];
            return ListTile(
              leading: (place.images != null && place.images!.isNotEmpty)
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        place.images!.first,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(Icons.place),
              title: Text(place.name),
              subtitle: Text(place.category),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, size: 16, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(place.rating?.toStringAsFixed(1) ?? '0.0'),
                ],
              ),
              onTap: () {
                close(context, place);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PlaceDetailScreen(place: place),
                  ),
                );
              },
            );
          },
        );
      },
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
