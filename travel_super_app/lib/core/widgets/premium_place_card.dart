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
                      child: _PlaceImage(imageUrl: widget.poi.image),
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
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      const Spacer(),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaceImage extends StatelessWidget {
  const _PlaceImage({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Image.asset(
        'assets/images/placeholder.jpg',
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      );
    }
    return Image.network(
      imageUrl!,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Image.asset(
        'assets/images/placeholder.jpg',
        fit: BoxFit.cover,
      ),
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
