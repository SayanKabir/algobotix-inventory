import 'package:flutter/material.dart';

const myPurpleColor = Color(0xFF6C63FF);
const myWhiteColor = const Color(0xFFF0F4F8);

const backgroundGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFFF0F4F8), // Soft Cloud White
    Color(0xFFE6E6FA), // Very Light Lavender
    Color(0xFFF0F4F8), // Soft Cloud White
  ],
);