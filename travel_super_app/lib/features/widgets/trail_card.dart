import 'package:flutter/material.dart';

import '../../data/models/trail_model.dart';

/// 🥾 Trail Card Widget
class TrailCard extends StatelessWidget {
  final TrailModel trail;
  final VoidCallback? onTap;

  const TrailCard({
    super.key,
    required this.trail,
    this.onTap,
  });

  Color get _difficultyColor {
    switch (trail.difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'moderate':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              blurRadius: 8,
              offset: const Offset(0, 4),
              color: Colors.black.withOpacity(0.1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    trail.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _difficultyColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    trail.difficulty.toUpperCase(),
                    style: TextStyle(
                      color: _difficultyColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.straighten, size: 18, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Text(
                  trail.formattedDistance,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 18, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Text(
                  trail.formattedDuration,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                if (trail.elevation != null) ...[
                  const SizedBox(width: 16),
                  Icon(Icons.terrain, size: 18, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Text(
                    '${trail.elevation!.toInt()}m',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
