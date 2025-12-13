import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../data/models/poi_model_full.dart';
import '../../places/widgets/place_detail_full.dart';

/// 🗺️ MAP SCREEN - Shows all places as markers on OpenStreetMap
/// 100% FREE - No API key needed!
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  String? _selectedCategory;

  // Layer toggles
  bool _showPlaces = true;
  bool _showTrails = true;

  // Iceland center
  static const _initialCenter = LatLng(64.9631, -19.0208);
  static const _initialZoom = 6.5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // OpenStreetMap with markers and polylines
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('places').snapshots(),
            builder: (context, placesSnapshot) {
              // Debug Firebase connection
              print('📡 Places snapshot state: ${placesSnapshot.connectionState}');
              if (placesSnapshot.hasError) {
                print('❌ Places error: ${placesSnapshot.error}');
              }
              
              return StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('trails').snapshots(),
                builder: (context, trailsSnapshot) {
                  // Debug Firebase connection
                  print('📡 Trails snapshot state: ${trailsSnapshot.connectionState}');
                  if (trailsSnapshot.hasError) {
                    print('❌ Trails error: ${trailsSnapshot.error}');
                  }
                  
                  // Debug logging
                  if (placesSnapshot.hasData) {
                    print('🏔️ Places count: ${placesSnapshot.data!.docs.length}');
                  }
                  if (trailsSnapshot.hasData) {
                    print('🥾 Trails count: ${trailsSnapshot.data!.docs.length}');
                  }

                  // Build markers
                  final markers = _showPlaces && placesSnapshot.hasData
                      ? _buildMarkersSync(placesSnapshot.data!.docs)
                      : <Marker>[];

                  // Build polylines
                  final polylines = _showTrails && trailsSnapshot.hasData
                      ? _buildPolylinesSync(trailsSnapshot.data!.docs)
                      : <Polyline>[];

                  print('🗺️ Rendering ${markers.length} markers and ${polylines.length} polylines');

                  return FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _initialCenter,
                      initialZoom: _initialZoom,
                      minZoom: 5.0,
                      maxZoom: 18.0,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.all,
                      ),
                    ),
                    children: [
                      // OpenStreetMap tiles (FREE!)
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.travel_super_app',
                        maxZoom: 19,
                      ),

                      // Trail polylines
                      if (_showTrails)
                        PolylineLayer(
                          polylines: polylines,
                        ),

                      // Place markers
                      if (_showPlaces)
                        MarkerLayer(
                          markers: markers,
                        ),
                    ],
                  );
                },
              );
            },
          ),

          // Layer toggle switches at top left
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: _buildLayerToggles(),
          ),

          // Category filter chips at top right
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: _buildCategoryFilters(),
          ),

          // My Location button
          Positioned(
            bottom: 100,
            right: 16,
            child: FloatingActionButton(
              heroTag: 'myLocation',
              mini: true,
              onPressed: () {
                // TODO: Get user location and animate camera
                _mapController.move(_initialCenter, _initialZoom);
              },
              child: const Icon(Icons.my_location),
            ),
          ),

          // Zoom controls
          Positioned(
            bottom: 160,
            right: 16,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'zoomIn',
                  mini: true,
                  backgroundColor: Colors.white,
                  onPressed: () {
                    final currentZoom = _mapController.camera.zoom;
                    final newZoom = (currentZoom + 1).clamp(5.0, 18.0);
                    print('🔍 Zooming in: $currentZoom -> $newZoom');
                    _mapController.move(
                      _mapController.camera.center,
                      newZoom,
                    );
                  },
                  child: const Icon(Icons.add, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'zoomOut',
                  mini: true,
                  backgroundColor: Colors.white,
                  onPressed: () {
                    final currentZoom = _mapController.camera.zoom;
                    final newZoom = (currentZoom - 1).clamp(5.0, 18.0);
                    print('🔍 Zooming out: $currentZoom -> $newZoom');
                    _mapController.move(
                      _mapController.camera.center,
                      newZoom,
                    );
                  },
                  child: const Icon(Icons.remove, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Marker> _buildMarkersSync(List<QueryDocumentSnapshot> docs) {
    final markers = <Marker>[];
    print('📍 Building markers from ${docs.length} places');

    for (var doc in docs) {
      try {
        final data = doc.data() as Map<String, dynamic>;
        final latRaw = data['lat'] ?? data['latitude'];
        final lngRaw = data['lng'] ?? data['longitude'];
        final category = data['category'] ?? '';

        if (latRaw == null || lngRaw == null) continue;

        // Convert to double safely
        final lat = latRaw is num ? latRaw.toDouble() : double.tryParse(latRaw.toString());
        final lng = lngRaw is num ? lngRaw.toDouble() : double.tryParse(lngRaw.toString());
        
        if (lat == null || lng == null) {
          print('  ❌ ${data['name']}: Invalid coordinates ($latRaw, $lngRaw)');
          continue;
        }

        print('  ✅ ${data['name']}: ($lat, $lng) [$category]');

        // Filter by category if selected
        if (_selectedCategory != null && category != _selectedCategory) {
          continue;
        }

        markers.add(
          Marker(
            point: LatLng(lat, lng),
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: () => _showPlaceBottomSheet(data),
              child: Icon(
                _getCategoryIcon(category),
                color: _getCategoryColor(category),
                size: 40,
                shadows: const [
                  Shadow(color: Colors.white, blurRadius: 10),
                  Shadow(color: Colors.white, blurRadius: 20),
                ],
              ),
            ),
          ),
        );
      } catch (e) {
        print('Error building marker: $e');
      }
    }

    return markers;
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'waterfall':
        return Icons.water;
      case 'glacier':
        return Icons.ac_unit;
      case 'hot_spring':
        return Icons.hot_tub;
      case 'beach':
        return Icons.beach_access;
      case 'restaurant':
        return Icons.restaurant;
      case 'hotel':
        return Icons.hotel;
      default:
        return Icons.place;
    }
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
        return Colors.red;
    }
  }

  void _showPlaceBottomSheet(Map<String, dynamic> data) {
    final name = data['name'] ?? 'Unknown';
    final category = data['category'] ?? data['type'] ?? '';
    
    // Get description from multiple possible fields
    String? description;
    if (data['description'] is Map) {
      final desc = data['description'] as Map<String, dynamic>;
      description = desc['short'] ?? desc['history'] ?? desc['saga_og_menning'];
    } else if (data['description'] is String) {
      description = data['description'];
    } else if (data['descriptions'] is Map) {
      final desc = data['descriptions'] as Map<String, dynamic>;
      description = desc['short'] ?? desc['history'];
    }
    
    // Truncate long descriptions
    if (description != null && description.length > 200) {
      description = '${description.substring(0, 200)}...';
    }

    // Get image from multiple possible fields
    String? imageUrl;
    if (data['media'] is Map) {
      final media = data['media'] as Map<String, dynamic>;
      imageUrl = media['hero_image'] ?? media['thumbnail'];
      if (imageUrl == null && media['images'] is List && (media['images'] as List).isNotEmpty) {
        imageUrl = media['images'][0];
      }
    }
    imageUrl ??= data['image'];
    if (imageUrl == null && data['images'] is List && (data['images'] as List).isNotEmpty) {
      imageUrl = data['images'][0];
    }

    // Get rating
    final rating = data['rating'] ?? (data['ratings'] is Map ? data['ratings']['google'] : null);
    
    // Get region/location
    final region = data['region'] ?? data['municipality'] ?? data['area'];
    
    // Get tags
    List<String>? tags;
    if (data['tags'] is List) {
      tags = (data['tags'] as List).map((e) => e.toString()).toList();
    }
    
    // Get coordinates
    final lat = data['lat'] ?? data['latitude'];
    final lng = data['lng'] ?? data['longitude'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              // Image
              if (imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                    ),
                  ),
                ),
              
              const SizedBox(height: 16),
              
              // Name and Category
              Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(category).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      category.replaceAll('_', ' ').toUpperCase(),
                      style: TextStyle(
                        color: _getCategoryColor(category),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Rating and Region
              Row(
                children: [
                  if (rating != null) ...[
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  if (region != null) ...[
                    const Icon(Icons.location_on, color: Colors.grey, size: 20),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        region,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              
              // Coordinates
              if (lat != null && lng != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.my_location, color: Colors.grey, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ],
              
              // Tags
              if (tags != null && tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: tags.take(5).map((tag) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  )).toList(),
                ),
              ],
              
              // Description
              if (description != null) ...[
                const SizedBox(height: 16),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                    height: 1.5,
                  ),
                ),
              ],
              
              const SizedBox(height: 20),
              
              // View Details Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _openPlaceDetail(data);
                  },
                  child: const Text(
                    'View Full Details',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openPlaceDetail(Map<String, dynamic> data) {
    try {
      final place = PoiModelFull.fromJson(data);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PlaceDetailFull(place: place),
        ),
      );
    } catch (e) {
      print('Error opening detail: $e');
    }
  }

  Widget _buildLayerToggles() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _layerToggle(
            icon: Icons.place,
            label: 'Places',
            value: _showPlaces,
            onChanged: (value) => setState(() => _showPlaces = value),
          ),
          const SizedBox(height: 8),
          _layerToggle(
            icon: Icons.hiking,
            label: 'Trails',
            value: _showTrails,
            onChanged: (value) => setState(() => _showTrails = value),
          ),
        ],
      ),
    );
  }

  Widget _layerToggle({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: value ? Colors.blue : Colors.grey),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: value ? Colors.black : Colors.grey,
          ),
        ),
        const SizedBox(width: 8),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.blue,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    );
  }

  List<Polyline> _buildPolylinesSync(List<QueryDocumentSnapshot> docs) {
    final polylines = <Polyline>[];

    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;

      // Get polyline from flat array
      final polylineData = data['polyline'] as List?;
      if (polylineData == null || polylineData.isEmpty) continue;

      // Convert flat array [lat, lng, lat, lng, ...] to List<LatLng>
      final points = <LatLng>[];
      for (int i = 0; i < polylineData.length - 1; i += 2) {
        final latRaw = polylineData[i];
        final lngRaw = polylineData[i + 1];
        if (latRaw != null && lngRaw != null) {
          // Convert to double safely
          final lat = latRaw is num ? latRaw.toDouble() : double.tryParse(latRaw.toString());
          final lng = lngRaw is num ? lngRaw.toDouble() : double.tryParse(lngRaw.toString());
          if (lat != null && lng != null) {
            points.add(LatLng(lat, lng));
          }
        }
      }

      if (points.isEmpty) continue;

      // Get difficulty color
      final difficulty = data['difficulty'] as String?;
      Color color = Colors.blue;
      if (difficulty != null) {
        color = _getDifficultyColor(difficulty);
      }

      polylines.add(Polyline(
        points: points,
        strokeWidth: 3,
        color: color.withOpacity(0.7),
      ));
    }

    return polylines;
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

  Widget _buildCategoryFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _filterChip('All', null, Icons.place),
          _filterChip('Waterfalls', 'waterfall', Icons.water),
          _filterChip('Glaciers', 'glacier', Icons.ac_unit),
          _filterChip('Hot Springs', 'hot_spring', Icons.hot_tub),
          _filterChip('Beaches', 'beach', Icons.beach_access),
          _filterChip('Trails', 'trail', Icons.hiking),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String? category, IconData icon) {
    final isSelected = _selectedCategory == category;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 4),
            Text(label),
          ],
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _selectedCategory = selected ? category : null);
        },
        backgroundColor: Colors.white,
        selectedColor: Colors.blue.withOpacity(0.3),
      ),
    );
  }
}
