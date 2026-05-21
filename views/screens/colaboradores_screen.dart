import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/routine_model.dart';
import '../../viewmodels/routine_viewmodel.dart';
import '../../viewmodels/login_viewmodel.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

class ColaboradoresScreen extends StatefulWidget {
  final RoutineModel routine;

  const ColaboradoresScreen({super.key, required this.routine});

  @override
  State<ColaboradoresScreen> createState() => _ColaboradoresScreenState();
}

class _ColaboradoresScreenState extends State<ColaboradoresScreen> {
  final _emailCtrl = TextEditingController();
  bool _isAdding = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _anadirColaborador() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) return;

    setState(() => _isAdding = true);

    final token = context.read<LoginViewModel>().user?.token ?? '';
    final error = await context
        .read<RoutineViewModel>()
        .addColaborador(widget.routine.id ?? '', email, token);

    if (!mounted) return;
    setState(() => _isAdding = false);

    if (error == null) {
      _emailCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Colaborador añadido correctamente'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _quitarColaborador(ColaboradorModel colaborador) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (d) {
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: AppColors.surfaceLight,
          title: Text('¿Quitar colaborador?', style: theme.textTheme.titleLarge),
          content: Text(
            '${colaborador.nombre} perderá el acceso a esta rutina.',
            style: theme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(d, false),
              child: Text('CANCELAR',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: AppColors.textMuted)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(d, true),
              child: Text('QUITAR',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: AppColors.error)),
            ),
          ],
        );
      },
    );

    if (!(confirmar ?? false) || !mounted) return;

    final token = context.read<LoginViewModel>().user?.token ?? '';
    final success = await context
        .read<RoutineViewModel>()
        .removeColaborador(widget.routine.id ?? '', colaborador.usuarioId, token);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? '${colaborador.nombre} eliminado'
              : 'Error al quitar el colaborador'),
          backgroundColor: success ? AppColors.surface : AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rutina = context
        .watch<RoutineViewModel>()
        .routines
        .firstWhere(
          (r) => r.id == widget.routine.id,
      orElse: () => widget.routine,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: AppColors.primary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Colaboradores', style: theme.textTheme.displayLarge),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //  Anadir colaborador
            _buildSectionLabel('Anadir por email', theme),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    style: theme.textTheme.bodyLarge,
                    decoration: InputDecoration(
                      hintText: 'email@ejemplo.com',
                      hintStyle: theme.textTheme.bodyMedium
                          ?.copyWith(color: AppColors.textMuted),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 1.5),
                      ),
                    ),
                    onSubmitted: (_) => _anadirColaborador(),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 52,
                  child: OutlinedButton(
                    style: AppTheme.primaryButtonStyle,
                    onPressed: _isAdding ? null : _anadirColaborador,
                    child: _isAdding
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.primary),
                    )
                        : const Icon(Icons.person_add_outlined,
                        color: AppColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            _buildSectionLabel(
                'Acceso actual (${rutina.colaboradores.length})', theme),
            const SizedBox(height: 8),

            if (rutina.colaboradores.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'Aún no hay colaboradores.\nAñade a alguien por su email.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: AppColors.textMuted),
                  ),
                ),
              )
            else
              ...rutina.colaboradores.map(
                    (colaborador) => _buildColaboradorItem(colaborador, theme),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildColaboradorItem(ColaboradorModel colaborador, ThemeData theme) {
    return Dismissible(
      key: ValueKey(colaborador.usuarioId),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.person_remove_outlined,
            color: Colors.white, size: 22),
      ),
      confirmDismiss: (_) async {
        await _quitarColaborador(colaborador);
        return false;
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: AppColors.primary.withOpacity(0.15), width: 1),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.surfaceLight,
              child: Text(
                colaborador.nombre.isNotEmpty
                    ? colaborador.nombre[0].toUpperCase()
                    : '?',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(colaborador.nombre,
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  Text(colaborador.email,
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
            ),
            _buildBadge(colaborador.puedeEditar, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(bool puedeEditar, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: puedeEditar
            ? const Color(0xFF4FC3F7).withOpacity(0.15)
            : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: puedeEditar
              ? const Color(0xFF4FC3F7).withOpacity(0.4)
              : AppColors.textMuted.withOpacity(0.3),
        ),
      ),
      child: Text(
        puedeEditar ? 'Editar' : 'Solo ver',
        style: TextStyle(
          color: puedeEditar ? const Color(0xFF4FC3F7) : AppColors.textMuted,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label, ThemeData theme) => Text(
    label.toUpperCase(),
    style: theme.textTheme.bodyMedium?.copyWith(
      color: AppColors.textMuted,
      fontSize: 10,
      letterSpacing: 1.1,
      fontWeight: FontWeight.bold,
    ),
  );
}