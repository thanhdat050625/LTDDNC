import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  static TextStyle get heading => GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get title => GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get subtitle => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get body => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  static TextStyle get caption => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.normal,
  );

  static TextStyle get button => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
}
