import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // static const primaryColor = Color.fromARGB(255, 247, 115, 8);
  static const primaryColor = Color.fromARGB(255, 241, 110, 54);
  static const secondaryColor = Color(0xFF374151);
  static const whiteColor = Color(0xFFFFFFFF);
}

final ThemeData appTheme = ThemeData(
  textTheme: TextTheme(
    headlineSmall: GoogleFonts.nunito(
      fontSize: 24,
      fontWeight: FontWeight.bold,
    ),
    titleLarge: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.bold),
    bodyLarge: GoogleFonts.notoSans(fontSize: 16),
    bodyMedium: GoogleFonts.notoSans(fontSize: 14),
    bodySmall: GoogleFonts.notoSans(fontSize: 12),
    labelLarge: GoogleFonts.notoSans(fontSize: 14, fontWeight: FontWeight.w600),
    labelMedium: GoogleFonts.notoSans(fontSize: 12),
    labelSmall: GoogleFonts.notoSans(fontSize: 10),
  ),
  primaryColor: AppColors.primaryColor,
  scaffoldBackgroundColor: AppColors.whiteColor,
);
