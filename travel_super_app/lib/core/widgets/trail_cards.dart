import 'package:flutter/material.dart';

import '../../data/models/place_model.dart';
import '../../data/models/trail_model.dart';
import '../../features/trail/trail_map_view.dart';

/// Large place card for Today's Picks section - prominent image with gradient overlay
class LargePlaceCard extends StatelessWidget {
  final PlaceModel place;
  final VoidCallback? onTap;

  const LargePlaceCard({
    required this.place,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 320,
        height: 240,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Background image
              Positioned.fill(
                child: Image.asset(
                  place.images.isNotEmpty
                      ? place.images.first
                      : 'assets/images/placeholder.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.image, size: 60),
                  ),
                ),
              ),
              // Gradient overlay
              Positioned.fill(
                child: DecoratedBox(
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
              ),
              // Content
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (place.meta?['region'] != null)
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.white70,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            place.meta!['region'],
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    if (place.rating != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Color(0xFFFFB800),
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            place.rating!.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small place card for horizontal scrolling collections
class SmallPlaceCard extends StatelessWidget {
  final PlaceModel place;
  final VoidCallback? onTap;

  const SmallPlaceCard({
    required this.place,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              SizedBox(
                height: 120,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        place.images.isNotEmpty
                            ? place.images.first
                            : 'assets/images/placeholder.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.image, size: 40),
                        ),
                      ),
                    ),
                    if (place.rating != null)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                color: Color(0xFFFFB800),
                                size: 14,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                place.rating!.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (place.meta?['region'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        place.meta!['region'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Trail list tile with difficulty badge, stats, and mini map preview
class TrailListTile extends StatelessWidget {
  final TrailModel trail;
  final VoidCallback? onTap;

  const TrailListTile({
    required this.trail,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ??
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TrailMapView(trail: trail),
              ),
            );
          },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Trail thumbnail / mini map preview
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 80,
                height: 80,
                color: Colors.grey.shade200,
                child: trail.images.isNotEmpty
                    ? Image.asset(
                        trail.images.first,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildMapPlaceholder(),
                      )
                    : _buildMapPlaceholder(),
              ),
            ),
            const SizedBox(width: 16),
            // Trail info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          trail.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Difficulty badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Color(int.parse(
                                  trail.difficultyColor.substring(1),
                                  radix: 16) +
                              0xFF000000),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          trail.difficulty,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildStatBadge(Icons.straighten, '${trail.lengthKm} km'),
                      const SizedBox(width: 12),
                      _buildStatBadge(Icons.schedule, trail.formattedDuration),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _buildStatBadge(
                          Icons.terrain, '↑${trail.elevationGain}m'),
                      const SizedBox(width: 12),
                      if (trail.region.isNotEmpty)
                        Flexible(
                          child: Text(
                            trail.region,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF00D4AA),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBadge(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey.shade300,
            Colors.grey.shade200,
          ],
        ),
      ),
      child: Icon(
        Icons.map,
        size: 32,
        color: Colors.grey.shade500,
      ),
    );
  }
}
