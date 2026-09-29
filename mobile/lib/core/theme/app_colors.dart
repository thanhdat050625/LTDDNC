import 'package:flutter/material.dart';

class AppColors {
  // Brand
  static const Color primary = Color(0xFFE50914);
  static const Color secondary = Color(0xFF3A86FF);
  static const Color accent = Color(0xFFE58E26);

  // Dark Mode
  static const Color darkBackground = Color(0xFF0D0D11); // Deeper base for gradients
  static const Color darkSurface = Color(0xFF1E1E28);
  static const Color darkText = Colors.white;
  static const Color darkTextSecondary = Colors.white70;
  static const Color glassmorphismColor = Color(0x1AFFFFFF); // 10% white for glass effect
  static const Color neonGlow = Color(0x80E50914); // 50% opacity red for glow

  static const RadialGradient cinematicGradient = RadialGradient(
    center: Alignment.topLeft,
    radius: 1.5,
    colors: [
      Color(0xFF2A2A35), // Soft grey/white tint glow
      Color(0xFF0D0D11), // Fades to deep black
    ],
    stops: [0.0, 1.0],
  );

  // Light Mode
  static const Color lightBackground = Color(0xFFF9FAFB);
  static const Color lightSurface = Colors.white;
  static const Color lightText = Color(0xFF111827);
  static const Color lightTextSecondary = Color(0xFF4B5563);

  // Seats
  static const Color seatStandard = Color(0xFF718096);
  static const Color seatVIP = Color(0xFFE50914);
  static const Color seatCouple = Color(0xFFD946EF);
  static const Color seatSelected = Color(0xFF22C55E);
  static const Color seatHeld = Color(0xFFF59E0B);
  static const Color seatBooked = Color(0xFF374151);

  // Status
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);
}
