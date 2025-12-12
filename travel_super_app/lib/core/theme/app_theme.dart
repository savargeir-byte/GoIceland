import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'color_palette.dart';

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  scaffoldBackgroundColor: ColorPalette.background,
  colorScheme: ColorScheme.fromSeed(
    seedColor: ColorPalette.primary,
    primary: ColorPalette.primary,
    secondary: ColorPalette.secondary,
    background: ColorPalette.background,
    surface: ColorPalette.card,
    primaryContainer: ColorPalette.glowTeal,
    secondaryContainer: ColorPalette.glowPurple,
  ),
  textTheme: GoogleFonts.interTextTheme(
    const TextTheme(
      displayLarge:
          TextStyle(fontSize: 32, fontWeight: FontWeight.bold, height: 1.2),
      displayMedium:
          TextStyle(fontSize: 28, fontWeight: FontWeight.bold, height: 1.2),
      displaySmall:
          TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.3),
      headlineMedium:
          TextStyle(fontSize: 20, fontWeight: FontWeight.w600, height: 1.3),
      titleLarge:
          TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.4),
      titleMedium:
          TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.4),
      titleSmall:
          TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 1.4),
      bodyLarge:
          TextStyle(fontSize: 16, fontWeight: FontWeight.normal, height: 1.5),
      bodyMedium:
          TextStyle(fontSize: 14, fontWeight: FontWeight.normal, height: 1.5),
      bodySmall:
          TextStyle(fontSize: 12, fontWeight: FontWeight.normal, height: 1.5),
      labelLarge:
          TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 1.2),
      labelMedium:
          TextStyle(fontSize: 12, fontWeight: FontWeight.w500, height: 1.2),
      labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          height: 1.2,
          letterSpacing: 0.5),
    ),
  ).apply(
    bodyColor: ColorPalette.textPrimary,
    displayColor: ColorPalette.textPrimary,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: false,
    titleTextStyle: GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: ColorPalette.textPrimary,
    ),
    iconTheme: const IconThemeData(color: ColorPalette.textPrimary),
  ),
  cardTheme: CardThemeData(
    color: ColorPalette.card,
    elevation: 8,
    shadowColor: Colors.black.withOpacity(0.08),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    margin: const EdgeInsets.all(12),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: ColorPalette.primary,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      elevation: 4,
      shadowColor: ColorPalette.glowTeal,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: ColorPalette.primary,
    elevation: 8,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: ColorPalette.card,
    selectedColor: ColorPalette.primary,
    secondarySelectedColor: ColorPalette.secondary,
    labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  ),
);
