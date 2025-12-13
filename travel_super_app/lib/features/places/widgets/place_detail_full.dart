import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../data/models/poi_model_full.dart';

/// 🌟 FULLUR DETAIL SCREEN með öllum upplýsingum
/// - Hero image
/// - Description tabs (About, History, Services)
/// - Services icons
/// - Visit info
/// - Wikipedia link
/// - Image gallery

class PlaceDetailFull extends StatelessWidget {
  const PlaceDetailFull({super.key, required this.place});

  final PoiModelFull place;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero image AppBar
          _buildHeroAppBar(context),

          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title & Rating
                _buildHeader(context),

                // Services icons
                if (place.services != null) _buildServices(context),

                // Visit info
                if (place.visitInfo != null) _buildVisitInfo(context),

                // Tabs: About, History, Services
                _buildTabs(context),

                const SizedBox(height: 24),

                // Image gallery
                if (place.images?.isNotEmpty == true)
                  _buildImageGallery(context),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroAppBar(BuildContext context) {
    final imageUrl = place.image ?? place.media?.heroImage;

    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          place.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
          ),
        ),
        background: imageUrl != null
            ? CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue[700]!, Colors.blue[300]!],
                    ),
                  ),
                  child: const Icon(Icons.landscape,
                      size: 80, color: Colors.white70),
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[700]!, Colors.blue[300]!],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  place.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              if (place.rating != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, size: 18, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        place.rating!.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            place.type.toUpperCase(),
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
              letterSpacing: 1.2,
            ),
          ),
          if (place.description?.short != null) ...[
            const SizedBox(height: 12),
            Text(
              place.description!.short!,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildServices(BuildContext context) {
    final services = place.services!;
    final servicesList = <MapEntry<String, IconData>>[
      if (services.parking) const MapEntry('Parking', Icons.local_parking),
      if (services.toilet) const MapEntry('WC', Icons.wc),
      if (services.restaurantNearby)
        const MapEntry('Restaurant', Icons.restaurant),
      if (services.wheelchairAccess)
        const MapEntry('Wheelchair', Icons.accessible),
      if (services.wifi) const MapEntry('WiFi', Icons.wifi),
      if (services.information) const MapEntry('Info', Icons.info),
      if (services.camping) const MapEntry('Camping', Icons.cabin),
      if (services.shelter) const MapEntry('Shelter', Icons.roofing),
    ];

    if (servicesList.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🛠️ Available Services',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: servicesList.map((service) {
              return Column(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.blue[200],
                    child: Icon(service.value, color: Colors.blue[800]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service.key,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitInfo(BuildContext context) {
    final info = place.visitInfo!;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📅 Visit Information',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          if (info.bestTime != null)
            _buildInfoRow(Icons.calendar_today, 'Best time', info.bestTime!),
          if (info.suggestedDuration != null)
            _buildInfoRow(Icons.schedule, 'Duration', info.suggestedDuration!),
          if (info.crowds != null)
            _buildInfoRow(Icons.people, 'Crowds', info.crowds!),
          _buildInfoRow(
            Icons.attach_money,
            'Entry fee',
            info.entryFee ? 'Yes' : 'Free',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.green[700]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildTabs(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'About'),
              Tab(text: 'History'),
              Tab(text: 'Services'),
            ],
          ),
          SizedBox(
            height: 200,
            child: TabBarView(
              children: [
                // About tab
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    place.description?.short ??
                        place.description?.history ??
                        'No description available.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                // History tab
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (place.description?.history != null) ...[
                        Text(
                          place.description!.history!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (place.wikipediaUrl != null)
                        TextButton.icon(
                          onPressed: () {
                            // Open Wikipedia
                          },
                          icon: const Icon(Icons.open_in_new),
                          label: const Text('Read more on Wikipedia'),
                        ),
                    ],
                  ),
                ),
                // Services tab
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: place.services != null
                      ? _buildServicesDetail()
                      : const Text('No service information available.'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesDetail() {
    final services = place.services!;
    return ListView(
      children: [
        _buildServiceTile(Icons.local_parking, 'Parking', services.parking),
        _buildServiceTile(Icons.wc, 'Toilet', services.toilet),
        _buildServiceTile(
            Icons.restaurant, 'Restaurant nearby', services.restaurantNearby),
        _buildServiceTile(
            Icons.accessible, 'Wheelchair access', services.wheelchairAccess),
        _buildServiceTile(Icons.tour, 'Guided tours', services.guidedTours),
        _buildServiceTile(Icons.cabin, 'Camping', services.camping),
        _buildServiceTile(Icons.wifi, 'WiFi', services.wifi),
        _buildServiceTile(Icons.info, 'Information', services.information),
        _buildServiceTile(Icons.roofing, 'Shelter', services.shelter),
      ],
    );
  }

  Widget _buildServiceTile(IconData icon, String label, bool available) {
    return ListTile(
      leading: Icon(
        icon,
        color: available ? Colors.green : Colors.grey,
      ),
      title: Text(label),
      trailing: Icon(
        available ? Icons.check_circle : Icons.cancel,
        color: available ? Colors.green : Colors.grey,
      ),
    );
  }

  Widget _buildImageGallery(BuildContext context) {
    final images = place.images!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '📸 Gallery',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: images.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(right: 12),
                width: 160,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: images[index],
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.error),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
