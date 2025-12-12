import 'package:flutter/material.dart';

/// Animated category chip with glow effect and smooth transitions.
class AnimatedCategoryChip extends StatefulWidget {
  const AnimatedCategoryChip({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<AnimatedCategoryChip> createState() => _AnimatedCategoryChipState();
}

class _AnimatedCategoryChipState extends State<AnimatedCategoryChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    if (widget.isSelected) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedCategoryChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: widget.onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color:
                    widget.isSelected ? const Color(0xFF00D4AA) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.isSelected
                      ? const Color(0xFF00D4AA)
                      : Colors.grey.shade300,
                  width: 1.5,
                ),
                boxShadow: [
                  if (widget.isSelected)
                    BoxShadow(
                      color: const Color(0xFF00D4AA)
                          .withOpacity(0.4 * _glowAnimation.value),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.icon,
                    size: 18,
                    color:
                        widget.isSelected ? Colors.white : Colors.grey.shade700,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: widget.isSelected
                          ? Colors.white
                          : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Horizontal scrollable list of animated category chips.
class CategoryChipList extends StatefulWidget {
  const CategoryChipList({super.key});

  @override
  State<CategoryChipList> createState() => _CategoryChipListState();
}

class _CategoryChipListState extends State<CategoryChipList> {
  int _selectedIndex = 0;

  static const _categories = [
    _CategoryItem(label: 'All', icon: Icons.explore),
    _CategoryItem(label: 'Food', icon: Icons.restaurant),
    _CategoryItem(label: 'Photo', icon: Icons.camera_alt),
    _CategoryItem(label: 'Nature', icon: Icons.terrain),
    _CategoryItem(label: 'Wellness', icon: Icons.spa),
    _CategoryItem(label: 'Adventure', icon: Icons.hiking),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final category = _categories[index];
          return AnimatedCategoryChip(
            label: category.label,
            icon: category.icon,
            isSelected: _selectedIndex == index,
            onTap: () => setState(() => _selectedIndex = index),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: _categories.length,
      ),
    );
  }
}

class _CategoryItem {
  const _CategoryItem({required this.label, required this.icon});
  final String label;
  final IconData icon;
}
