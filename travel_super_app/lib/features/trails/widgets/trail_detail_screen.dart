import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// 🥾 TRAIL DETAIL SCREEN - Complete trail information
class TrailDetailScreen extends StatelessWidget {
  final Map<String, dynamic> trail;

  const TrailDetailScreen({super.key, required this.trail});

  @override
  Widget build(BuildContext context) {
    final name = trail['name'] ?? 'Unknown Trail';
    final difficulty = trail['difficulty'] ?? '';
    final distance = trail['distance_km'] as num?;
    final duration = trail['duration_hours'] as num?;
    final elevation = trail['elevation_gain_m'] as num?;
    final description = trail['description'] ?? 'No description available';
    
    // Get images
    String? heroImage;
    List<String> images = [];
    if (trail['media'] is Map) {
      final media = trail['media'] as Map<String, dynamic>;
      heroImage = media['hero_image'];
      if (media['images'] is List) {
        images = (media['images'] as List).cast<String>();
      }
    }
    heroImage ??= trail['image'];
    if (heroImage == null && trail['images'] is List) {
      final imgList = trail['images'] as List;
      if (imgList.isNotEmpty) {
        heroImage = imgList[0];
        images = imgList.cast<String>();
      }
    }

    // Get coordinates for map
    final startLat = trail['start_lat'] ?? trail['latitude'];
    final startLng = trail['start_lng'] ?? trail['longitude'];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero Image AppBar
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (heroImage != null)
                    CachedNetworkImage(
                      imageUrl: heroImage,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.green[700]!, Colors.green[300]!],
                          ),
                        ),
                        child: const Icon(Icons.terrain, size: 80, color: Colors.white70),
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.green[700]!, Colors.green[300]!],
                        ),
                      ),
                      child: const Icon(Icons.terrain, size: 80, color: Colors.white70),
                    ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats Cards
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      if (difficulty.isNotEmpty)
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.bar_chart,
                            label: 'Difficulty',
                            value: difficulty.toUpperCase(),
                            color: _getDifficultyColor(difficulty),
                          ),
                        ),
                      if (distance != null) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.straighten,
                            label: 'Distance',
                            value: '${distance.toStringAsFixed(1)} km',
                            color: Colors.blue,
                          ),
                        ),
                      ],
                      if (duration != null) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.access_time,
                            label: 'Duration',
                            value: '${duration.toStringAsFixed(1)} hrs',
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                if (elevation != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildStatCard(
                      icon: Icons.trending_up,
                      label: 'Elevation Gain',
                      value: '${elevation.round()} m',
                      color: Colors.purple,
                    ),
                  ),

                const SizedBox(height: 24),

                // Description
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'About This Trail',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Map (if coordinates available)
                if (startLat != null && startLng != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Trail Location',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: FlutterMap(
                            options: MapOptions(
                              initialCenter: LatLng(
                                (startLat is num ? startLat.toDouble() : double.tryParse(startLat.toString())) ?? 0,
                                (startLng is num ? startLng.toDouble() : double.tryParse(startLng.toString())) ?? 0,
                              ),
                              initialZoom: 12,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.goiceland.app',
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: LatLng(
                                      (startLat is num ? startLat.toDouble() : double.tryParse(startLat.toString())) ?? 0,
                                      (startLng is num ? startLng.toDouble() : double.tryParse(startLng.toString())) ?? 0,
                                    ),
                                    width: 40,
                                    height: 40,
                                    child: const Icon(
                                      Icons.hiking,
                                      color: Colors.green,
                                      size: 40,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                // Image Gallery
                if (images.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Trail Photos',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 150,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: images.length,
                          itemBuilder: (context, index) {
                            return Container(
                              width: 200,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: CachedNetworkImage(
                                imageUrl: images[index],
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey[200],
                                  child: const Center(child: CircularProgressIndicator()),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.image_not_supported),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'moderate':
        return Colors.orange;
      case 'challenging':
        return Colors.red;
      case 'expert':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
