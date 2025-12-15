import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/categories.dart';

// Removed unused imports

/// 🔍 EXPLORE SCREEN - Browse all places in a list
/// Real-time Firebase updates with search and filters
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String _searchQuery = '';
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Search bar
          SliverAppBar(
            floating: true,
            snap: true,
            title: TextField(
              decoration: const InputDecoration(
                hintText: 'Search places...',
                border: InputBorder.none,
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),

          // Category filters
          SliverToBoxAdapter(
            child: SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  _categoryChip('All', null),
                  ...PlaceCategories.byGroup('nature')
                      .take(5)
                      .map((cat) => _categoryChip(
                            '${cat.emoji} ${cat.label}',
                            cat.id,
                          )),
                  ...PlaceCategories.byGroup('food')
                      .take(2)
                      .map((cat) => _categoryChip(
                            '${cat.emoji} ${cat.label}',
                            cat.id,
                          )),
                ],
              ),
            ),
          ),

          // Places list from Firebase
          StreamBuilder<QuerySnapshot>(
            stream: _buildQuery().snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Text('No places found'),
                  ),
                );
              }

              final docs = snapshot.data!.docs;

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    try {
                      final data = docs[index].data() as Map<String, dynamic>;
                      return _buildPlaceCard(data);
                    } catch (e) {
                      return ListTile(
                        title: Text('Error loading place: $e'),
                      );
                    }
                  },
                  childCount: docs.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Query<Map<String, dynamic>> _buildQuery() {
    Query<Map<String, dynamic>> query =
        FirebaseFirestore.instance.collection('places');

    // Filter by category
    if (_selectedCategory != null) {
      query = query.where('category', isEqualTo: _selectedCategory);
    }

    // Sort by rating
    // Note: Requires Firestore index
    // query = query.orderBy('rating', descending: true);

    return query.limit(50);
  }

  Widget _categoryChip(String label, String? category) {
    final isSelected = _selectedCategory == category;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _selectedCategory = selected ? category : null);
        },
      ),
    );
  }

  Widget _buildPlaceCard(Map<String, dynamic> data) {
    final name = data['name'] ?? 'Unknown';
    final category = data['category'] ?? '';
    final rating = (data['rating'] as num?)?.toDouble();
    final region = data['region'] as String?;
    final tags = data['tags'] as List?;

    // Get description
    String? description;
    if (data['descriptions'] != null) {
      final desc = data['descriptions'];
      description = desc['short'] ?? desc['saga_og_menning'];
      if (description != null && description.length > 100) {
        description = '${description.substring(0, 100)}...';
      }
    }

    // Get image
    String? imageUrl;
    if (data['media'] != null) {
      imageUrl = data['media']['hero_image'] ?? data['media']['thumbnail'];
    } else if (data['image'] != null) {
      imageUrl = data['image'];
    } else if (data['images'] is List && (data['images'] as List).isNotEmpty) {
      imageUrl = data['images'][0];
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openPlaceDetail(data),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (imageUrl != null)
              SizedBox(
                width: 120,
                height: 120,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported),
                  ),
                ),
              ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Category badge
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(category).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            category.replaceAll('_', ' ').toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              color: _getCategoryColor(category),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (region != null) ...[
                          const SizedBox(width: 6),
                          Icon(Icons.location_on,
                              size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 2),
                          Text(
                            region,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),

                    if (description != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    if (rating != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],

                    // Tags
                    if (tags != null && tags.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 4,
                        children: tags.take(3).map((tag) {
                          return Text(
                            '#$tag',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Arrow
            const Padding(
              padding: EdgeInsets.all(16),
              child: Icon(Icons.chevron_right),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'waterfall':
        return Colors.blue;
      case 'glacier':
        return Colors.cyan;
      case 'hot_spring':
        return Colors.orange;
      case 'beach':
        return Colors.brown;
      case 'restaurant':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _openPlaceDetail(Map<String, dynamic> data) {
    try {
      // TODO: Navigate to detail screen when ready
      final name = data['name'] ?? 'Unknown Place';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Opening: $name')),
      );
    } catch (e) {
      print('Error opening detail: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading place details: $e')),
      );
    }
  }
}
