// lib/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        surface: AppColors.surface,
      ),

      // -- TIPOGRAFÍAS UNIFICADAS --
      textTheme: const TextTheme(
        // Títulos grandes
        displayLarge: TextStyle(fontFamily: 'sans-serif', fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 24),
        // Textos normales
        bodyLarge: TextStyle(fontFamily: 'sans-serif', color: AppColors.textPrimary, fontSize: 16),
        // Textos secundarios
        bodyMedium: TextStyle(fontFamily: 'sans-serif', color: AppColors.textSecondary, fontSize: 14),
      ),

      // -- ESTILOS DE COMPONENTES GLOBALES --
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.primary),
        titleTextStyle: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
      ),

      // BottomNavigationBar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
      ),
    );
  }
  // Fondo transparente, borde verde neón, texto verde
  static ButtonStyle get primaryButtonStyle => OutlinedButton.styleFrom(
    foregroundColor: AppColors.primary,
    side: const BorderSide(color: AppColors.primary, width: 1.5),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    padding: const EdgeInsets.symmetric(vertical: 16),
    textStyle: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
      letterSpacing: 0.5,
    ),
  );
}