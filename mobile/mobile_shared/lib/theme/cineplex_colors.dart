import 'package:flutter/material.dart';

class CineplexColors extends ThemeExtension<CineplexColors> {
  // Brand
  final Color primary;
  final Color secondary;
  final Color accent;

  // Background & Surface
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color card;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;

  // Borders & Dividers
  final Color border;
  final Color borderSubtle;
  final Color divider;
  final Color cardBorder;

  // Icons
  final Color iconPrimary;
  final Color iconSecondary;
  final Color iconMuted;

  // Glass & Overlay
  final Color glassSurface;
  final Color glassBorder;
  final Color shadowColor;
  final Color buttonGlow;

  // Seats
  final Color seatStandard;
  final Color seatVIP;
  final Color seatCouple;
  final Color seatSelected;
  final Color seatHeld;
  final Color seatBooked;
  final Color seatText;
  final Color seatBookedText;

  // Status
  final Color success;
  final Color error;
  final Color warning;
  final Color info;

  // Gradients
  final Gradient cinematicGradient;

  // Design Tokens (Spacing, Radius, Elevation)
  final double spacingSm;
  final double spacingMd;
  final double spacingLg;

  final double radiusSm;
  final double radiusMd;
  final double radiusLg;

  final double elevationSm;
  final double elevationMd;

  // Theme Mode flag
  final bool isDark;

  const CineplexColors({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.card,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.border,
    required this.borderSubtle,
    required this.divider,
    required this.cardBorder,
    required this.iconPrimary,
    required this.iconSecondary,
    required this.iconMuted,
    required this.glassSurface,
    required this.glassBorder,
    required this.shadowColor,
    required this.buttonGlow,
    required this.seatStandard,
    required this.seatVIP,
    required this.seatCouple,
    required this.seatSelected,
    required this.seatHeld,
    required this.seatBooked,
    required this.seatText,
    required this.seatBookedText,
    required this.success,
    required this.error,
    required this.warning,
    required this.info,
    required this.cinematicGradient,
    required this.spacingSm,
    required this.spacingMd,
    required this.spacingLg,
    required this.radiusSm,
    required this.radiusMd,
    required this.radiusLg,
    required this.elevationSm,
    required this.elevationMd,
    required this.isDark,
  });

  @override
  ThemeExtension<CineplexColors> copyWith({
    Color? primary,
    Color? secondary,
    Color? accent,
    Color? background,
    Color? surface,
    Color? surfaceVariant,
    Color? card,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? border,
    Color? borderSubtle,
    Color? divider,
    Color? cardBorder,
    Color? iconPrimary,
    Color? iconSecondary,
    Color? iconMuted,
    Color? glassSurface,
    Color? glassBorder,
    Color? shadowColor,
    Color? buttonGlow,
    Color? seatStandard,
    Color? seatVIP,
    Color? seatCouple,
    Color? seatSelected,
    Color? seatHeld,
    Color? seatBooked,
    Color? seatText,
    Color? seatBookedText,
    Color? success,
    Color? error,
    Color? warning,
    Color? info,
    Gradient? cinematicGradient,
    double? spacingSm,
    double? spacingMd,
    double? spacingLg,
    double? radiusSm,
    double? radiusMd,
    double? radiusLg,
    double? elevationSm,
    double? elevationMd,
    bool? isDark,
  }) {
    return CineplexColors(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      accent: accent ?? this.accent,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      card: card ?? this.card,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      border: border ?? this.border,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      divider: divider ?? this.divider,
      cardBorder: cardBorder ?? this.cardBorder,
      iconPrimary: iconPrimary ?? this.iconPrimary,
      iconSecondary: iconSecondary ?? this.iconSecondary,
      iconMuted: iconMuted ?? this.iconMuted,
      glassSurface: glassSurface ?? this.glassSurface,
      glassBorder: glassBorder ?? this.glassBorder,
      shadowColor: shadowColor ?? this.shadowColor,
      buttonGlow: buttonGlow ?? this.buttonGlow,
      seatStandard: seatStandard ?? this.seatStandard,
      seatVIP: seatVIP ?? this.seatVIP,
      seatCouple: seatCouple ?? this.seatCouple,
      seatSelected: seatSelected ?? this.seatSelected,
      seatHeld: seatHeld ?? this.seatHeld,
      seatBooked: seatBooked ?? this.seatBooked,
      seatText: seatText ?? this.seatText,
      seatBookedText: seatBookedText ?? this.seatBookedText,
      success: success ?? this.success,
      error: error ?? this.error,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      cinematicGradient: cinematicGradient ?? this.cinematicGradient,
      spacingSm: spacingSm ?? this.spacingSm,
      spacingMd: spacingMd ?? this.spacingMd,
      spacingLg: spacingLg ?? this.spacingLg,
      radiusSm: radiusSm ?? this.radiusSm,
      radiusMd: radiusMd ?? this.radiusMd,
      radiusLg: radiusLg ?? this.radiusLg,
      elevationSm: elevationSm ?? this.elevationSm,
      elevationMd: elevationMd ?? this.elevationMd,
      isDark: isDark ?? this.isDark,
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
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      card: Color.lerp(card, other.card, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      iconPrimary: Color.lerp(iconPrimary, other.iconPrimary, t)!,
      iconSecondary: Color.lerp(iconSecondary, other.iconSecondary, t)!,
      iconMuted: Color.lerp(iconMuted, other.iconMuted, t)!,
      glassSurface: Color.lerp(glassSurface, other.glassSurface, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t)!,
      buttonGlow: Color.lerp(buttonGlow, other.buttonGlow, t)!,
      seatStandard: Color.lerp(seatStandard, other.seatStandard, t)!,
      seatVIP: Color.lerp(seatVIP, other.seatVIP, t)!,
      seatCouple: Color.lerp(seatCouple, other.seatCouple, t)!,
      seatSelected: Color.lerp(seatSelected, other.seatSelected, t)!,
      seatHeld: Color.lerp(seatHeld, other.seatHeld, t)!,
      seatBooked: Color.lerp(seatBooked, other.seatBooked, t)!,
      seatText: Color.lerp(seatText, other.seatText, t)!,
      seatBookedText: Color.lerp(seatBookedText, other.seatBookedText, t)!,
      success: Color.lerp(success, other.success, t)!,
      error: Color.lerp(error, other.error, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      cinematicGradient: Gradient.lerp(cinematicGradient, other.cinematicGradient, t)!,
      spacingSm: (spacingSm + (other.spacingSm - spacingSm) * t),
      spacingMd: (spacingMd + (other.spacingMd - spacingMd) * t),
      spacingLg: (spacingLg + (other.spacingLg - spacingLg) * t),
      radiusSm: (radiusSm + (other.radiusSm - radiusSm) * t),
      radiusMd: (radiusMd + (other.radiusMd - radiusMd) * t),
      radiusLg: (radiusLg + (other.radiusLg - radiusLg) * t),
      elevationSm: (elevationSm + (other.elevationSm - elevationSm) * t),
      elevationMd: (elevationMd + (other.elevationMd - elevationMd) * t),
      isDark: t < 0.5 ? isDark : other.isDark,
    );
  }

  // Dark Theme Tokens (Deep Cinema Dark per design.md)
  static const CineplexColors dark = CineplexColors(
    primary: Color(0xFFE50914),
    secondary: Color(0xFF3A86FF),
    accent: Color(0xFFE58E26),
    background: Color(0xFF121212),
    surface: Color(0xFF1E1E24),
    surfaceVariant: Color(0xFF26262E),
    card: Color(0xFF1E1E24),
    textPrimary: Colors.white,
    textSecondary: Colors.white70,
    textMuted: Color(0xFF9CA3AF),
    border: Color(0xFF2E2E38),
    borderSubtle: Color(0xFF24242C),
    divider: Color(0xFF2E2E38),
    cardBorder: Color(0xFF2E2E38),
    iconPrimary: Colors.white,
    iconSecondary: Colors.white70,
    iconMuted: Color(0xFF6B7280),
    glassSurface: Color(0x1AFFFFFF),
    glassBorder: Color(0x26FFFFFF),
    shadowColor: Color(0x80000000),
    buttonGlow: Color(0x80E50914),
    seatStandard: Color(0xFF718096),
    seatVIP: Color(0xFFE50914),
    seatCouple: Color(0xFFD946EF),
    seatSelected: Color(0xFF22C55E),
    seatHeld: Color(0xFFF59E0B),
    seatBooked: Color(0xFF374151),
    seatText: Colors.white,
    seatBookedText: Colors.white38,
    success: Color(0xFF22C55E),
    error: Color(0xFFEF4444),
    warning: Color(0xFFF59E0B),
    info: Color(0xFF3B82F6),
    cinematicGradient: RadialGradient(
      center: Alignment.topLeft,
      radius: 1.5,
      colors: [Color(0xFF2A2A35), Color(0xFF121212)],
      stops: [0.0, 1.0],
    ),
    spacingSm: 8.0,
    spacingMd: 16.0,
    spacingLg: 24.0,
    radiusSm: 8.0,
    radiusMd: 12.0,
    radiusLg: 16.0,
    elevationSm: 2.0,
    elevationMd: 8.0,
    isDark: true,
  );

  // Light Theme Tokens (Modern High-Contrast Clean Light)
  static const CineplexColors light = CineplexColors(
    primary: Color(0xFFE50914),
    secondary: Color(0xFF3A86FF),
    accent: Color(0xFFE58E26),
    background: Color(0xFFF9FAFB),
    surface: Colors.white,
    surfaceVariant: Color(0xFFF3F4F6),
    card: Colors.white,
    textPrimary: Color(0xFF111827),
    textSecondary: Color(0xFF4B5563),
    textMuted: Color(0xFF6B7280),
    border: Color(0xFFE5E7EB),
    borderSubtle: Color(0xFFF3F4F6),
    divider: Color(0xFFE5E7EB),
    cardBorder: Color(0xFFE5E7EB),
    iconPrimary: Color(0xFF111827),
    iconSecondary: Color(0xFF4B5563),
    iconMuted: Color(0xFF9CA3AF),
    glassSurface: Color(0xD9FFFFFF),
    glassBorder: Color(0x1A000000),
    shadowColor: Color(0x12000000),
    buttonGlow: Color(0x33E50914),
    seatStandard: Color(0xFF718096),
    seatVIP: Color(0xFFE50914),
    seatCouple: Color(0xFFD946EF),
    seatSelected: Color(0xFF22C55E),
    seatHeld: Color(0xFFF59E0B),
    seatBooked: Color(0xFF9CA3AF),
    seatText: Colors.white,
    seatBookedText: Color(0xFF111827),
    success: Color(0xFF16A34A),
    error: Color(0xFFDC2626),
    warning: Color(0xFFD97706),
    info: Color(0xFF2563EB),
    cinematicGradient: RadialGradient(
      center: Alignment.topLeft,
      radius: 1.5,
      colors: [Color(0xFFFFFFFF), Color(0xFFEDF0F5)],
      stops: [0.0, 1.0],
    ),
    spacingSm: 8.0,
    spacingMd: 16.0,
    spacingLg: 24.0,
    radiusSm: 8.0,
    radiusMd: 12.0,
    radiusLg: 16.0,
    elevationSm: 2.0,
    elevationMd: 8.0,
    isDark: false,
  );

  static CineplexColors of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<CineplexColors>() ??
        (theme.brightness == Brightness.light
            ? CineplexColors.light
            : CineplexColors.dark);
  }
}

extension CineplexColorsX on BuildContext {
  CineplexColors get colors => CineplexColors.of(this);
}
