import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../core/theme/color_palette.dart';
import '../../core/widgets/bottom_sheet.dart';
import '../../data/api/poi_api.dart';
import '../../data/models/poi_model.dart';
import '../../data/models/trail_model.dart';
import 'pin_details_sheet.dart';

class MapScreen extends StatefulWidget {
  final TrailModel? trail;

  const MapScreen({super.key, this.trail});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final _poiApi = PoiApi();
  final _searchController = TextEditingController();
  List<PoiModel> _pois = const [];
  int _selectedIndex = 0;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPins();

    // If trail provided, zoom to trail start
    if (widget.trail != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(
          LatLng(widget.trail!.startLat, widget.trail!.startLng),
          12.0,
        );
      });
    }
  }

  Future<void> _loadPins() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      final data = await _poiApi.fetchFeatured();
      if (mounted) {
        setState(() {
          _pois = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gat ekki sótt staði: $e';
          _isLoading = false;
        });
      }
      if (kDebugMode) {
        print('Error loading POIs: $e');
      }
    }
  }

  void _onPoiTap(PoiModel poi) {
    final index = _pois.indexOf(poi);
    if (index != -1) {
      setState(() => _selectedIndex = index);
      _mapController.move(
        LatLng(poi.latitude, poi.longitude),
        13.0,
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map or error state
          if (_errorMessage != null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _loadPins,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reyna aftur'),
                  ),
                ],
              ),
            )
          else
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: const LatLng(64.1265, -21.8174), // Reykjavik
                initialZoom: 6.0,
                minZoom: 5.0,
                maxZoom: 18.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.goiceland.app',
                  maxZoom: 19,
                ),
                // Trail polyline layer
                if (widget.trail != null && widget.trail!.polyline.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: widget.trail!.polyline
                            .map((p) => LatLng(p['lat']!, p['lng']!))
                            .toList(),
                        color: Colors.blue,
                        strokeWidth: 4.0,
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: _pois.map((poi) {
                    return Marker(
                      point: LatLng(poi.latitude, poi.longitude),
                      width: 40,
                      height: 40,
                      child: GestureDetector(
                        onTap: () => _onPoiTap(poi),
                        child: Icon(
                          Icons.location_on,
                          size: 40,
                          color: _pois.indexOf(poi) == _selectedIndex
                              ? ColorPalette.primary
                              : Colors.red,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),

          // Loading indicator
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),

          // Search bar
          Positioned(
            top: 54,
            left: 16,
            right: 16,
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(16),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search places or "Surprise me"',
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: Icon(Icons.mic_none),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
                onSubmitted: (query) {
                  if (query.toLowerCase().contains('surprise')) {
                    _openSurprise();
                  } else {
                    _searchPlaces(query);
                  }
                },
              ),
            ),
          ),

          // Action buttons
          Positioned(
            top: 130,
            right: 16,
            child: Column(
              children: [
                _RoundButton(
                    icon: Icons.filter_alt_outlined, onPressed: _openFilters),
                const SizedBox(height: 12),
                _RoundButton(
                  icon: Icons.my_location,
                  onPressed: () {
                    _mapController.move(
                      const LatLng(64.1265, -21.8174),
                      6.0,
                    );
                  },
                ),
              ],
            ),
          ),

          // Hero spot card
          if (_pois.isNotEmpty)
            Positioned(
              top: 200,
              left: 16,
              right: 16,
              child: _HeroSpotCard(
                poi: _pois[_selectedIndex.clamp(0, _pois.length - 1)],
                onTap: () =>
                    _openPoi(_pois[_selectedIndex.clamp(0, _pois.length - 1)]),
              ),
            ),

          // Surprise me button
          Positioned(
            bottom: 120,
            right: 16,
            child: FloatingActionButton.extended(
              onPressed: _openSurprise,
              label: const Text('Surprise Me'),
              icon: const Icon(Icons.auto_awesome),
              backgroundColor: ColorPalette.primary,
            ),
          ),

          // Preview carousel
          if (_pois.isNotEmpty)
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 180,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: _pois.length,
                  itemBuilder: (context, index) {
                    return _SpotPreviewCard(
                      poi: _pois[index],
                      isSelected: index == _selectedIndex,
                      onTap: () {
                        setState(() => _selectedIndex = index);
                        _mapController.move(
                          LatLng(_pois[index].latitude, _pois[index].longitude),
                          13.0,
                        );
                      },
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _openPoi(PoiModel poi) {
    AppBottomSheet.show(
      context: context,
      child: PinDetailsSheet(poi: poi),
    );
  }

  void _openFilters() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Filters coming soon!')),
    );
  }

  void _openSurprise() {
    if (_pois.isEmpty) return;
    final randomIndex = DateTime.now().millisecond % _pois.length;
    setState(() => _selectedIndex = randomIndex);
    _mapController.move(
      LatLng(_pois[randomIndex].latitude, _pois[randomIndex].longitude),
      13.0,
    );
  }

  void _searchPlaces(String query) {
    if (query.isEmpty) return;

    // Search through POIs
    final results = _pois.where((poi) {
      return poi.name.toLowerCase().contains(query.toLowerCase()) ||
          poi.type.toLowerCase().contains(query.toLowerCase());
    }).toList();

    if (results.isNotEmpty) {
      final index = _pois.indexOf(results.first);
      setState(() => _selectedIndex = index);
      _mapController.move(
        LatLng(results.first.latitude, results.first.longitude),
        13.0,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Found ${results.length} results')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No results found')),
      );
    }
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.onPressed});
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
        color: Colors.black87,
      ),
    );
  }
}

class _HeroSpotCard extends StatelessWidget {
  const _HeroSpotCard({required this.poi, required this.onTap});
  final PoiModel poi;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                poi.image ?? 'https://via.placeholder.com/80',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    poi.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    poi.type,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        poi.rating?.toStringAsFixed(1) ?? 'N/A',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}

class _SpotPreviewCard extends StatelessWidget {
  const _SpotPreviewCard({
    required this.poi,
    required this.isSelected,
    required this.onTap,
  });

  final PoiModel poi;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 170,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? ColorPalette.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
              child: Image.network(
                poi.image ?? 'https://via.placeholder.com/170x100',
                width: double.infinity,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: double.infinity,
                  height: 100,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    poi.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        poi.rating?.toStringAsFixed(1) ?? 'N/A',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
