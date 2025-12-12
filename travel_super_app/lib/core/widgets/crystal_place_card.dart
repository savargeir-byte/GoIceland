import 'package:flutter/material.dart';
import '../../core/theme/crystal_theme.dart';
import '../../data/models/poi_model.dart';

/// Crystal glassmorphism place card
class CrystalPlaceCard extends StatefulWidget {
  final PoiModel poi;
  final VoidCallback onTap;
  final double? width;
  final double? height;
  
  const CrystalPlaceCard({
    super.key,
    required this.poi,
    required this.onTap,
    this.width = 280,
    this.height = 320,
  });
  
  @override
  State<CrystalPlaceCard> createState() => _CrystalPlaceCardState();
}

class _CrystalPlaceCardState extends State<CrystalPlaceCard> {
  bool _isHovered = false;
  
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovered ? 1.03 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            width: widget.width,
            height: widget.height,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(CrystalTheme.radiusLarge),
              boxShadow: CrystalTheme.crystalShadow,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(CrystalTheme.radiusLarge),
              child: Stack(
                children: [
                  // Background image
                  Positioned.fill(
                    child: _buildImage(),
                  ),
                  // Gradient overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // Glass info panel at bottom
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: CrystalContainer(
                      borderRadius: CrystalTheme.radiusLarge,
                      blur: CrystalTheme.blurLight,
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Title
                          Text(
                            widget.poi.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black38,
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          // Category & Rating
                          Row(
                            children: [
                              // Category chip
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  gradient: CrystalTheme.crystalGradient,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: CrystalTheme.glowShadow,
                                ),
                                child: Text(
                                  widget.poi.type.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Rating
                              if (widget.poi.rating != null) ...[
                                const Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Color(0xFFFFB800),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.poi.rating!.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Heart icon (top right)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: CrystalContainer(
                      padding: const EdgeInsets.all(8),
                      borderRadius: 12,
                      blur: CrystalTheme.blurLight,
                      child: const Icon(
                        Icons.favorite_border,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildImage() {
    final colors = _getCategoryGradient(widget.poi.type);
    
    if (widget.poi.image == null || widget.poi.image!.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Icon(
            _getCategoryIcon(widget.poi.type),
            size: 80,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
      );
    }
    
    return Image.network(
      widget.poi.image!,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Icon(
            _getCategoryIcon(widget.poi.type),
            size: 80,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
      ),
    );
  }
  
  List<Color> _getCategoryGradient(String category) {
    switch (category.toLowerCase()) {
      case 'waterfall':
        return [Colors.blue.shade400, Colors.blue.shade700];
      case 'peak':
      case 'mountain':
        return [Colors.grey.shade500, Colors.grey.shade800];
      case 'restaurant':
      case 'cafe':
        return [Colors.orange.shade400, Colors.orange.shade700];
      case 'hotel':
        return [Colors.purple.shade400, Colors.purple.shade700];
      case 'hot_spring':
        return [Colors.cyan.shade400, Colors.cyan.shade700];
      case 'cave':
        return [Colors.brown.shade400, Colors.brown.shade700];
      case 'volcano':
        return [Colors.red.shade400, Colors.red.shade800];
      case 'beach':
        return [Colors.amber.shade400, Colors.amber.shade700];
      case 'viewpoint':
        return [Colors.green.shade400, Colors.green.shade700];
      case 'museum':
        return [Colors.indigo.shade400, Colors.indigo.shade700];
      default:
        return [Colors.teal.shade400, Colors.teal.shade700];
    }
  }
  
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
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
}
