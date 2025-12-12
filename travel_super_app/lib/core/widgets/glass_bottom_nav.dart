import 'dart:ui';

import 'package:flutter/material.dart';

/// Glass morphism bottom navigation bar with glow effects and smooth transitions.
class GlassBottomNav extends StatelessWidget {
  const GlassBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    _NavItem(icon: Icons.explore, label: 'Home'),
    _NavItem(icon: Icons.map, label: 'Map'),
    _NavItem(icon: Icons.grid_view, label: 'Explore'),
    _NavItem(icon: Icons.person, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D4AA).withOpacity(0.2),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                _items.length,
                (index) => _NavButton(
                  item: _items[index],
                  isSelected: currentIndex == index,
                  onTap: () => onTap(index),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      const Color(0xFF00D4AA).withOpacity(0.15),
                      const Color(0xFF6B5CE7).withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF00D4AA).withOpacity(0.2)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF00D4AA).withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  item.icon,
                  size: 24,
                  color: isSelected
                      ? const Color(0xFF00D4AA)
                      : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? const Color(0xFF00D4AA)
                      : Colors.grey.shade600,
                ),
                child: Text(item.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}
