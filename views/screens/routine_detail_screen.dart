// Este código es una composición basada en patrones oficiales de Flutter/Dart
// y los recursos de referencia indicados

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/routine_model.dart';
import '../../theme/app_colors.dart';
import '../../viewmodels/registro_viewmodel.dart';
import '../../viewmodels/login_viewmodel.dart';

class RoutineDetailScreen extends StatelessWidget {
  final RoutineModel routine;

  const RoutineDetailScreen({super.key, required this.routine});

  // ✅ Recibe context para poder leer providers y mostrar diálogos
  void _mostrarDialogoCompletar(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      // ✅ barrierDismissible: false — el usuario no puede cerrar
      // el diálogo tocando fuera mientras se procesa la petición
      barrierDismissible: false,
      builder: (dialogContext) => _ConfirmarEntrenamientoDialog(
        routine: routine,
        theme: theme,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(routine.nombre, style: theme.textTheme.titleLarge),
        backgroundColor: AppColors.surface,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.background, AppColors.surface],
          ),
        ),
        // ✅ Column con Expanded para que lista + botón convivan sin overflow
        child: Column(
          children: [
            Expanded(
              child: routine.ejercicios.isEmpty
                  ? Center(
                child: Text(
                  "Esta rutina no tiene ejercicios todavía.",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: routine.ejercicios.length,
                itemBuilder: (context, index) {
                  return _buildExerciseCard(
                    routine.ejercicios[index],
                    theme,
                  );
                },
              ),
            ),

            // ✅ Botón fijo al fondo, fuera del scroll
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  // ✅ Deshabilitado si la rutina está vacía — no tiene sentido
                  // completar una rutina sin ejercicios
                  onPressed: routine.ejercicios.isEmpty
                      ? null
                      : () => _mostrarDialogoCompletar(context),
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text(
                    "COMPLETAR ENTRENAMIENTO",
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(ExerciseModel ex, ThemeData theme) {
    return Card(
      color: AppColors.surfaceLight,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Icon(Icons.fitness_center, color: Colors.black),
        ),
        title: Text(
          ex.nombre,
          style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "${ex.series} series x ${ex.repeticiones} reps",
          style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
        ),
        trailing: ex.descripcion.isNotEmpty
            ? const Icon(Icons.info_outline, color: AppColors.textSecondary)
            : null,
      ),
    );
  }
}

// ✅ Diálogo extraído a su propio StatefulWidget
// Motivo: necesita manejar su propio _isLoading para el spinner
// sin reconstruir toda la pantalla de detalle
class _ConfirmarEntrenamientoDialog extends StatefulWidget {
  final RoutineModel routine;
  final ThemeData theme;

  const _ConfirmarEntrenamientoDialog({
    required this.routine,
    required this.theme,
  });

  @override
  State<_ConfirmarEntrenamientoDialog> createState() =>
      _ConfirmarEntrenamientoDialogState();
}

class _ConfirmarEntrenamientoDialogState
    extends State<_ConfirmarEntrenamientoDialog> {
  bool _isLoading = false;

  Future<void> _confirmar() async {
    setState(() => _isLoading = true);

    final token =
        context.read<LoginViewModel>().user?.token ?? '';
    final success = await context.read<RegistroViewModel>().completarEntrenamiento(
      token,
      widget.routine.id ?? '',
      widget.routine.nombre,
      widget.routine.ejercicios.length,
    );

    if (!mounted) return;

    // ✅ CRÍTICO: cerramos el diálogo ANTES del SnackBar
    // Si intentamos mostrar el SnackBar con el diálogo abierto,
    // el context puede estar en un estado inconsistente
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? '¡Entrenamiento completado! 💪'
              : 'Error al guardar el registro. Inténtalo de nuevo.',
          style: widget.theme.textTheme.bodyLarge,
        ),
        backgroundColor:
        success ? AppColors.success : AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceLight,
      title: Text(
        '¿Completar entrenamiento?',
        style: widget.theme.textTheme.titleLarge,
      ),
      content: Text(
        'Se registrará "${widget.routine.nombre}" como completada hoy.',
        style: widget.theme.textTheme.bodyMedium,
      ),
      actions: [
        // ✅ Cancelar deshabilitado mientras carga — no permitimos
        // salir del diálogo a mitad de una petición
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text(
            'CANCELAR',
            style: widget.theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.background,
          ),
          onPressed: _isLoading ? null : _confirmar,
          child: _isLoading
              ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.background,
            ),
          )
              : Text(
            'COMPLETAR',
            style: widget.theme.textTheme.labelLarge,
          ),
        ),
      ],
    );
  }
}