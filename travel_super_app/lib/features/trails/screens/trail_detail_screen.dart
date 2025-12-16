import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/widgets/premium_lock.dart';

/// 🥾 TRAIL DETAIL SCREEN - Full trail information
/// Shows map, stats, description, and download option
class TrailDetailScreen extends StatefulWidget {
  final String trailId;

  const TrailDetailScreen({super.key, required this.trailId});

  @override
  State<TrailDetailScreen> createState() => _TrailDetailScreenState();
}

class _TrailDetailScreenState extends State<TrailDetailScreen> {
  final MapController _mapController = MapController();
  bool _isSaved = false;

  // TODO: Get from user preferences
  final bool _isPremium = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('trails')
          .doc(widget.trailId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            appBar: AppBar(title: const Text('Trail Not Found')),
            body: const Center(child: Text('Trail not found')),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        return _buildTrailDetail(data);
      },
    );
  }

  Widget _buildTrailDetail(Map<String, dynamic> data) {
    final name = data['name'] ?? 'Unknown Trail';
    final difficulty = data['difficulty'] as String?;
    final distance = data['distance_km'] as num?;
    final duration = data['duration_hours'] as num?;
    final elevationGain = data['elevation_gain_m'] as num?;
    final region = data['region'] as String?;
    final surface = data['surface'] as String?;

    String? description;
    if (data['content'] != null && data['content'] is Map) {
      final content = data['content'] as Map<String, dynamic>;
      if (content['en'] != null && content['en'] is Map) {
        final en = content['en'] as Map<String, dynamic>;
        description = en['description'] as String?;
      }
    }
    // Fallback to old format
    if (description == null && data['descriptions'] != null) {
      final desc = data['descriptions'];
      description = desc['saga_og_menning'] ?? desc['short'];
    }
    description ??= data['description'];

    // Get polyline for map
    final polylineData = data['polyline'] as List?;
    List<LatLng> points = [];
    if (polylineData != null && polylineData.isNotEmpty) {
      for (var point in polylineData) {
        if (point is Map) {
          final lat = point['lat'];
          final lng = point['lng'];
          if (lat != null && lng != null) {
            points.add(LatLng(
              (lat is num ? lat.toDouble() : double.tryParse(lat.toString())) ??
                  0,
              (lng is num ? lng.toDouble() : double.tryParse(lng.toString())) ??
                  0,
            ));
          }
        }
      }
    }

    // Check if expert trail (premium)
    final isExpertTrail = difficulty?.toLowerCase() == 'expert';
    final requiresPremium = isExpertTrail && !_isPremium;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with map
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              background: _buildTrailMapOrFallback(
                points,
                difficulty ?? 'moderate',
                data['startLat'] ?? data['start_lat'] ?? data['latitude'],
                data['startLng'] ?? data['start_lng'] ?? data['longitude'],
              ),
            ),
            actions: [
              // Save button
              IconButton(
                icon: Icon(_isSaved ? Icons.favorite : Icons.favorite_border),
                onPressed: () {
                  setState(() => _isSaved = !_isSaved);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_isSaved ? 'Saved!' : 'Removed from saved'),
                    ),
                  );
                },
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: requiresPremium
                ? PremiumLock(
                    isPremium: _isPremium,
                    featureName: 'Expert Trails',
                    child: _buildContent(data, difficulty, distance, duration,
                        elevationGain, region, surface, description),
                  )
                : _buildContent(data, difficulty, distance, duration,
                    elevationGain, region, surface, description),
          ),
        ],
      ),
    );
  }

  Widget _buildTrailMapOrFallback(
    List<LatLng> points,
    String difficulty,
    dynamic startLat,
    dynamic startLng,
  ) {
    // If we have polyline points, use them
    if (points.isNotEmpty) {
      return _buildTrailMap(points, difficulty);
    }

    // Otherwise, show single marker at start location
    if (startLat != null && startLng != null) {
      final lat = (startLat is num
              ? startLat.toDouble()
              : double.tryParse(startLat.toString())) ??
          0;
      final lng = (startLng is num
              ? startLng.toDouble()
              : double.tryParse(startLng.toString())) ??
          0;

      if (lat != 0 && lng != 0) {
        final center = LatLng(lat, lng);
        return FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: center,
            initialZoom: 13.0,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.drag | InteractiveFlag.pinchZoom,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.travel_super_app',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: center,
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
        );
      }
    }

    // Final fallback
    return Container(
      color: Colors.grey[300],
      child: const Icon(Icons.hiking, size: 80, color: Colors.grey),
    );
  }

  Widget _buildTrailMap(List<LatLng> points, String difficulty) {
    // Calculate bounds
    double minLat = points[0].latitude;
    double maxLat = points[0].latitude;
    double minLng = points[0].longitude;
    double maxLng = points[0].longitude;

    for (final point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    final center = LatLng(
      (minLat + maxLat) / 2,
      (minLng + maxLng) / 2,
    );

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: center,
        initialZoom: 12.0,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.drag | InteractiveFlag.pinchZoom,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.travel_super_app',
        ),
        PolylineLayer(
          polylines: [
            Polyline(
              points: points,
              strokeWidth: 4,
              color: _getDifficultyColor(difficulty),
            ),
          ],
        ),
        MarkerLayer(
          markers: [
            // Start marker
            Marker(
              point: points.first,
              width: 40,
              height: 40,
              child: const Icon(
                Icons.play_circle_filled,
                color: Colors.green,
                size: 40,
              ),
            ),
            // End marker
            Marker(
              point: points.last,
              width: 40,
              height: 40,
              child: const Icon(
                Icons.flag,
                color: Colors.red,
                size: 40,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContent(
    Map<String, dynamic> data,
    String? difficulty,
    num? distance,
    num? duration,
    num? elevationGain,
    String? region,
    String? surface,
    String? description,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats row
          Row(
            children: [
              if (difficulty != null) ...[
                _statChip(
                  icon: Icons.trending_up,
                  label: difficulty.toUpperCase(),
                  color: _getDifficultyColor(difficulty),
                ),
                const SizedBox(width: 8),
              ],
              if (distance != null) ...[
                _statChip(
                  icon: Icons.straighten,
                  label: '${distance.toStringAsFixed(1)} km',
                  color: Colors.blue,
                ),
                const SizedBox(width: 8),
              ],
              if (duration != null)
                _statChip(
                  icon: Icons.access_time,
                  label: '${duration.toStringAsFixed(1)} hrs',
                  color: Colors.orange,
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Additional stats
          if (elevationGain != null || region != null || surface != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (elevationGain != null)
                      _infoRow(
                        Icons.terrain,
                        'Elevation Gain',
                        '${elevationGain.toStringAsFixed(0)} m',
                      ),
                    if (region != null) ...[
                      const Divider(),
                      _infoRow(Icons.location_on, 'Region', region),
                    ],
                    if (surface != null) ...[
                      const Divider(),
                      _infoRow(Icons.landscape, 'Surface', surface),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Description
          if (description != null) ...[
            const Text(
              'About This Trail',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 24),
          ],

          // Download for offline (Premium)
          _isPremium ? _buildDownloadButton() : const PremiumBanner(),

          const SizedBox(height: 16),

          // Start navigation button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Navigation coming soon!'),
                  ),
                );
              },
              icon: const Icon(Icons.navigation),
              label: const Text('Start Navigation'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      backgroundColor: color.withOpacity(0.1),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadButton() {
    return Card(
      color: Colors.green[50],
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Downloading trail for offline use...'),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.download, color: Colors.green[700]),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Download for Offline',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Available with Premium',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
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
        return Colors.blue;
    }
  }
}
