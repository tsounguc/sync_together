import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF5F5F5),
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black87),
      titleTextStyle: TextStyle(
        color: Colors.black87,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF3F51B5),
      onPrimary: Colors.white,
      surface: Color(0xFFF5F5F5),
      surfaceContainerHighest: Color(0xFFECECEC),
      onSurface: Colors.black87,
      outline: Colors.black45,
    ),
    textTheme: GoogleFonts.interTextTheme().copyWith(
      displayLarge:
          GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.bold),
      titleLarge: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold),
      titleMedium: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
      bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500),
      bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400),
      labelLarge: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
    ),
    cardColor: const Color(0xFFECECEC),
    iconTheme: const IconThemeData(color: Colors.black87),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF3F51B5),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF121212),
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF3F51B5),
      onPrimary: Colors.white,
      surface: Color(0xFF1E1E1E),
      surfaceContainerHighest: Color(0xFF2A2A2A),
      onSurface: Colors.white,
      outline: Colors.grey,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge:
          GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.bold),
      titleLarge: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold),
      titleMedium: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
      bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500),
      bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400),
      labelLarge: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
    ),
    cardColor: const Color(0xFF2A2A2A),
    iconTheme: const IconThemeData(color: Colors.white70),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[900],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF3F51B5),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );
}
