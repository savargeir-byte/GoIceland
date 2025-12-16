import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/constants/categories.dart';
import '../../../data/models/poi_model_full.dart';
import '../../places/widgets/place_detail_full.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Position? _userLocation;
  bool _isLoadingLocation = true;
  String? _locationError;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationError = 'Location services disabled';
          _isLoadingLocation = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationError = 'Permission denied';
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationError = 'Permission denied permanently';
          _isLoadingLocation = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _userLocation = position;
        _isLoadingLocation = false;
      });

      print('📍 GPS: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      print('❌ GPS Error: $e');
      setState(() {
        _locationError = 'GPS error: $e';
        _isLoadingLocation = false;
      });
    }
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const R = 6371;
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }

  double _toRadians(double degrees) => degrees * math.pi / 180;

  String _formatDistance(double km) {
    if (km < 1) {
      return '${(km * 1000).round()}m';
    } else if (km < 10) {
      return '${km.toStringAsFixed(1)}km';
    } else {
      return '${km.round()}km';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          _buildGPSStatus(),
          _buildQuickStats(),
          _buildCategories(),
          _buildSectionHeader(),
          _buildPlacesList(),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'GO ICELAND',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 26,
                letterSpacing: 1.2,
                shadows: [
                  Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3,
                      color: Colors.black26)
                ],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Explore • Trails • Profile',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/app_banner.png',
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGPSStatus() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _locationError != null
                ? [Colors.orange.shade100, Colors.orange.shade50]
                : [const Color(0xFF1E88E5), const Color(0xFF42A5F5)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isLoadingLocation
                      ? Icons.location_searching
                      : _locationError != null
                          ? Icons.location_off
                          : Icons.my_location,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isLoadingLocation
                          ? 'Finding your location...'
                          : _locationError != null
                              ? 'Location Unavailable'
                              : 'GPS Active',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isLoadingLocation
                          ? 'Accessing GPS...'
                          : _locationError != null
                              ? 'Enable location to see nearby places'
                              : 'Showing places sorted by distance',
                      style: TextStyle(
                          fontSize: 13, color: Colors.white.withOpacity(0.9)),
                    ),
                  ],
                ),
              ),
              if (_locationError != null)
                ElevatedButton(
                  onPressed: _getUserLocation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.orange.shade700,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('Retry'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('places').snapshots(),
          builder: (context, snapshot) {
            final placeCount =
                snapshot.hasData ? snapshot.data!.docs.length : 0;
            return Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                      icon: Icons.place,
                      count: '$placeCount',
                      label: 'Places',
                      color: Colors.blue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                      icon: Icons.terrain,
                      count: '401',
                      label: 'Trails',
                      color: Colors.green),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                      icon: Icons.photo_library,
                      count: '1K+',
                      label: 'Photos',
                      color: Colors.purple),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(
      {required IconData icon,
      required String count,
      required String label,
      required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(count,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return SliverToBoxAdapter(
      child: Container(
        height: 60,
        margin: const EdgeInsets.symmetric(vertical: 12),
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            _buildCategoryChip('All', null, Icons.grid_view),
            ...PlaceCategories.all.take(12).map((cat) => _buildCategoryChip(
                  '${cat.emoji} ${cat.label}',
                  cat.id,
                  _getCategoryIcon(cat.id),
                )),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String categoryId) {
    // Map common categories to icons
    const iconMap = {
      'viewpoint': Icons.landscape,
      'landmark': Icons.tour,
      'restaurant': Icons.restaurant,
      'cafe': Icons.local_cafe,
      'hotel': Icons.hotel,
      'hostel': Icons.bed,
      'museum': Icons.museum,
      'hot_spring': Icons.hot_tub,
      'volcano': Icons.terrain,
      'peak': Icons.landscape_outlined,
      'cave': Icons.dark_mode,
      'camping': Icons.cabin,
      'waterfall': Icons.water_drop,
      'glacier': Icons.ac_unit,
      'beach': Icons.beach_access,
    };
    return iconMap[categoryId] ?? Icons.place;
  }

  Widget _buildCategoryChip(String label, String? category, IconData icon) {
    final isSelected = _selectedCategory == category;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 18,
                color: isSelected ? Colors.white : Colors.blue.shade700),
            const SizedBox(width: 6),
            Text(label),
          ],
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _selectedCategory = selected ? category : null);
        },
        backgroundColor: Colors.white,
        selectedColor: Colors.blue.shade600,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.blue.shade700,
          fontWeight: FontWeight.w600,
        ),
        elevation: 2,
        pressElevation: 4,
      ),
    );
  }

  Widget _buildSectionHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.near_me, color: Colors.blue.shade700, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Nearest Attractions',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5)),
            const Spacer(),
            if (_userLocation != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.gps_fixed,
                        size: 14, color: Colors.green.shade700),
                    const SizedBox(width: 4),
                    Text('Sorted',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlacesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('places').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return SliverToBoxAdapter(
            child: Center(
                child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Error: ${snapshot.error}'))),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SliverToBoxAdapter(
            child: Center(
                child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No places found'))),
          );
        }

        List<Map<String, dynamic>> placesWithDistance = [];

        for (var doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final latRaw = data['lat'] ?? data['latitude'];
          final lngRaw = data['lng'] ?? data['longitude'];

          if (latRaw == null || lngRaw == null) continue;

          final lat = latRaw is num
              ? latRaw.toDouble()
              : double.tryParse(latRaw.toString());
          final lng = lngRaw is num
              ? lngRaw.toDouble()
              : double.tryParse(lngRaw.toString());

          if (lat == null || lng == null) continue;

          // Filter by category
          if (_selectedCategory != null) {
            final category = (data['category'] ?? data['type'] ?? '')
                .toString()
                .toLowerCase();
            if (!category.contains(_selectedCategory!.toLowerCase())) continue;
          }

          double? distance;
          if (_userLocation != null) {
            distance = _calculateDistance(
                _userLocation!.latitude, _userLocation!.longitude, lat, lng);
          }

          placesWithDistance.add(
              {'data': data, 'distance': distance, 'lat': lat, 'lng': lng});
        }

        if (_userLocation != null) {
          placesWithDistance.sort((a, b) {
            final distA = a['distance'] as double?;
            final distB = b['distance'] as double?;
            if (distA == null) return 1;
            if (distB == null) return -1;
            return distA.compareTo(distB);
          });
        }

        final nearbyPlaces = placesWithDistance.take(20).toList();

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final placeData = nearbyPlaces[index];
              final data = placeData['data'] as Map<String, dynamic>;
              final distance = placeData['distance'] as double?;

              return _buildPlaceCard(data, distance);
            },
            childCount: nearbyPlaces.length,
          ),
        );
      },
    );
  }

  Widget _buildPlaceCard(Map<String, dynamic> data, double? distance) {
    final name = data['name'] ?? 'Unknown';
    final category = data['category'] ?? data['type'] ?? '';
    final rating =
        data['rating'] is num ? (data['rating'] as num).toDouble() : null;

    String? shortDesc;
    // Try new content.en.description format first
    if (data['content'] is Map) {
      final content = data['content'] as Map<String, dynamic>;
      if (content['en'] is Map) {
        final en = content['en'] as Map<String, dynamic>;
        shortDesc = en['description'] as String?;
      }
    }
    // Fallback to old description format
    if (shortDesc == null) {
      if (data['description'] is Map) {
        final desc = data['description'] as Map<String, dynamic>;
        shortDesc = desc['short'];
      } else if (data['description'] is String) {
        shortDesc = data['description'] as String;
      }
    }

    String? imageUrl;
    if (data['media'] is Map) {
      final media = data['media'] as Map<String, dynamic>;
      imageUrl = media['hero_image'] ?? media['thumbnail'];
      if (imageUrl == null &&
          media['images'] is List &&
          (media['images'] as List).isNotEmpty) {
        imageUrl = media['images'][0];
      }
    }
    imageUrl ??= data['image'];
    if (imageUrl == null &&
        data['images'] is List &&
        (data['images'] as List).isNotEmpty) {
      imageUrl = data['images'][0];
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.white,
          child: InkWell(
            onTap: () {
              try {
                final place = PoiModelFull.fromJson(data);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => PlaceDetailFull(place: place)));
              } catch (e) {
                print('Error opening detail: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Could not open: $e')));
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    if (imageUrl != null)
                      SizedBox(
                        width: double.infinity,
                        height: 180,
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                                child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey.shade200,
                            child: Center(
                                child: Icon(Icons.image_not_supported,
                                    size: 48, color: Colors.grey.shade400)),
                          ),
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        height: 180,
                        color: Colors.grey.shade200,
                        child: Icon(Icons.landscape,
                            size: 64, color: Colors.grey.shade400),
                      ),
                    if (distance != null)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.location_on,
                                  color: Colors.white, size: 14),
                              const SizedBox(width: 4),
                              Text(_formatDistance(distance),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade700.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          category.replaceAll('_', ' ').toUpperCase(),
                          style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (rating != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                  color: Colors.amber.shade50,
                                  borderRadius: BorderRadius.circular(8)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.star,
                                      size: 16, color: Colors.amber.shade700),
                                  const SizedBox(width: 4),
                                  Text(rating.toStringAsFixed(1),
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.amber.shade900)),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (shortDesc != null) ...[
                        const SizedBox(height: 8),
                        Text(shortDesc,
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                                height: 1.4),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Spacer(),
                          Text('View Details',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(width: 4),
                          Icon(Icons.arrow_forward,
                              size: 16, color: Colors.blue.shade700),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
