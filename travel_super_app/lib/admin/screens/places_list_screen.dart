import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/constants/categories.dart';
import '../models/admin_place.dart';
import '../services/admin_service.dart';
import 'place_edit_screen.dart';

/// 📍 Places List Screen - Browse and manage all places
class PlacesListScreen extends StatefulWidget {
  const PlacesListScreen({super.key});

  @override
  State<PlacesListScreen> createState() => _PlacesListScreenState();
}

class _PlacesListScreenState extends State<PlacesListScreen> {
  final _placeService = AdminPlaceService();
  final _searchController = TextEditingController();

  String? _selectedCategory;
  String _searchQuery = '';

  // Use shared categories
  late final List<String> _categories = [
    'All',
    ...PlaceCategories.all.map((c) => c.id),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Places'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Navigate to create place screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Create place coming soon!')),
              );
            },
            tooltip: 'Add New Place',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filter bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade50,
            child: Column(
              children: [
                // Search field
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search places...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                ),
                const SizedBox(height: 12),

                // Category chips
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isAll = category == 'All';
                      final isSelected = (isAll && _selectedCategory == null) ||
                          category == _selectedCategory;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(
                            isAll
                                ? category
                                : '${PlaceCategories.getEmoji(category)} ${PlaceCategories.getLabel(category)}',
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = isAll ? null : category;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Places list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _placeService.getPlaces(
                category: _selectedCategory,
                limit: 100,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                var docs = snapshot.data!.docs;

                // Filter by search query
                if (_searchQuery.isNotEmpty) {
                  docs = docs.where((doc) {
                    final name = (doc.data() as Map)['name']?.toString() ?? '';
                    return name
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase());
                  }).toList();
                }

                if (docs.isEmpty) {
                  return const Center(
                    child: Text('No places found'),
                  );
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final place = AdminPlace.fromFirestore(docs[index]);
                    return _PlaceListItem(
                      place: place,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => PlaceEditScreen(placeId: place.id),
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
}

/// 📍 Place list item widget
class _PlaceListItem extends StatelessWidget {
  final AdminPlace place;
  final VoidCallback onTap;

  const _PlaceListItem({
    required this.place,
    required this.onTap,
  });

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'restaurant':
        return Icons.restaurant;
      case 'hotel':
        return Icons.hotel;
      case 'cafe':
        return Icons.local_cafe;
      case 'bar':
        return Icons.local_bar;
      case 'museum':
        return Icons.museum;
      case 'hiking':
        return Icons.hiking;
      case 'shop':
        return Icons.shopping_bag;
      case 'viewpoint':
        return Icons.landscape;
      default:
        return Icons.place;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'restaurant':
        return Colors.orange;
      case 'hotel':
        return Colors.purple;
      case 'cafe':
        return Colors.brown;
      case 'bar':
        return Colors.amber;
      case 'museum':
        return Colors.indigo;
      case 'hiking':
        return Colors.green;
      case 'shop':
        return Colors.pink;
      case 'viewpoint':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasDescription = place.content.values
        .any((content) => content.description?.isNotEmpty ?? false);
    final hasImages =
        place.images.cover != null || place.images.gallery.isNotEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Place image or icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _getCategoryColor(place.category).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: place.images.cover != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          place.images.cover!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            _getCategoryIcon(place.category),
                            color: _getCategoryColor(place.category),
                          ),
                        ),
                      )
                    : Icon(
                        _getCategoryIcon(place.category),
                        color: _getCategoryColor(place.category),
                        size: 32,
                      ),
              ),
              const SizedBox(width: 12),

              // Place info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(place.category)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            place.category,
                            style: TextStyle(
                              fontSize: 12,
                              color: _getCategoryColor(place.category),
                            ),
                          ),
                        ),
                        if (place.region != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            place.region!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          hasDescription ? Icons.check_circle : Icons.warning,
                          size: 14,
                          color: hasDescription ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          hasDescription ? 'Has description' : 'No description',
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          hasImages ? Icons.image : Icons.image_not_supported,
                          size: 14,
                          color: hasImages ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          hasImages
                              ? '${place.images.gallery.length} images'
                              : 'No images',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
