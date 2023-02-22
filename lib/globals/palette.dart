import 'package:flutter/material.dart';

class ColorPalette {
  final Color orange = const Color(0xFFF09000);
  final Color black = const Color(0xFF101010);
  final Color white = const Color(0xFFF3F3F3);
  final Color red = const Color(0xFFFF0B0B);
  final Color card = const Color(0xFF1F2B30);
  final Color highlight = const Color(0xFF324046);
  final Color cardColor = const Color(0xFF1F2B30);
  final Color topColor = const Color(0xFF0F2027);
  final Color cardButton = const Color.fromARGB(255, 65, 80, 86);
  final Color grey = const Color.fromARGB(255, 79, 79, 79);

  final LinearGradient gradient = const LinearGradient(
    colors: [
      Color(0xFF0F2027),
      Color(0xFF101010),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  final LinearGradient gradientLive = const LinearGradient(
    colors: [
      Color(0xFF9B0303),
      Color(0xFFFF0B0B),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
