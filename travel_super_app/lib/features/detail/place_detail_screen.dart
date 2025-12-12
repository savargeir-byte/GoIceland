import 'dart:ui';
import 'package:flutter/material.dart';
import '../../data/models/place.dart';

/// 📄 Place Detail Screen - Full place information
class PlaceDetailScreen extends StatelessWidget {
  final Place place;

  const PlaceDetailScreen({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero Image AppBar
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                place.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 8,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (place.imageUrl != null)
                    Image.network(
                      place.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.place, size: 80),
                      ),
                    )
                  else
                    Container(
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.place, size: 80),
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

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rating & Category
                  Row(
                    children: [
                      if (place.rating != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                place.rating!.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      
                      // Category Chip
                      Chip(
                        label: Text(place.category),
                        backgroundColor: Colors.blue.withOpacity(0.1),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Description
                  const Text(
                    'About',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    place.description.isNotEmpty
                        ? place.description
                        : 'No description available.',
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Location Info
                  const Text(
                    'Location',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.red),
                      const SizedBox(width: 8),
                      Text(
                        '${place.lat.toStringAsFixed(4)}, ${place.lng.toStringAsFixed(4)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),

                  if (place.open != null) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.access_time, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(
                          'Open: ${place.open}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Open in Maps
                          },
                          icon: const Icon(Icons.directions),
                          label: const Text('Directions'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // TODO: Save to favorites
                          },
                          icon: const Icon(Icons.favorite_border),
                          label: const Text('Save'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
