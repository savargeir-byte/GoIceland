import 'package:flutter/material.dart';

/// Centralized palette for the "Fresh Explorer Premium" theme.
class ColorPalette {
  const ColorPalette._();

  // Premium Aurora Palette
  static const Color primary = Color(0xFF00D4AA); // Fresh teal
  static const Color primaryDark = Color(0xFF00A87E);
  static const Color secondary = Color(0xFF6B5CE7); // Aurora purple
  static const Color accent = Color(0xFFFFB74D); // Warm amber
  static const Color accentPink = Color(0xFFFF6B9D); // Aurora pink
  static const Color accentSun = Color(0xFFFFB55E);
  static const Color aurora = Color(0xFF9173F2);

  // Backgrounds
  static const Color background = Color(0xFFF8FAFB);
  static const Color card = Colors.white;
  static const Color surfaceElevated = Color(0xFFFAFBFC);

  // Glass Morphism
  static const Color glassLight = Color(0xCCFFFFFF);
  static const Color glassDark = Color(0x99000000);
  static const Color glowTeal = Color(0x3300D4AA);
  static const Color glowPurple = Color(0x336B5CE7);

  // Text
  static const Color textPrimary = Color(0xFF1A202C);
  static const Color textSecondary = Color(0xFF718096);
  static const Color textTertiary = Color(0xFFA0AEC0);

  // Status
  static const Color success = Color(0xFF3CB371);
  static const Color warning = Color(0xFFFFD166);
  static const Color danger = Color(0xFFE94F37);

  // Gradients
  static const LinearGradient auroraGradient = LinearGradient(
    colors: [Color(0xFF6B5CE7), Color(0xFF00D4AA), Color(0xFFFF6B9D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF4A90E2), Color(0xFF00D4AA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFB)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient glowGradient = LinearGradient(
    colors: [Color(0x4400D4AA), Color(0x446B5CE7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
