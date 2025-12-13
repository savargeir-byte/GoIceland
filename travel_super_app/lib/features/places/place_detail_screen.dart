import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../data/models/place_model.dart';

/// 📍 Place Detail Screen - Shows detailed information about a place
class PlaceDetailScreen extends StatelessWidget {
  final PlaceModel place;

  const PlaceDetailScreen({
    super.key,
    required this.place,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero Image with App Bar
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                place.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 4,
                      color: Colors.black45,
                    ),
                  ],
                ),
              ),
              background: place.images.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: place.images.first,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.landscape, size: 64),
                      ),
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.landscape, size: 64),
                    ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category & Rating
                  Row(
                    children: [
                      _buildCategoryChip(place.type),
                      const SizedBox(width: 12),
                      if (place.rating != null) ...[
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          place.rating!.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                      const Spacer(),
                      if (place.meta?['region'] != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.place,
                                  size: 16, color: Colors.blue),
                              const SizedBox(width: 4),
                              Text(
                                place.meta!['region'],
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Description
                  if (place.description != null &&
                      place.description!.isNotEmpty)
                    _buildSection(
                      icon: Icons.description,
                      title: 'Lýsing',
                      child: Text(
                        place.description!,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.6,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Coordinates
                  _buildSection(
                    icon: Icons.map,
                    title: 'Staðsetning',
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.my_location,
                                size: 20, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              'Lat: ${place.lat.toStringAsFixed(4)}',
                              style: const TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.explore,
                                size: 20, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              'Lng: ${place.lng.toStringAsFixed(4)}',
                              style: const TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Additional Images
                  if (place.images.length > 1) ...[
                    _buildSection(
                      icon: Icons.photo_library,
                      title: 'Myndir',
                      child: SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: place.images.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: CachedNetworkImage(
                                  imageUrl: place.images[index],
                                  width: 180,
                                  height: 120,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    width: 180,
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    width: 180,
                                    color: Colors.grey[300],
                                    child:
                                        const Icon(Icons.image_not_supported),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Open in maps
                          },
                          icon: const Icon(Icons.directions),
                          label: const Text('Leiðir'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // TODO: Share place
                          },
                          icon: const Icon(Icons.share),
                          label: const Text('Deila'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    final categoryInfo = _getCategoryInfo(category);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: categoryInfo['color'],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(categoryInfo['icon'], size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            categoryInfo['label'],
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getCategoryInfo(String category) {
    switch (category.toLowerCase()) {
      case 'waterfall':
        return {
          'label': 'Foss',
          'icon': Icons.water_drop,
          'color': Colors.blue[600],
        };
      case 'glacier':
        return {
          'label': 'Jökull',
          'icon': Icons.ac_unit,
          'color': Colors.lightBlue[300],
        };
      case 'hot_spring':
        return {
          'label': 'Heitar laugar',
          'icon': Icons.hot_tub,
          'color': Colors.orange[600],
        };
      case 'viewpoint':
        return {
          'label': 'Útsýnisstaður',
          'icon': Icons.landscape,
          'color': Colors.green[600],
        };
      case 'beach':
        return {
          'label': 'Strönd',
          'icon': Icons.beach_access,
          'color': Colors.amber[700],
        };
      case 'cave':
        return {
          'label': 'Hellir',
          'icon': Icons.circle,
          'color': Colors.brown[600],
        };
      case 'peak':
        return {
          'label': 'Fjall',
          'icon': Icons.terrain,
          'color': Colors.grey[700],
        };
      case 'restaurant':
        return {
          'label': 'Veitingastaður',
          'icon': Icons.restaurant,
          'color': Colors.red[600],
        };
      default:
        return {
          'label': category,
          'icon': Icons.place,
          'color': Colors.grey[600],
        };
    }
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 24, color: Colors.blue),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}
