// Este código es una composición basada en patrones oficiales de Flutter/Dart
// y los recursos de referencia indicados

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // ← Una sola importación
import '../../viewmodels/profile_viewmodel.dart';
import '../../viewmodels/login_viewmodel.dart';
import '../../viewmodels/registro_viewmodel.dart';
import '../../models/user_model.dart';
import '../../theme/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    // select evita reconstruir toda la pantalla si cambia
    // un campo que no usamos — bien aplicado, mantenlo
    final isLoading = context.select<ProfileViewModel, bool>(
          (vm) => vm.isLoading,
    );
    final user = context.select<ProfileViewModel, UserModel?>(
          (vm) => vm.user,
    );
    final errorMessage = context.select<ProfileViewModel, String?>(
          (vm) => vm.errorMessage,
    );
    final totalEntrenamientos = context.select<RegistroViewModel, int>(
          (vm) => vm.totalEntrenamientos,
    );
    final esteMes = context.select<RegistroViewModel, int>(
          (vm) => vm.esteMes,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text("Mi perfil", style: theme.textTheme.displayLarge),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: primaryColor),
            // TODO: Navegar a pantalla de edición de perfil
            onPressed: () => debugPrint('Editar perfil'),
          ),
        ],
      ),
      body: _buildBody(
        context: context,
        theme: theme,
        primaryColor: primaryColor,
        isLoading: isLoading,
        user: user,
        errorMessage: errorMessage,
        totalEntrenamientos: totalEntrenamientos,
        esteMes: esteMes,
      ),
    );
  }

  Widget _buildBody({
    required BuildContext context,
    required ThemeData theme,
    required Color primaryColor,
    required bool isLoading,
    required UserModel? user,
    required String? errorMessage,
    required int totalEntrenamientos,
    required int esteMes,
  }) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(color: primaryColor),
      );
    }

    // Estado de error explícito — ya no se confunde con "usuario null"
    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                size: 60, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: AppColors.error),
            ),
          ],
        ),
      );
    }

    if (user == null) {
      return const Center(
        child: Text(
          "Error al cargar perfil",
          style: TextStyle(color: AppColors.error),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Cabecera
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.surface,
                  child: Icon(Icons.person, size: 50, color: primaryColor),
                ),
                const SizedBox(height: 15),
                Text(
                  user.nombre,
                  style: theme.textTheme.displayLarge
                      ?.copyWith(fontSize: 26),
                ),
                Text(
                  user.email,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          _buildSectionLabel('Datos corporales', theme),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStat(primaryColor, "Peso",
                    user.pesoActual != null ? "${user.pesoActual} kg" : "—", theme),
                _buildVerticalDivider(),
                _buildStat(primaryColor, "Altura",
                    user.altura != null ? "${user.altura} cm" : "—", theme),
                _buildVerticalDivider(),
                _buildStat(primaryColor, "Edad",
                    user.edad != null ? "${user.edad}" : "—", theme),
              ],
            ),
          ),
          const SizedBox(height: 16),

// Tarjeta 2 — Actividad
          _buildSectionLabel('Actividad', theme),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStat(primaryColor, "Entrenos totales",
                    '$totalEntrenamientos', theme),
                _buildVerticalDivider(),
                _buildStat(primaryColor, "Este mes",
                    '$esteMes', theme),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // Información adicional
          // TODO: Calcular fecha de miembro desde user.fechaMiembro
          _buildInfoTile(
            Icons.calendar_today,
            "Miembro desde",
            _formatFecha(user.fechaMiembro),
            theme,
          ),
          _buildInfoTile(
            Icons.fitness_center,
            "Nivel",
            user.experiencia ?? "—",
            theme,
          ),

          const SizedBox(height: 40),

          // Botón cerrar sesión
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.textPrimary,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _mostrarDialogoLogout(context),
              child: const Text(
                "CERRAR SESIÓN",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStat(
      Color color, String label, String value, ThemeData theme) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildInfoTile(
      IconData icon, String title, String value, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 15),
          Text(title, style: theme.textTheme.bodyMedium),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.bodyLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label.toUpperCase(),
        style: theme.textTheme.bodyMedium?.copyWith(
          color: AppColors.textMuted,
          fontSize: 11,
          letterSpacing: 1.2,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 36,
      color: AppColors.textMuted.withOpacity(0.2),
    );
  }

  void _mostrarDialogoLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surfaceLight,
        title: Text("¿Cerrar sesión?",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content:
        const Text("¿Estás seguro de que quieres abandonar el barco?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              "CANCELAR",
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              // logout() ahora existe en LoginViewModel
              await Provider.of<LoginViewModel>(
                context,
                listen: false,
              ).logout();

              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                      (route) => false,
                );
              }
            },
            child: const Text(
              "SÍ, SALIR",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  String _formatFecha(String? fechaIso) {
    if (fechaIso == null) return '—';
    try {
      final fecha = DateTime.parse(fechaIso);
      // Formato simple: "Mayo 2025"
      const meses = [
        'Enero','Febrero','Marzo','Abril','Mayo','Junio',
        'Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'
      ];
      return '${meses[fecha.month - 1]} ${fecha.year}';
    } catch (_) {
      return '—';
    }
  }
}