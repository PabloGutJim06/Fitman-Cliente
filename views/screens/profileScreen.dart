import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../viewmodels/login_viewmodel.dart';
import '../../viewmodels/registro_viewmodel.dart';
import '../../models/user_model.dart';
import '../../theme/app_colors.dart';
import 'edit_profile_screen.dart';
import 'chat_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

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
            icon: const Icon(Icons.fitness_center, color: AppColors.primary),
            tooltip: 'Asistente FitMan',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChatScreen()),
            ),
          ),
          IconButton(
            icon: Icon(Icons.settings_outlined, color: primaryColor),
            onPressed: () => _mostrarOpcionesCuenta(context, theme),
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

  void _mostrarOpcionesCuenta(BuildContext context, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle visual
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.textMuted.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Opción 1 — Editar perfil
              _buildOpcionCuenta(
                context: context,
                theme: theme,
                icon: Icons.edit_outlined,
                titulo: 'Editar perfil',
                subtitulo: 'Modifica tus datos personales',
                color: AppColors.primary,
                onTap: () {
                  Navigator.pop(sheetContext);
                  final user = context
                      .read<ProfileViewModel>()
                      .user;
                  if (user != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditProfileScreen(user: user),
                      ),
                    );
                  }
                },
              ),

              // Opción 2 — Ayuda
              _buildOpcionCuenta(
                context: context,
                theme: theme,
                icon: Icons.help_outline_rounded,
                titulo: 'Ayuda',
                subtitulo: 'Preguntas frecuentes y soporte',
                color: AppColors.textSecondary,
                onTap: () {
                  Navigator.pop(sheetContext);
                  debugPrint('Ayuda — TODO');
                },
              ),

              _buildOpcionCuenta(
                context: context,
                theme: theme,
                icon: Icons.fitness_center,
                titulo: 'Asistente FitMan',
                subtitulo: 'Tu entrenador personal con IA',
                color: AppColors.primary,
                onTap: () {
                  Navigator.pop(sheetContext);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ChatScreen()),
                  );
                },
              ),

              const Divider(
                color: AppColors.surface,
                height: 24,
                indent: 20,
                endIndent: 20,
              ),

              // Opción 3 — Cerrar sesión
              _buildOpcionCuenta(
                context: context,
                theme: theme,
                icon: Icons.logout_rounded,
                titulo: 'Cerrar sesión',
                subtitulo: 'Salir de tu cuenta',
                color: AppColors.error,
                onTap: () {
                  Navigator.pop(sheetContext);
                  _mostrarDialogoLogout(context, theme);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOpcionCuenta({
    required BuildContext context,
    required ThemeData theme,
    required IconData icon,
    required String titulo,
    required String subtitulo,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        titulo,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        subtitulo,
        style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        color: AppColors.textMuted,
        size: 14,
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
      return Center(child: CircularProgressIndicator(color: primaryColor));
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: AppColors.error),
            const SizedBox(height: 16),
            Text(errorMessage,
                style: theme.textTheme.bodyLarge
                    ?.copyWith(color: AppColors.error)),
          ],
        ),
      );
    }

    if (user == null) {
      return Center(
        child: Text("Error al cargar perfil",
            style: theme.textTheme.bodyLarge
                ?.copyWith(color: AppColors.error)),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.surface,
                  child: Icon(Icons.person, size: 50, color: primaryColor),
                ),
                const SizedBox(height: 15),
                Text(user.nombre,
                    style: theme.textTheme.displayLarge
                        ?.copyWith(fontSize: 26)),
                Text(user.email,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: AppColors.textSecondary)),
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
                    user.pesoActual != null ? "${user.pesoActual} kg" : "—",
                    theme),
                _buildVerticalDivider(),
                _buildStat(primaryColor, "Altura",
                    user.altura != null ? "${user.altura} cm" : "—", theme),
                _buildVerticalDivider(),
                _buildStat(primaryColor, "Edad",
                    user.edad != null ? "${user.edad} años" : "—", theme),
              ],
            ),
          ),
          const SizedBox(height: 16),

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
                _buildStat(primaryColor, "Este mes", '$esteMes', theme),
              ],
            ),
          ),
          const SizedBox(height: 30),

          _buildInfoTile(Icons.calendar_today, "Miembro desde",
              _formatFecha(user.fechaMiembro), theme),
          _buildInfoTile(
            Icons.bar_chart_rounded,
            "Nivel",
            user.nivel != null ? _capitalizarPrimera(user.nivel!) : "—",
            theme,
          ),
          _buildInfoTile(
            Icons.flag_outlined,
            "Objetivo",
            user.objetivo != null
                ? _capitalizarPrimera(user.objetivo!)
                : "—",
            theme,
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
        Text(value,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            )),
        const SizedBox(height: 4),
        Text(label,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: AppColors.textSecondary)),
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
          Text(value,
              style: theme.textTheme.bodyLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
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

  void _mostrarDialogoLogout(BuildContext context, ThemeData theme) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surfaceLight,
        title: Text("¿Cerrar sesión?", style: theme.textTheme.titleLarge),
        content: Text(
          "¿Estás seguro de que quieres cerrar sesión?",
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text("CANCELAR",
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await Provider.of<LoginViewModel>(context, listen: false)
                  .logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (route) => false);
              }
            },
            child: Text("SÍ, SALIR",
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
  }


  String _formatFecha(String? fechaIso) {
    if (fechaIso == null) return '—';
    try {
      final fecha = DateTime.parse(fechaIso);
      const meses = [
        'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
        'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
      ];
      return '${meses[fecha.month - 1]} ${fecha.year}';
    } catch (_) {
      return '—';
    }
  }

  String _capitalizarPrimera(String texto) =>
      texto.isEmpty ? texto : texto[0].toUpperCase() + texto.substring(1);
}