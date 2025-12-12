import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/crystal_theme.dart';

/// Crystal glassmorphism search bar with mic and filter
class CrystalSearchBar extends StatelessWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;
  final VoidCallback? onMicTap;
  final TextEditingController? controller;
  
  const CrystalSearchBar({
    super.key,
    this.hintText = 'Search places, restaurants, trails...',
    this.onChanged,
    this.onFilterTap,
    this.onMicTap,
    this.controller,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(CrystalTheme.radiusLarge),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: CrystalTheme.blurHeavy,
            sigmaY: CrystalTheme.blurHeavy,
          ),
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(CrystalTheme.radiusLarge),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search,
                  color: CrystalTheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1A202C),
                    ),
                    decoration: InputDecoration(
                      hintText: hintText,
                      hintStyle: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 15,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
                if (onMicTap != null) ...[
                  const SizedBox(width: 8),
                  _CrystalIconButton(
                    icon: Icons.mic_outlined,
                    onTap: onMicTap!,
                  ),
                ],
                if (onFilterTap != null) ...[
                  const SizedBox(width: 8),
                  _CrystalIconButton(
                    icon: Icons.tune,
                    onTap: onFilterTap!,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CrystalIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  
  const _CrystalIconButton({
    required this.icon,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          color: CrystalTheme.primary,
          size: 20,
        ),
      ),
    );
  }
}
