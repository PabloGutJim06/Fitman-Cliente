import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/edit_profile_viewmodel.dart';
import '../../viewmodels/login_viewmodel.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../models/user_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nombreCtrl = TextEditingController();
  final _edadCtrl = TextEditingController();
  final _pesoCtrl = TextEditingController();
  final _alturaCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final vm = context.read<EditProfileViewModel>();
    vm.inicializar(widget.user);

    _nombreCtrl.text = widget.user.nombre;
    _edadCtrl.text = widget.user.edad?.toString() ?? '';
    _pesoCtrl.text = widget.user.pesoActual?.toString() ?? '';
    _alturaCtrl.text = widget.user.altura?.toString() ?? '';
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _edadCtrl.dispose();
    _pesoCtrl.dispose();
    _alturaCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final vm = context.read<EditProfileViewModel>();
    final token = context.read<LoginViewModel>().user?.token ?? '';

    final success = await vm.guardar(token);

    if (!mounted) return;

    if (success) {
      await context.read<ProfileViewModel>().loadUserProfile(token);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('¡Perfil actualizado correctamente!'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.errorMessage ?? 'Error al guardar'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vm = context.watch<EditProfileViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: AppColors.textSecondary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Editar perfil', style: theme.textTheme.displayLarge),
        actions: [
          TextButton(
            onPressed: vm.isLoading || !vm.formularioValido
                ? null
                : _guardar,
            child: Text(
              'Guardar',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: vm.formularioValido
                    ? AppColors.primary
                    : AppColors.textMuted,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            _buildSectionLabel('Datos personales', theme),
            const SizedBox(height: 12),
            _buildCampo(
              controller: _nombreCtrl,
              label: 'Nombre',
              icon: Icons.badge_outlined,
              theme: theme,
              onChanged: vm.actualizarNombre,
            ),
            const SizedBox(height: 28),

            _buildSectionLabel('Datos corporales', theme),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildCampo(
                    controller: _edadCtrl,
                    label: 'Edad',
                    icon: Icons.cake_outlined,
                    theme: theme,
                    tipo: TextInputType.number,
                    onChanged: vm.actualizarEdad,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildCampo(
                    controller: _pesoCtrl,
                    label: 'Peso (kg)',
                    icon: Icons.monitor_weight_outlined,
                    theme: theme,
                    tipo: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: vm.actualizarPeso,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildCampo(
                    controller: _alturaCtrl,
                    label: 'Altura (cm)',
                    icon: Icons.height_rounded,
                    theme: theme,
                    tipo: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: vm.actualizarAltura,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            _buildSectionLabel('Tu nivel', theme),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.2,
              children: [
                _buildGridCard(
                  valor: 'principiante',
                  icono: Icons.directions_walk_rounded,
                  titulo: 'Principiante',
                  seleccionado: vm.nivel == 'principiante',
                  onTap: () => vm.seleccionarNivel('principiante'),
                  theme: theme,
                ),
                _buildGridCard(
                  valor: 'intermedio',
                  icono: Icons.directions_run_rounded,
                  titulo: 'Intermedio',
                  seleccionado: vm.nivel == 'intermedio',
                  onTap: () => vm.seleccionarNivel('intermedio'),
                  theme: theme,
                ),
                _buildGridCard(
                  valor: 'avanzado',
                  icono: Icons.sports_martial_arts_rounded,
                  titulo: 'Avanzado',
                  seleccionado: vm.nivel == 'avanzado',
                  onTap: () => vm.seleccionarNivel('avanzado'),
                  theme: theme,
                ),
                _buildGridCard(
                  valor: 'culturista',
                  icono: Icons.emoji_events_rounded,
                  titulo: 'Culturista',
                  seleccionado: vm.nivel == 'culturista',
                  onTap: () => vm.seleccionarNivel('culturista'),
                  theme: theme,
                ),
              ],
            ),
            const SizedBox(height: 28),

            _buildSectionLabel('Tu objetivo', theme),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildObjetivoCard(
                    valor: 'perder peso',
                    icono: Icons.trending_down_rounded,
                    titulo: 'Perder\npeso',
                    seleccionado: vm.objetivo == 'perder peso',
                    onTap: () => vm.seleccionarObjetivo('perder peso'),
                    theme: theme,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildObjetivoCard(
                    valor: 'ganar músculo',
                    icono: Icons.trending_up_rounded,
                    titulo: 'Ganar\nmúsculo',
                    seleccionado: vm.objetivo == 'ganar músculo',
                    onTap: () => vm.seleccionarObjetivo('ganar músculo'),
                    theme: theme,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildObjetivoCard(
                    valor: 'mantener peso',
                    icono: Icons.balance_rounded,
                    titulo: 'Mantener\npeso',
                    seleccionado: vm.objetivo == 'mantener peso',
                    onTap: () => vm.seleccionarObjetivo('mantener peso'),
                    theme: theme,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.background,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: vm.isLoading || !vm.formularioValido
                    ? null
                    : _guardar,
                child: vm.isLoading
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.background),
                )
                    : Text(
                  'GUARDAR CAMBIOS',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label, ThemeData theme) {
    return Text(
      label.toUpperCase(),
      style: theme.textTheme.bodyMedium?.copyWith(
        color: AppColors.textMuted,
        fontSize: 11,
        letterSpacing: 1.2,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildCampo({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ThemeData theme,
    TextInputType tipo = TextInputType.text,
    required ValueChanged<String> onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: tipo,
      style: theme.textTheme.bodyLarge,
      onChanged: onChanged,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
        labelText: label,
        labelStyle: theme.textTheme.bodyMedium
            ?.copyWith(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildGridCard({
    required String valor,
    required IconData icono,
    required String titulo,
    required bool seleccionado,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          color: seleccionado
              ? AppColors.primary.withOpacity(0.12)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: seleccionado ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        padding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(
              icono,
              color: seleccionado
                  ? AppColors.primary
                  : AppColors.textSecondary,
              size: 22,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                titulo,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: seleccionado
                      ? AppColors.primary
                      : AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildObjetivoCard({
    required String valor,
    required IconData icono,
    required String titulo,
    required bool seleccionado,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: seleccionado
              ? AppColors.primary.withOpacity(0.12)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: seleccionado ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icono,
              color: seleccionado
                  ? AppColors.primary
                  : AppColors.textSecondary,
              size: 22,
            ),
            const SizedBox(height: 6),
            Text(
              titulo,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: seleccionado
                    ? AppColors.primary
                    : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}