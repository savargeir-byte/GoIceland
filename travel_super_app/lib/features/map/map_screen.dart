import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../core/theme/color_palette.dart';
import '../../core/widgets/bottom_sheet.dart';
import '../../data/api/poi_api.dart';
import '../../data/models/poi_model.dart';
import 'pin_details_sheet.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapboxMap? _mapboxMap;
  PointAnnotationManager? _annotationManager;
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
      await _showPoisOnMap();
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

  void _onMapCreated(MapboxMap mapboxMap) {
    _mapboxMap = mapboxMap;
    _showPoisOnMap();
  }

  @override
  void dispose() {
    unawaited(_annotationManager?.deleteAll());
    _annotationManager = null;
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final token =
        dotenv.isInitialized ? dotenv.env['MAPBOX_ACCESS_TOKEN'] : null;
    if (token != null) {
      MapboxOptions.setAccessToken(token);
    }

    return Scaffold(
      body: Stack(
        children: [
          // Map or error state
          if (_errorMessage != null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey),
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
          else if (token == null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.map_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Mapbox token vantar',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bættu MAPBOX_ACCESS_TOKEN við .env',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            )
          else
            MapWidget(
              key: const ValueKey('mapbox-map'),
              styleUri: MapboxStyles.OUTDOORS,
              cameraOptions: CameraOptions(
                center: Point(
                  coordinates: Position(-21.8174, 64.1265),
                ),
                zoom: 6,
              ),
              onMapCreated: _onMapCreated,
            ),

          // Loading indicator
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
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
                onSubmitted: (_) => _openFilters(),
              ),
            ),
          ),
          Positioned(
            top: 130,
            right: 16,
            child: Column(
              children: [
                _RoundButton(
                    icon: Icons.filter_alt_outlined, onPressed: _openFilters),
                const SizedBox(height: 12),
                _RoundButton(icon: Icons.my_location, onPressed: () {}),
              ],
            ),
          ),
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
          if (_pois.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: 16,
              child: SizedBox(
                height: 150,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (_, index) => _SpotPreviewCard(
                    poi: _pois[index],
                    isSelected: index == _selectedIndex,
                    onTap: () => _focusOnPoi(index),
                  ),
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemCount: _pois.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _openFilters() {
    AppBottomSheet.show(
      context: context,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filters', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              children: [
                FilterChip(
                    label: const Text('Food'),
                    selected: true,
                    onSelected: (_) {}),
                FilterChip(label: const Text('Photo'), onSelected: (_) {}),
                FilterChip(label: const Text('Nature'), onSelected: (_) {}),
                FilterChip(label: const Text('Wellness'), onSelected: (_) {}),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  void _openSurprise() {
    if (_pois.isEmpty) return;
    _openPoi(_pois.first);
  }

  void _openPoi(PoiModel poi) {
    AppBottomSheet.show(
      context: context,
      child: PinDetailsSheet(poi: poi),
    );
  }

  Future<void> _showPoisOnMap() async {
    if (_mapboxMap == null || _pois.isEmpty) return;
    _annotationManager ??=
        await _mapboxMap!.annotations.createPointAnnotationManager();
    await _annotationManager!.deleteAll();
    for (final poi in _pois) {
      await _annotationManager!.create(
        PointAnnotationOptions(
          geometry: Point(
            coordinates: Position(poi.longitude, poi.latitude),
          ),
          iconImage: 'marker-15',
          textField: poi.name,
          textOffset: const [0, -1.2],
          textSize: 10,
        ),
      );
    }
  }

  Future<void> _focusOnPoi(int index) async {
    if (_mapboxMap == null || index >= _pois.length) return;
    final poi = _pois[index];
    setState(() => _selectedIndex = index);
    await _mapboxMap!.flyTo(
      CameraOptions(
        center: Point(coordinates: Position(poi.longitude, poi.latitude)),
        zoom: 12,
      ),
      MapAnimationOptions(duration: 1200, startDelay: 0),
    );
    _openPoi(poi);
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 4,
      child: IconButton(icon: Icon(icon), onPressed: onPressed),
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
          borderRadius: BorderRadius.circular(28),
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
                blurRadius: 24, offset: Offset(0, 10), color: Colors.black26)
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: AspectRatio(
                aspectRatio: 1,
                child: _PoiImage(imageUrl: poi.image),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(poi.name,
                      style: Theme.of(context).textTheme.titleMedium),
                  Text(poi.type.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(poi.rating?.toStringAsFixed(1) ?? 'New'),
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

class _SpotPreviewCard extends StatelessWidget {
  const _SpotPreviewCard({
    required this.poi,
    required this.onTap,
    required this.isSelected,
  });

  final PoiModel poi;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 170,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: Colors.white,
          border: Border.all(
              color: isSelected ? ColorPalette.primary : Colors.transparent,
              width: 2),
          boxShadow: const [
            BoxShadow(
                blurRadius: 16, offset: Offset(0, 8), color: Colors.black26)
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: _PoiImage(imageUrl: poi.image),
              ),
            ),
            const SizedBox(height: 8),
            Text(poi.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall),
            Text(poi.type, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _PoiImage extends StatelessWidget {
  const _PoiImage({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Image.asset('assets/images/placeholder.jpg', fit: BoxFit.cover);
    }
    return Image.network(
      imageUrl!,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
          Image.asset('assets/images/placeholder.jpg', fit: BoxFit.cover),
      loadingBuilder: (_, child, progress) => progress == null
          ? child
          : Container(
              color: Colors.grey.shade200,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
    );
  }
}
