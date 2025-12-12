import 'dart:ui';
import 'package:flutter/material.dart';
import '../../data/models/poi_category.dart';

/// 🏷️ Category Chip Widget
class CategoryChip extends StatelessWidget {
  final PoiCategory category;
  final bool isSelected;
  final VoidCallback? onTap;

  const CategoryChip({
    super.key,
    required this.category,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? category.color.withOpacity(0.2)
              : Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? category.color.withOpacity(0.5)
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (category.emoji != null) ...[
              Text(
                category.emoji!,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 6),
            ],
            Icon(
              category.icon,
              size: 18,
              color: isSelected ? category.color : Colors.white70,
            ),
            const SizedBox(width: 6),
            Text(
              category.displayName,
              style: TextStyle(
                color: isSelected ? category.color : Colors.white70,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
