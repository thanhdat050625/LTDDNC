import 'package:flutter/material.dart';

class AppColors {
  // Brand
  static const Color primary = Color(0xFFE50914);
  static const Color secondary = Color(0xFF3A86FF);
  static const Color accent = Color(0xFFE58E26);

  // Dark Mode Base (Cinema Dark)
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E24);
  static const Color darkSurfaceVariant = Color(0xFF26262E);
  static const Color darkText = Colors.white;
  static const Color darkTextSecondary = Colors.white70;
  static const Color darkTextMuted = Color(0xFF9CA3AF);
  static const Color darkBorder = Color(0xFF2E2E38);
  static const Color darkDivider = Color(0xFF2E2E38);
  static const Color glassmorphismColor = Color(0x1AFFFFFF); // Backward compatibility
  static const Color darkGlassSurface = Color(0x1AFFFFFF);
  static const Color darkGlassBorder = Color(0x26FFFFFF);
  static const Color neonGlow = Color(0x80E50914); // Backward compatibility
  static const Color darkNeonGlow = neonGlow;

  // Dark Gradients
  static const RadialGradient darkCinematicGradient = RadialGradient(
    center: Alignment.topLeft,
    radius: 1.5,
    colors: [
      Color(0xFF2A2A35),
      Color(0xFF121212),
    ],
    stops: [0.0, 1.0],
  );
  static const RadialGradient cinematicGradient = darkCinematicGradient; // Backward compatibility

  // Light Mode Base (Modern Clean Light)
  static const Color lightBackground = Color(0xFFF9FAFB);
  static const Color lightSurface = Colors.white;
  static const Color lightSurfaceVariant = Color(0xFFF3F4F6);
  static const Color lightText = Color(0xFF111827);
  static const Color lightTextSecondary = Color(0xFF4B5563);
  static const Color lightTextMuted = Color(0xFF6B7280);
  static const Color lightBorder = Color(0xFFE5E7EB);
  static const Color lightDivider = Color(0xFFE5E7EB);
  static const Color lightGlassSurface = Color(0xD9FFFFFF);
  static const Color lightGlassBorder = Color(0x1A000000);
  static const Color lightNeonGlow = Color(0x33E50914);

  // Light Gradients
  static const RadialGradient lightCinematicGradient = RadialGradient(
    center: Alignment.topLeft,
    radius: 1.5,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFEDF0F5),
    ],
    stops: [0.0, 1.0],
  );

  // Brand Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE50914), Color(0xFFFF334B)],
  );

  // Dynamic Theme Helpers
  static RadialGradient getCinematicGradient(bool isDark) =>
      isDark ? darkCinematicGradient : lightCinematicGradient;

  static RadialGradient cinematicGradientOf(BuildContext context) =>
      getCinematicGradient(Theme.of(context).brightness == Brightness.dark);

  static Color getGlassmorphism(bool isDark) =>
      isDark ? darkGlassSurface : lightGlassSurface;

  static Color getNeonGlow(bool isDark) =>
      isDark ? darkNeonGlow : lightNeonGlow;

  // Seats (Per design.md)
  static const Color seatStandard = Color(0xFF718096);
  static const Color seatVIP = Color(0xFFE50914);
  static const Color seatCouple = Color(0xFFD946EF);
  static const Color seatSelected = Color(0xFF22C55E);
  static const Color seatHeld = Color(0xFFF59E0B);
  static const Color seatBooked = Color(0xFF374151); // Dark mode default
  static const Color seatBookedLight = Color(0xFF9CA3AF); // Light mode high-contrast

  // Status
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);
}
