import 'package:flutter/material.dart';

import '../../data/models/poi_model.dart';

/// Premium place card with parallax effect, gradients, and distance/time info.
class PremiumPlaceCard extends StatefulWidget {
  const PremiumPlaceCard({
    super.key,
    required this.poi,
    required this.onTap,
    this.distance,
    this.travelTime,
    this.isSaved = false,
    this.onBookmarkTap,
  });

  final PoiModel poi;
  final VoidCallback onTap;
  final double? distance; // km
  final Duration? travelTime;
  final bool isSaved;
  final VoidCallback? onBookmarkTap;

  @override
  State<PremiumPlaceCard> createState() => _PremiumPlaceCardState();
}

class _PremiumPlaceCardState extends State<PremiumPlaceCard> {
  double _parallaxOffset = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onPanUpdate: (details) {
        setState(() {
          _parallaxOffset = (details.localPosition.dy / 300).clamp(-0.2, 0.2);
        });
      },
      onPanEnd: (_) {
        setState(() => _parallaxOffset = 0);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        width: 240,
        height: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00D4AA).withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Image with parallax
              SizedBox(
                height: 160,
                child: Stack(
                  children: [
                    Transform.translate(
                      offset: Offset(0, _parallaxOffset * 20),
                      child: _PlaceImage(
                        imageUrl: widget.poi.image,
                        category: widget.poi.type,
                      ),
                    ),
                    // Gradient overlay
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.3),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                    // Bookmark button (top-left)
                    if (widget.onBookmarkTap != null)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: widget.onBookmarkTap,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Icon(
                                widget.isSaved
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                                size: 20,
                                color: widget.isSaved
                                    ? const Color(0xFF00D4AA)
                                    : const Color(0xFF1A202C),
                              ),
                            ),
                          ),
                        ),
                      ),
                    // Rating badge
                    if (widget.poi.rating != null)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                size: 14,
                                color: Color(0xFFFFB74D),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.poi.rating!.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A202C),
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
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.poi.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A202C),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.poi.type.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Rating stars
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < (widget.poi.rating ?? 0).round() 
                              ? Icons.star 
                              : Icons.star_border,
                            size: 14,
                            color: const Color(0xFFFFB800),
                          );
                        }),
                        const SizedBox(width: 6),
                        Text(
                          widget.poi.rating?.toStringAsFixed(1) ?? 'N/A',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Distance & Time
                    if (widget.distance != null || widget.travelTime != null)
                      Row(
                        children: [
                          if (widget.distance != null) ...[
                            Icon(
                              Icons.near_me,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.distance!.toStringAsFixed(1)} km',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                          if (widget.distance != null &&
                              widget.travelTime != null)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Container(
                                width: 2,
                                height: 12,
                                color: Colors.grey.shade300,
                              ),
                            ),
                          if (widget.travelTime != null) ...[
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.travelTime!.inMinutes} min',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ],
                      ),
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

class _PlaceImage extends StatelessWidget {
  const _PlaceImage({this.imageUrl, this.category});

  final String? imageUrl;
  final String? category;
  
  List<Color> _getCategoryGradient() {
    switch (category?.toLowerCase()) {
      case 'waterfall':
        return [Colors.blue.shade300, Colors.blue.shade600];
      case 'peak':
      case 'mountain':
        return [Colors.grey.shade400, Colors.grey.shade700];
      case 'restaurant':
      case 'cafe':
        return [Colors.orange.shade300, Colors.orange.shade600];
      case 'hotel':
        return [Colors.purple.shade300, Colors.purple.shade600];
      case 'hot_spring':
        return [Colors.cyan.shade300, Colors.cyan.shade600];
      case 'cave':
        return [Colors.brown.shade300, Colors.brown.shade600];
      case 'volcano':
        return [Colors.red.shade300, Colors.red.shade700];
      case 'beach':
        return [Colors.amber.shade300, Colors.amber.shade600];
      case 'viewpoint':
        return [Colors.green.shade300, Colors.green.shade600];
      case 'museum':
        return [Colors.indigo.shade300, Colors.indigo.shade600];
      default:
        return [Colors.teal.shade300, Colors.teal.shade600];
    }
  }
  
  IconData _getCategoryIcon() {
    switch (category?.toLowerCase()) {
      case 'waterfall':
        return Icons.water;
      case 'peak':
      case 'mountain':
        return Icons.terrain;
      case 'restaurant':
        return Icons.restaurant;
      case 'cafe':
        return Icons.local_cafe;
      case 'hotel':
        return Icons.hotel;
      case 'hot_spring':
        return Icons.hot_tub;
      case 'cave':
        return Icons.landscape;
      case 'volcano':
        return Icons.whatshot;
      case 'beach':
        return Icons.beach_access;
      case 'viewpoint':
        return Icons.camera_alt;
      case 'museum':
        return Icons.museum;
      default:
        return Icons.place;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use imageUrl if available, otherwise use placeholder
    final effectiveUrl = imageUrl != null && imageUrl!.isNotEmpty 
        ? imageUrl!
        : null;
    
    if (effectiveUrl == null) {
      // Category-specific gradient with icon
      final colors = _getCategoryGradient();
      return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Icon(
          _getCategoryIcon(),
          size: 64,
          color: Colors.white.withOpacity(0.8),
        ),
      );
    }
    
    return Image.network(
      effectiveUrl,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        final colors = _getCategoryGradient();
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Icon(
            _getCategoryIcon(),
            size: 64,
            color: Colors.white.withOpacity(0.8),
          ),
        );
      },
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
