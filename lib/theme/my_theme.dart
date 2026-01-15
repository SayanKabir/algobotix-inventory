import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData myTheme() {
  final base = ThemeData.light(useMaterial3: true);

  return base.copyWith(
    scaffoldBackgroundColor: const Color(0xFFF0F4F8),

    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6C63FF),
      surface: const Color(0xFFF0F4F8),
    ),

    textTheme: GoogleFonts.poppinsTextTheme(base.textTheme),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.black87,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: Colors.black87),
    ),
  );
}