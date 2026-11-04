import 'package:flutter/material.dart';

// One shared palette for markers, routes, legends and galleries (up to 30 days).
const tripDayColors = <Color>[
  Color(0xFF2196F3),
  Color(0xFFE53935),
  Color(0xFF43A047),
  Color(0xFFFB8C00),
  Color(0xFF8E24AA),
  Color(0xFF00897B),
  Color(0xFFD81B60),
  Color(0xFF3949AB),
  Color(0xFF827717),
  Color(0xFF6D4C41),
  Color(0xFF00ACC1),
  Color(0xFFC0CA33),
  Color(0xFF5E35B1),
  Color(0xFFF4511E),
  Color(0xFF546E7A),
  Color(0xFFAD1457),
  Color(0xFF1565C0),
  Color(0xFF558B2F),
  Color(0xFFFFB300),
  Color(0xFFAB47BC),
  Color(0xFF00695C),
  Color(0xFFEF6C80),
  Color(0xFF7986CB),
  Color(0xFF9E9D24),
  Color(0xFFA1887F),
  Color(0xFF00838F),
  Color(0xFF7CB342),
  Color(0xFF4527A0),
  Color(0xFFBF360C),
  Color(0xFF263238),
];

Color tripDayColor(int index) => tripDayColors[index % tripDayColors.length];
