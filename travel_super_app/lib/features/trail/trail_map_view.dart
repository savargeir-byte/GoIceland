import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../data/models/trail_model.dart';

/// Full-screen map view for displaying a hiking trail with polyline, start/end markers
class TrailMapView extends StatefulWidget {
  final TrailModel trail;

  const TrailMapView({
    required this.trail,
    super.key,
  });

  @override
  State<TrailMapView> createState() => _TrailMapViewState();
}

class _TrailMapViewState extends State<TrailMapView> {
  MapboxMap? _mapboxMap;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
  }

  void _onMapCreated(MapboxMap mapboxMap) {
    _mapboxMap = mapboxMap;
    _drawTrail();
  }

  Future<void> _drawTrail() async {
    if (_mapboxMap == null) return;
    setState(() => _isLoading = true);

    try {
      final coords = widget.trail.polyline;
      if (coords.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      // Add polyline as a LineString GeoJSON source
      await _mapboxMap!.style.addSource(GeoJsonSource(
        id: 'trail-source',
        data: '''
{
  "type": "Feature",
  "geometry": {
    "type": "LineString",
    "coordinates": ${coords.map((p) => '[${p['lng']}, ${p['lat']}]').toList()}
  }
}
''',
      ));

      // Add line layer
      await _mapboxMap!.style.addLayer(LineLayer(
        id: 'trail-layer',
        sourceId: 'trail-source',
        lineColor: int.parse('FF4A90E2', radix: 16),
        lineWidth: 6.0,
        lineOpacity: 0.95,
      ));

      // Add start marker
      await _mapboxMap!.annotations
          .createPointAnnotationManager()
          .then((manager) {
        manager.create(PointAnnotationOptions(
          geometry: Point(
            coordinates: Position(widget.trail.startLng, widget.trail.startLat),
          ),
          iconImage: 'assets/icons/pin_start.png',
          iconSize: 1.5,
        ));
      });

      // Add end marker (use last coordinate)
      final endCoord = coords.last;
      await _mapboxMap!.annotations
          .createPointAnnotationManager()
          .then((manager) {
        manager.create(PointAnnotationOptions(
          geometry: Point(
            coordinates: Position(endCoord['lng']!, endCoord['lat']!),
          ),
          iconImage: 'assets/icons/pin_end.png',
          iconSize: 1.5,
        ));
      });

      // Fit camera to bounds
      final lats = coords.map((c) => c['lat']!).toList();
      final lngs = coords.map((c) => c['lng']!).toList();
      final minLat = lats.reduce((a, b) => a < b ? a : b);
      final maxLat = lats.reduce((a, b) => a > b ? a : b);
      final minLng = lngs.reduce((a, b) => a < b ? a : b);
      final maxLng = lngs.reduce((a, b) => a > b ? a : b);

      await _mapboxMap!.flyTo(
        CameraOptions(
          center: Point(
            coordinates: Position(
              (minLng + maxLng) / 2,
              (minLat + maxLat) / 2,
            ),
          ),
          zoom: _calculateZoomLevel(minLat, maxLat, minLng, maxLng),
          padding: MbxEdgeInsets(
            top: 120,
            left: 40,
            bottom: 120,
            right: 40,
          ),
        ),
        MapAnimationOptions(duration: 2000),
      );

      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('Error drawing trail: $e');
      setState(() => _isLoading = false);
    }
  }

  double _calculateZoomLevel(
      double minLat, double maxLat, double minLng, double maxLng) {
    final latDiff = maxLat - minLat;
    final lngDiff = maxLng - minLng;
    final maxDiff = latDiff > lngDiff ? latDiff : lngDiff;

    if (maxDiff > 5) return 7;
    if (maxDiff > 2) return 9;
    if (maxDiff > 1) return 10;
    if (maxDiff > 0.5) return 11;
    return 12;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.trail.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showTrailInfo(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          MapWidget(
            key: ValueKey('trail_map_${widget.trail.id}'),
            cameraOptions: CameraOptions(
              center: Point(
                coordinates:
                    Position(widget.trail.startLng, widget.trail.startLat),
              ),
              zoom: 12.0,
            ),
            onMapCreated: _onMapCreated,
          ),
          if (_isLoading)
            Container(
              color: Colors.black26,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(color: Colors.white),
            ),
          // Trail info overlay (bottom sheet style)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildTrailInfoCard(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _handleStartNavigation(),
        icon: const Icon(Icons.directions),
        label: const Text('Byrja leið'),
        backgroundColor: const Color(0xFF00D4AA),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildTrailInfoCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Color(int.parse(
                          widget.trail.difficultyColor.substring(1),
                          radix: 16) +
                      0xFF000000),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.trail.difficulty,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                widget.trail.region,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(Icons.straighten, '${widget.trail.lengthKm} km'),
              _buildStatItem(Icons.schedule, widget.trail.formattedDuration),
              _buildStatItem(Icons.terrain, '${widget.trail.elevationGain}m'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _showTrailInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.all(24),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                widget.trail.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Upplýsingar um gönguleið',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              if (widget.trail.gpxUrl != null) ...[
                ElevatedButton.icon(
                  onPressed: () => _downloadGPX(),
                  icon: const Icon(Icons.download),
                  label: const Text('Hlaða niður GPX'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D4AA),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _handleStartNavigation() {
    // TODO: Integrate with navigation app or provide GPX download
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opnar leiðsögu...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _downloadGPX() {
    // TODO: Implement GPX download
    if (widget.trail.gpxUrl != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hleður niður GPX: ${widget.trail.gpxUrl}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
