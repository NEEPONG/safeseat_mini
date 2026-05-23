import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // สีหลักของแอป
  static const Color primaryColor = Color(0xFF2340A7);
  static const Color backgroundColor = Colors.white;
  static const Color inputColor = Color(0xFFF3F4F6);

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      textTheme: GoogleFonts.kanitTextTheme(),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
      ),
      useMaterial3: true,
    );
  }
}
