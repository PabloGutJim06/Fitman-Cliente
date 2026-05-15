// lib/theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Colores principales
  static const Color primary = Color(0xFFADFF2F); // Tu famoso verde neón fosforito
  static const Color background = Colors.black; // El fondo oscuro del océano

  // Grises y superficies (Para tarjetas, diálogos, menús)
  static const Color surface = Color(0xFF1E1E1E); // Gris oscuro para tarjetas
  static const Color surfaceLight = Color(0xFF2C2C2C); // Gris para diálogos
  static const Color surfaceDark = Color(0xFF121212); // Gradientes

  // Colores de estado
  static const Color success = Color(0xFF388E3C); // Verde oscuro para botones/iconos de éxito
  static const Color error = Colors.redAccent;

  // Textos
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white54;
  static const Color textMuted = Colors.grey;
}