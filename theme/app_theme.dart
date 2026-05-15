// lib/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  // ¡Hissatsu! El tema oscuro definitivo de FitMan
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        surface: AppColors.surface,
        // Si necesitas definir el color del contenedor de errores, etc.
      ),

      // -- TIPOGRAFÍAS UNIFICADAS --
      textTheme: const TextTheme(
        // Títulos grandes (ej. "Mi perfil")
        displayLarge: TextStyle(fontFamily: 'sans-serif', fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 24),
        // Textos normales
        bodyLarge: TextStyle(fontFamily: 'sans-serif', color: AppColors.textPrimary, fontSize: 16),
        // Textos secundarios (ej. subtítulos o etiquetas pequeñas)
        bodyMedium: TextStyle(fontFamily: 'sans-serif', color: AppColors.textSecondary, fontSize: 14),
      ),

      // -- ESTILOS DE COMPONENTES GLOBALES --
      // ¡Así no tienes que repetir el código del AppBar en cada pantalla!
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
}