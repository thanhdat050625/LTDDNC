import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'cineplex_colors.dart';

class AppTheme {
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Inter',
    scaffoldBackgroundColor: CineplexColors.dark.background,
    primaryColor: AppColors.primary,
    cardColor: CineplexColors.dark.card,
    canvasColor: CineplexColors.dark.surface,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      surface: Color(0xFF1E1E24),
      onSurface: Colors.white,
      error: AppColors.error,
      onError: Colors.white,
      outline: Color(0xFF2E2E38),
      surfaceContainerHighest: Color(0xFF26262E),
    ),
    extensions: const <ThemeExtension<dynamic>>[
      CineplexColors.dark,
    ],
    appBarTheme: AppBarTheme(
      backgroundColor: CineplexColors.dark.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: const TextStyle(
        fontFamily: 'Inter',
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardThemeData(
      color: CineplexColors.dark.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(CineplexColors.dark.radiusMd),
        side: const BorderSide(color: Color(0xFF2E2E38), width: 1),
      ),
      margin: EdgeInsets.zero,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: CineplexColors.dark.surfaceVariant,
      selectedColor: AppColors.primary,
      disabledColor: const Color(0xFF374151),
      labelStyle: const TextStyle(
        fontFamily: 'Inter',
        color: Colors.white,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      secondaryLabelStyle: const TextStyle(
        fontFamily: 'Inter',
        color: Colors.white,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(CineplexColors.dark.radiusSm),
        side: const BorderSide(color: Color(0xFF2E2E38), width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: CineplexColors.dark.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(CineplexColors.dark.radiusMd),
        borderSide: const BorderSide(color: Color(0xFF2E2E38), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(CineplexColors.dark.radiusMd),
        borderSide: const BorderSide(color: Color(0xFF2E2E38), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(CineplexColors.dark.radiusMd),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(CineplexColors.dark.radiusMd),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(CineplexColors.dark.radiusMd),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      labelStyle: const TextStyle(color: Colors.white70),
      hintStyle: const TextStyle(color: Colors.white38),
      prefixIconColor: Colors.white70,
      suffixIconColor: Colors.white70,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: CineplexColors.dark.surface,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(CineplexColors.dark.radiusLg),
      ),
      titleTextStyle: const TextStyle(
        fontFamily: 'Inter',
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      contentTextStyle: const TextStyle(
        fontFamily: 'Inter',
        color: Colors.white70,
        fontSize: 14,
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Color(0xFF1E1E24),
      elevation: 16,
      modalBackgroundColor: Color(0xFF1E1E24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      dragHandleColor: Colors.white38,
      showDragHandle: true,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1E1E24),
      selectedItemColor: AppColors.primary,
      unselectedItemColor: Colors.white54,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CineplexColors.dark.radiusSm),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CineplexColors.dark.radiusSm),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF2E2E38),
      thickness: 1,
      space: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF26262E),
      contentTextStyle: const TextStyle(fontFamily: 'Inter', color: Colors.white, fontSize: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(CineplexColors.dark.radiusSm),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: AppColors.primary,
      unselectedLabelColor: Colors.white60,
      indicatorColor: AppColors.primary,
      labelStyle: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 14),
      unselectedLabelStyle: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500, fontSize: 14),
    ),
  );

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'Inter',
    scaffoldBackgroundColor: CineplexColors.light.background,
    primaryColor: AppColors.primary,
    cardColor: CineplexColors.light.card,
    canvasColor: CineplexColors.light.surface,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      surface: Colors.white,
      onSurface: Color(0xFF111827),
      error: AppColors.error,
      onError: Colors.white,
      outline: Color(0xFFE5E7EB),
      surfaceContainerHighest: Color(0xFFF3F4F6),
    ),
    extensions: const <ThemeExtension<dynamic>>[
      CineplexColors.light,
    ],
    appBarTheme: AppBarTheme(
      backgroundColor: CineplexColors.light.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: Color(0xFF111827)),
      titleTextStyle: const TextStyle(
        fontFamily: 'Inter',
        color: Color(0xFF111827),
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardThemeData(
      color: CineplexColors.light.card,
      elevation: 1,
      shadowColor: const Color(0x12000000),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(CineplexColors.light.radiusMd),
        side: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
      ),
      margin: EdgeInsets.zero,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: CineplexColors.light.surfaceVariant,
      selectedColor: AppColors.primary,
      disabledColor: const Color(0xFFE5E7EB),
      labelStyle: const TextStyle(
        fontFamily: 'Inter',
        color: Color(0xFF374151),
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      secondaryLabelStyle: const TextStyle(
        fontFamily: 'Inter',
        color: Colors.white,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(CineplexColors.light.radiusSm),
        side: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(CineplexColors.light.radiusMd),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(CineplexColors.light.radiusMd),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(CineplexColors.light.radiusMd),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(CineplexColors.light.radiusMd),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(CineplexColors.light.radiusMd),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      labelStyle: const TextStyle(color: Color(0xFF4B5563)),
      hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
      prefixIconColor: const Color(0xFF6B7280),
      suffixIconColor: const Color(0xFF6B7280),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(CineplexColors.light.radiusLg),
      ),
      titleTextStyle: const TextStyle(
        fontFamily: 'Inter',
        color: Color(0xFF111827),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      contentTextStyle: const TextStyle(
        fontFamily: 'Inter',
        color: Color(0xFF4B5563),
        fontSize: 14,
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
      elevation: 16,
      modalBackgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      dragHandleColor: Color(0xFFD1D5DB),
      showDragHandle: true,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: Color(0xFF9CA3AF),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CineplexColors.light.radiusSm),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CineplexColors.light.radiusSm),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFFE5E7EB),
      thickness: 1,
      space: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF1F2937),
      contentTextStyle: const TextStyle(fontFamily: 'Inter', color: Colors.white, fontSize: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(CineplexColors.light.radiusSm),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: AppColors.primary,
      unselectedLabelColor: Color(0xFF6B7280),
      indicatorColor: AppColors.primary,
      labelStyle: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 14),
      unselectedLabelStyle: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500, fontSize: 14),
    ),
  );
}
