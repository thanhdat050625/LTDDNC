import 'package:flutter/material.dart';

class CineplexColors extends ThemeExtension<CineplexColors> {
  // Brand
  final Color primary;
  final Color secondary;
  final Color accent;
  
  // Background & Surface
  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;

  // Seats
  final Color seatStandard;
  final Color seatVIP;
  final Color seatCouple;
  final Color seatSelected;
  final Color seatHeld;
  final Color seatBooked;

  // Status
  final Color success;
  final Color error;
  final Color warning;
  final Color info;

  // Design Tokens (Spacing, Radius, Elevation)
  final double spacingSm;
  final double spacingMd;
  final double spacingLg;
  
  final double radiusSm;
  final double radiusMd;
  final double radiusLg;
  
  final double elevationSm;
  final double elevationMd;

  const CineplexColors({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.seatStandard,
    required this.seatVIP,
    required this.seatCouple,
    required this.seatSelected,
    required this.seatHeld,
    required this.seatBooked,
    required this.success,
    required this.error,
    required this.warning,
    required this.info,
    required this.spacingSm,
    required this.spacingMd,
    required this.spacingLg,
    required this.radiusSm,
    required this.radiusMd,
    required this.radiusLg,
    required this.elevationSm,
    required this.elevationMd,
  });

  @override
  ThemeExtension<CineplexColors> copyWith({
    Color? primary,
    Color? secondary,
    Color? accent,
    Color? background,
    Color? surface,
    Color? textPrimary,
    Color? textSecondary,
    Color? seatStandard,
    Color? seatVIP,
    Color? seatCouple,
    Color? seatSelected,
    Color? seatHeld,
    Color? seatBooked,
    Color? success,
    Color? error,
    Color? warning,
    Color? info,
    double? spacingSm,
    double? spacingMd,
    double? spacingLg,
    double? radiusSm,
    double? radiusMd,
    double? radiusLg,
    double? elevationSm,
    double? elevationMd,
  }) {
    return CineplexColors(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      accent: accent ?? this.accent,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      seatStandard: seatStandard ?? this.seatStandard,
      seatVIP: seatVIP ?? this.seatVIP,
      seatCouple: seatCouple ?? this.seatCouple,
      seatSelected: seatSelected ?? this.seatSelected,
      seatHeld: seatHeld ?? this.seatHeld,
      seatBooked: seatBooked ?? this.seatBooked,
      success: success ?? this.success,
      error: error ?? this.error,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      spacingSm: spacingSm ?? this.spacingSm,
      spacingMd: spacingMd ?? this.spacingMd,
      spacingLg: spacingLg ?? this.spacingLg,
      radiusSm: radiusSm ?? this.radiusSm,
      radiusMd: radiusMd ?? this.radiusMd,
      radiusLg: radiusLg ?? this.radiusLg,
      elevationSm: elevationSm ?? this.elevationSm,
      elevationMd: elevationMd ?? this.elevationMd,
    );
  }

  @override
  ThemeExtension<CineplexColors> lerp(ThemeExtension<CineplexColors>? other, double t) {
    if (other is! CineplexColors) {
      return this;
    }
    return CineplexColors(
      primary: Color.lerp(primary, other.primary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      seatStandard: Color.lerp(seatStandard, other.seatStandard, t)!,
      seatVIP: Color.lerp(seatVIP, other.seatVIP, t)!,
      seatCouple: Color.lerp(seatCouple, other.seatCouple, t)!,
      seatSelected: Color.lerp(seatSelected, other.seatSelected, t)!,
      seatHeld: Color.lerp(seatHeld, other.seatHeld, t)!,
      seatBooked: Color.lerp(seatBooked, other.seatBooked, t)!,
      success: Color.lerp(success, other.success, t)!,
      error: Color.lerp(error, other.error, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      spacingSm: (spacingSm + (other.spacingSm - spacingSm) * t),
      spacingMd: (spacingMd + (other.spacingMd - spacingMd) * t),
      spacingLg: (spacingLg + (other.spacingLg - spacingLg) * t),
      radiusSm: (radiusSm + (other.radiusSm - radiusSm) * t),
      radiusMd: (radiusMd + (other.radiusMd - radiusMd) * t),
      radiusLg: (radiusLg + (other.radiusLg - radiusLg) * t),
      elevationSm: (elevationSm + (other.elevationSm - elevationSm) * t),
      elevationMd: (elevationMd + (other.elevationMd - elevationMd) * t),
    );
  }

  // Dark Theme Tokens (theo design.md)
  static const CineplexColors dark = CineplexColors(
    primary: Color(0xFFE50914), 
    secondary: Color(0xFF3A86FF), 
    accent: Color(0xFFE58E26), 
    background: Color(0xFF121212),
    surface: Color(0xFF1E1E24),
    textPrimary: Colors.white,
    textSecondary: Colors.white70,
    seatStandard: Color(0xFF718096),
    seatVIP: Color(0xFFE50914),
    seatCouple: Color(0xFFD946EF),
    seatSelected: Color(0xFF22C55E),
    seatHeld: Color(0xFFF59E0B),
    seatBooked: Color(0xFF374151),
    success: Color(0xFF22C55E),
    error: Color(0xFFEF4444),
    warning: Color(0xFFF59E0B),
    info: Color(0xFF3B82F6),
    spacingSm: 8.0,
    spacingMd: 16.0,
    spacingLg: 24.0,
    radiusSm: 8.0,
    radiusMd: 12.0,
    radiusLg: 16.0,
    elevationSm: 2.0,
    elevationMd: 8.0,
  );

  // Light Theme Tokens
  static const CineplexColors light = CineplexColors(
    primary: Color(0xFFE50914),
    secondary: Color(0xFF3A86FF),
    accent: Color(0xFFE58E26),
    background: Color(0xFFF9FAFB),
    surface: Colors.white,
    textPrimary: Color(0xFF111827),
    textSecondary: Color(0xFF4B5563),
    seatStandard: Color(0xFF718096),
    seatVIP: Color(0xFFE50914),
    seatCouple: Color(0xFFD946EF),
    seatSelected: Color(0xFF22C55E),
    seatHeld: Color(0xFFF59E0B),
    seatBooked: Color(0xFFD1D5DB),
    success: Color(0xFF22C55E),
    error: Color(0xFFEF4444),
    warning: Color(0xFFF59E0B),
    info: Color(0xFF3B82F6),
    spacingSm: 8.0,
    spacingMd: 16.0,
    spacingLg: 24.0,
    radiusSm: 8.0,
    radiusMd: 12.0,
    radiusLg: 16.0,
    elevationSm: 2.0,
    elevationMd: 8.0,
  );
}
