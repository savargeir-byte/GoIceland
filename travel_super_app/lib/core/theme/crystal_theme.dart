import 'dart:ui';

import 'package:flutter/material.dart';

/// Crystal/Glassmorphism theme colors and styles
class CrystalTheme {
  // Primary colors with neon accents
  static const primary = Color(0xFF00D4AA); // Teal
  static const primaryLight = Color(0xFF4DFFCD); // Mint
  static const secondary = Color(0xFF667EEA); // Soft purple
  static const accent = Color(0xFFFF6B9D); // Pink accent
  
  // Glass backgrounds
  static const glassWhite = Color(0x33FFFFFF); // 20% white
  static const glassDark = Color(0x1A000000); // 10% black
  static const glassStrong = Color(0x4DFFFFFF); // 30% white
  
  // Gradients
  static const crystalGradient = LinearGradient(
    colors: [Color(0xFF00D4AA), Color(0xFF4DFFCD)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const softGradient = LinearGradient(
    colors: [Color(0xFFF8FAFB), Color(0xFFFFFFFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // Shadows
  static List<BoxShadow> get crystalShadow => [
    BoxShadow(
      color: primary.withOpacity(0.15),
      blurRadius: 30,
      offset: const Offset(0, 8),
    ),
    const BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 20,
      offset: Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> get glowShadow => [
    BoxShadow(
      color: primary.withOpacity(0.4),
      blurRadius: 20,
      spreadRadius: 2,
    ),
  ];
  
  // Border radius
  static const radiusLarge = 28.0;
  static const radiusMedium = 20.0;
  static const radiusSmall = 16.0;
  
  // Blur amounts
  static const blurLight = 12.0;
  static const blurMedium = 18.0;
  static const blurHeavy = 25.0;
}

/// Glass/Crystal container widget
class CrystalContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double borderRadius;
  final double blur;
  final Color? color;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;
  final Border? border;
  
  const CrystalContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = CrystalTheme.radiusMedium,
    this.blur = CrystalTheme.blurMedium,
    this.color,
    this.boxShadow,
    this.gradient,
    this.border,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: boxShadow ?? CrystalTheme.crystalShadow,
        border: border,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: color ?? CrystalTheme.glassWhite,
              gradient: gradient,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Floating crystal button
class CrystalButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double borderRadius;
  final EdgeInsets padding;
  final bool isSelected;
  
  const CrystalButton({
    super.key,
    required this.child,
    required this.onTap,
    this.borderRadius = CrystalTheme.radiusSmall,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    this.isSelected = false,
  });
  
  @override
  State<CrystalButton> createState() => _CrystalButtonState();
}

class _CrystalButtonState extends State<CrystalButton> {
  bool _isPressed = false;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: CrystalContainer(
          padding: widget.padding,
          borderRadius: widget.borderRadius,
          blur: CrystalTheme.blurLight,
          color: widget.isSelected 
              ? CrystalTheme.primary.withOpacity(0.3)
              : CrystalTheme.glassWhite,
          boxShadow: widget.isSelected 
              ? CrystalTheme.glowShadow 
              : CrystalTheme.crystalShadow,
          child: widget.child,
        ),
      ),
    );
  }
}
