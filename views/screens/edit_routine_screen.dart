import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/routine_model.dart';
import '../../viewmodels/routine_viewmodel.dart';
import '../../viewmodels/ejercicio_viewmodel.dart';
import '../../viewmodels/login_viewmodel.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

class EditRoutineScreen extends StatefulWidget {
  final RoutineModel routine;

  const EditRoutineScreen({super.key, required this.routine});

  @override
  State<EditRoutineScreen> createState() => _EditRoutineScreenState();
}

class _EditRoutineScreenState extends State<EditRoutineScreen> {
  late TextEditingController _nameCtrl;
  late List<ExerciseModel> _ejercicios;
  bool _isSaving = false;
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.routine.nombre);
    _ejercicios = widget.routine.ejercicios
        .map((e) => ExerciseModel(
      nombre: e.nombre,
      descripcion: e.descripcion,
      duracion: e.duracion,
      series: e.series,
      repeticiones: e.repeticiones,
      descansoSegundos: e.descansoSegundos,
    ))
        .toList();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El nombre no puede estar vacío'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final token = context.read<LoginViewModel>().user?.token ?? '';
    final rutinaActualizada = RoutineModel(
      id: widget.routine.id,
      nombre: _nameCtrl.text.trim(),
      ejercicios: _ejercicios,
    );

    final success = await context
        .read<RoutineViewModel>()
        .updateRoutine(rutinaActualizada, token);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      Navigator.pop(context, rutinaActualizada);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rutina actualizada correctamente'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al guardar los cambios'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _eliminarEjercicio(int index) {
    setState(() => _ejercicios.removeAt(index));
  }

  void _abrirEditarEjercicio(int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _EditExerciseSheet(
        ejercicio: _ejercicios[index],
        ejercicioVM: context.read<EjercicioViewModel>(),
        onGuardar: (actualizado) {
          setState(() {
            _ejercicios[index] = actualizado;
            _selectedIndex = null;
          });
        },
      ),
    );
  }

  void _abrirAnadirEjercicio() {
    final ejercicioVM = context.read<EjercicioViewModel>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _AddExerciseInlineSheet(
        ejercicioVM: ejercicioVM,
        onAnadir: (nuevo) {
          setState(() => _ejercicios.add(nuevo));
        },
      ),
    );
  }

  void _abrirAnadirDescanso() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _AddDescansoInlineSheet(
        onAnadir: (segundos) {
          setState(() => _ejercicios.add(
            ExerciseModel(nombre: 'Descanso', duracion: segundos),
          ));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: AppColors.textSecondary, size: 20),
          onPressed: () => _confirmarSalir(context),
        ),
        title: Text('Editar rutina', style: theme.textTheme.displayLarge),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _guardar,
            child: _isSaving
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.primary),
            )
                : Text(
              'Guardar',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Campo nombre
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionLabel('Nombre', theme),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameCtrl,
                  style: theme.textTheme.bodyLarge,
                  decoration: InputDecoration(
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
                ),
                const SizedBox(height: 20),
                _buildSectionLabel(
                    'Ejercicios (${_ejercicios.length})', theme),
                const SizedBox(height: 8),
              ],
            ),
          ),

          Expanded(
            child: _ejercicios.isEmpty
                ? Center(
              child: Text(
                'No hay ejercicios.\nPulsa + para añadir.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: AppColors.textMuted),
              ),
            )
                : ReorderableListView.builder(
              padding:
              const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _ejercicios.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex--;
                  final item = _ejercicios.removeAt(oldIndex);
                  _ejercicios.insert(newIndex, item);
                });
              },
              itemBuilder: (context, index) {
                final ex = _ejercicios[index];
                final esDescanso = ex.isDescanso;
                return _buildEjercicioItem(
                    key: ValueKey('$index-${ex.nombre}'),
                    ex: ex,
                    esDescanso: esDescanso,
                    index: index,
                    theme: theme);
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(
                          color: AppColors.primary, width: 1.5),
                      padding:
                      const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _abrirAnadirEjercicio,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Ejercicio'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(
                          color: AppColors.surfaceLight),
                      padding:
                      const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _abrirAnadirDescanso,
                    icon: const Icon(Icons.timer_outlined, size: 18),
                    label: const Text('Descanso'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEjercicioItem({
    required Key key,
    required ExerciseModel ex,
    required bool esDescanso,
    required int index,
    required ThemeData theme,
  }) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      key: key,
      onTap: () {
        setState(() {
          _selectedIndex = isSelected ? null : index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.surfaceLight
              : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withOpacity(0.4)
                : esDescanso
                ? Colors.transparent
                : AppColors.primary.withOpacity(0.15),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              leading: ReorderableDragStartListener(
                index: index,
                child: const Icon(Icons.drag_handle_rounded,
                    color: AppColors.textMuted, size: 22),
              ),
              title: Text(
                ex.nombre,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: esDescanso
                      ? AppColors.textSecondary
                      : AppColors.textPrimary,
                ),
              ),
              subtitle: Text(
                esDescanso
                    ? '${ex.duracion}s de descanso'
                    : '${ex.series} series × ${ex.repeticiones} reps',
                style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted, fontSize: 11),
              ),
            ),

            AnimatedCrossFade(
              duration: const Duration(milliseconds: 200),
              crossFadeState: isSelected
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: Padding(
                padding:
                const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Row(
                  children: [
                    // Botón editar — para ejercicios Y descansos
                    Expanded(
                      child: GestureDetector(
                        onTap: () => esDescanso
                            ? _abrirEditarDescanso(index)
                            : _abrirEditarEjercicio(index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color:
                                AppColors.primary.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            children: [
                              Icon(
                                esDescanso
                                    ? Icons.timer_outlined
                                    : Icons.edit_outlined,
                                color: AppColors.primary,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Editar',
                                style: theme.textTheme.bodyMedium
                                    ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Botón eliminar
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _ejercicios.removeAt(index);
                            _selectedIndex = null;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: AppColors.error.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.delete_outline,
                                  color: AppColors.error, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                'Eliminar',
                                style: theme.textTheme.bodyMedium
                                    ?.copyWith(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              secondChild: const SizedBox.shrink(),
            ),
          ],
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

  void _abrirEditarDescanso(int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _AddDescansoInlineSheet(
        segundosIniciales: _ejercicios[index].duracion,
        onAnadir: (segundos) {
          setState(() {
            _ejercicios[index] = ExerciseModel(
              nombre: 'Descanso',
              duracion: segundos,
            );
            _selectedIndex = null;
          });
        },
      ),
    );
  }

  Future<void> _confirmarSalir(BuildContext context) async {
    final theme = Theme.of(context);
    final salir = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        backgroundColor: AppColors.surfaceLight,
        title: Text('¿Salir sin guardar?',
            style: theme.textTheme.titleLarge),
        content: Text(
          'Los cambios no guardados se perderán.',
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
            child: Text('SALIR',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
    if ((salir ?? false) && context.mounted) Navigator.pop(context);
  }
}

class _EditExerciseSheet extends StatefulWidget {
  final ExerciseModel ejercicio;
  final EjercicioViewModel ejercicioVM;
  final ValueChanged<ExerciseModel> onGuardar;

  const _EditExerciseSheet({
    required this.ejercicio,
    required this.ejercicioVM,
    required this.onGuardar,
  });

  @override
  State<_EditExerciseSheet> createState() => _EditExerciseSheetState();
}

class _EditExerciseSheetState extends State<_EditExerciseSheet> {
  late TextEditingController _nombreCtrl;
  late TextEditingController _seriesCtrl;
  late TextEditingController _repsCtrl;
  final _nombreFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.ejercicio.nombre);
    _seriesCtrl =
        TextEditingController(text: widget.ejercicio.series.toString());
    _repsCtrl = TextEditingController(
        text: widget.ejercicio.repeticiones.toString());
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _seriesCtrl.dispose();
    _repsCtrl.dispose();
    _nombreFocus.dispose();
    widget.ejercicioVM.limpiarSugerenciasSilencioso();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: ListenableBuilder(
            listenable: widget.ejercicioVM,
            builder: (context, _) {
              final sugerencias = widget.ejercicioVM.sugerencias;
              final coincide =
              widget.ejercicioVM.buscarPorNombre(_nombreCtrl.text);

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.textMuted.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.edit_outlined,
                            color: AppColors.primary, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Text('Editar ejercicio',
                          style: theme.textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    controller: _nombreCtrl,
                    focusNode: _nombreFocus,
                    style: theme.textTheme.bodyLarge,
                    decoration: InputDecoration(
                      hintText: 'Nombre del ejercicio',
                      hintStyle: theme.textTheme.bodyMedium
                          ?.copyWith(color: AppColors.textMuted),
                      filled: true,
                      fillColor: AppColors.surfaceLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 1.5),
                      ),
                      suffixIcon: coincide != null
                          ? const Icon(Icons.info_outline,
                          color: AppColors.primary)
                          : null,
                    ),
                    onChanged: (v) {
                      widget.ejercicioVM.buscar(v);
                      setState(() {});
                    },
                  ),

                  if (sugerencias.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppColors.primary.withOpacity(0.2)),
                      ),
                      child: Column(
                        children: sugerencias.map((ej) {
                          return InkWell(
                            onTap: () {
                              _nombreCtrl.text = ej.nombre;
                              widget.ejercicioVM.limpiarSugerencias();
                              setState(() {});
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              child: Row(
                                children: [
                                  _grupoChip(ej.grupoMuscular, theme),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(ej.nombre,
                                        style: theme.textTheme.bodyMedium),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('SERIES', theme),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _seriesCtrl,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                              decoration: _inputDeco(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('REPETICIONES', theme),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _repsCtrl,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                              decoration: _inputDeco(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            side: const BorderSide(
                                color: AppColors.surfaceLight),
                            padding: const EdgeInsets.symmetric(
                                vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: Text('Cancelar',
                              style: theme.textTheme.bodyMedium),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: OutlinedButton(
                          style: AppTheme.primaryButtonStyle,
                          onPressed: () {
                            if (_nombreCtrl.text.isNotEmpty) {
                              widget.onGuardar(ExerciseModel(
                                nombre: _nombreCtrl.text,
                                descripcion: widget.ejercicio.descripcion,
                                series: int.tryParse(_seriesCtrl.text) ?? 0,
                                repeticiones: int.tryParse(_repsCtrl.text) ?? 0,
                                duracion: widget.ejercicio.duracion,
                                descansoSegundos: widget.ejercicio.descansoSegundos,
                              ));
                              Navigator.pop(context);
                            }
                          },
                          child: Text('Guardar cambios',
                              style: theme.textTheme.labelLarge?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String t, ThemeData theme) => Text(t,
      style: theme.textTheme.bodyMedium?.copyWith(
          color: AppColors.textMuted,
          fontSize: 10,
          letterSpacing: 1.1,
          fontWeight: FontWeight.bold));

  InputDecoration _inputDeco() => InputDecoration(
    filled: true,
    fillColor: AppColors.surfaceLight,
    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide:
        const BorderSide(color: AppColors.primary, width: 1.5)),
  );

  Widget _grupoChip(String grupo, ThemeData theme) {
    final config = _cfg(grupo);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: config.$1.withOpacity(0.15),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: config.$1.withOpacity(0.35)),
      ),
      child: Text(config.$2,
          style: TextStyle(
              color: config.$1, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }

  (Color, String) _cfg(String g) => switch (g) {
    'pecho' => (const Color(0xFF4FC3F7), 'PECHO'),
    'espalda' => (const Color(0xFF81C784), 'ESPALDA'),
    'piernas' => (const Color(0xFFFFB74D), 'PIERNAS'),
    'hombros' => (const Color(0xFFCE93D8), 'HOMBROS'),
    'brazos' => (const Color(0xFFFF8A65), 'BRAZOS'),
    'core' => (const Color(0xFFF06292), 'CORE'),
    'cardio' => (const Color(0xFF4DB6AC), 'CARDIO'),
    'gluteos' => (const Color(0xFFDCE775), 'GLÚTEOS'),
    'gemelos' => (const Color(0xFFFFD54F), 'GEMELOS'),
    _ => (AppColors.textMuted, g.toUpperCase()),
  };
}

class _AddExerciseInlineSheet extends StatefulWidget {
  final EjercicioViewModel ejercicioVM;
  final ValueChanged<ExerciseModel> onAnadir;

  const _AddExerciseInlineSheet({
    required this.ejercicioVM,
    required this.onAnadir,
  });

  @override
  State<_AddExerciseInlineSheet> createState() =>
      _AddExerciseInlineSheetState();
}

class _AddExerciseInlineSheetState
    extends State<_AddExerciseInlineSheet> {
  final _nombreCtrl = TextEditingController();
  final _seriesCtrl = TextEditingController();
  final _repsCtrl = TextEditingController();
  final _nombreFocus = FocusNode();

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _seriesCtrl.dispose();
    _repsCtrl.dispose();
    _nombreFocus.dispose();
    widget.ejercicioVM.limpiarSugerenciasSilencioso();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: ListenableBuilder(
            listenable: widget.ejercicioVM,
            builder: (context, _) {
              final sugerencias = widget.ejercicioVM.sugerencias;
              final coincide = widget.ejercicioVM
                  .buscarPorNombre(_nombreCtrl.text);

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.textMuted.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.fitness_center_rounded,
                            color: AppColors.primary, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Text('Nuevo ejercicio',
                          style: theme.textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _nombreCtrl,
                    focusNode: _nombreFocus,
                    style: theme.textTheme.bodyLarge,
                    decoration: InputDecoration(
                      hintText: 'ej: Press Banca',
                      hintStyle: theme.textTheme.bodyMedium
                          ?.copyWith(color: AppColors.textMuted),
                      filled: true,
                      fillColor: AppColors.surfaceLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 1.5),
                      ),
                      suffixIcon: coincide != null
                          ? const Icon(Icons.info_outline,
                          color: AppColors.primary)
                          : null,
                    ),
                    onChanged: (v) {
                      widget.ejercicioVM.buscar(v);
                      setState(() {});
                    },
                  ),
                  if (sugerencias.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppColors.primary.withOpacity(0.2)),
                      ),
                      child: Column(
                        children: sugerencias.map((ej) {
                          return InkWell(
                            onTap: () {
                              _nombreCtrl.text = ej.nombre;
                              widget.ejercicioVM.limpiarSugerencias();
                              setState(() {});
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              child: Row(
                                children: [
                                  _grupoChip(ej.grupoMuscular),
                                  const SizedBox(width: 8),
                                  Expanded(
                                      child: Text(ej.nombre,
                                          style:
                                          theme.textTheme.bodyMedium)),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _seriesCtrl,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            hintText: 'Series',
                            hintStyle: theme.textTheme.bodyMedium
                                ?.copyWith(color: AppColors.textMuted),
                            filled: true,
                            fillColor: AppColors.surfaceLight,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: AppColors.primary, width: 1.5)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _repsCtrl,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            hintText: 'Reps',
                            hintStyle: theme.textTheme.bodyMedium
                                ?.copyWith(color: AppColors.textMuted),
                            filled: true,
                            fillColor: AppColors.surfaceLight,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: AppColors.primary, width: 1.5)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            side: const BorderSide(
                                color: AppColors.surfaceLight),
                            padding: const EdgeInsets.symmetric(
                                vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: Text('Cancelar',
                              style: theme.textTheme.bodyMedium),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: OutlinedButton(
                          style: AppTheme.primaryButtonStyle,
                          onPressed: () {
                            if (_nombreCtrl.text.isNotEmpty) {
                              widget.onAnadir(ExerciseModel(
                                nombre: _nombreCtrl.text,
                                series: int.tryParse(_seriesCtrl.text) ?? 0,
                                repeticiones: int.tryParse(_repsCtrl.text) ?? 0,
                              ));
                              Navigator.pop(context);
                            }
                          },
                          child: Text('Añadir',
                              style: theme.textTheme.labelLarge?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _grupoChip(String grupo) {
    final config = _cfg(grupo);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: config.$1.withOpacity(0.15),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: config.$1.withOpacity(0.35)),
      ),
      child: Text(config.$2,
          style: TextStyle(
              color: config.$1, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }

  (Color, String) _cfg(String g) => switch (g) {
    'pecho' => (const Color(0xFF4FC3F7), 'PECHO'),
    'espalda' => (const Color(0xFF81C784), 'ESPALDA'),
    'piernas' => (const Color(0xFFFFB74D), 'PIERNAS'),
    'hombros' => (const Color(0xFFCE93D8), 'HOMBROS'),
    'brazos' => (const Color(0xFFFF8A65), 'BRAZOS'),
    'core' => (const Color(0xFFF06292), 'CORE'),
    'cardio' => (const Color(0xFF4DB6AC), 'CARDIO'),
    'gluteos' => (const Color(0xFFDCE775), 'GLÚTEOS'),
    'gemelos' => (const Color(0xFFFFD54F), 'GEMELOS'),
    _ => (AppColors.textMuted, g.toUpperCase()),
  };
}

class _AddDescansoInlineSheet extends StatefulWidget {
  final ValueChanged<int> onAnadir;
  final int segundosIniciales;
  const _AddDescansoInlineSheet({required this.onAnadir, this.segundosIniciales = 60});

  @override
  State<_AddDescansoInlineSheet> createState() =>
      _AddDescansoInlineSheetState();
}

class _AddDescansoInlineSheetState
    extends State<_AddDescansoInlineSheet> {
  late TextEditingController _ctrl;
  late int _sel;
  final _opciones = const [30, 60, 90, 120, 180, 300];
  final _etiquetas = const ['30s', '60s', '90s', '2min', '3min', '5min'];

  @override
  void initState() {
    super.initState();
    _sel = widget.segundosIniciales;
    _ctrl = TextEditingController(
        text: widget.segundosIniciales.toString());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.textMuted.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 2.6,
                children: List.generate(
                  _opciones.length,
                      (i) => GestureDetector(
                    onTap: () => setState(() {
                      _sel = _opciones[i];
                      _ctrl.text = _opciones[i].toString();
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: _sel == _opciones[i]
                            ? AppColors.primary.withOpacity(0.12)
                            : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _sel == _opciones[i]
                              ? AppColors.primary
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(_etiquetas[i],
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: _sel == _opciones[i]
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              fontWeight: _sel == _opciones[i]
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            )),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _ctrl,
                keyboardType: TextInputType.number,
                style: theme.textTheme.bodyLarge,
                decoration: InputDecoration(
                  suffixText: 'seg',
                  suffixStyle: theme.textTheme.bodyMedium
                      ?.copyWith(color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.surfaceLight,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: AppColors.primary, width: 1.5)),
                ),
                onChanged: (v) {
                  final p = int.tryParse(v);
                  if (p != null) setState(() => _sel = p);
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(
                            color: AppColors.surfaceLight),
                        padding:
                        const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancelar',
                          style: theme.textTheme.bodyMedium),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(
                            color: AppColors.primary, width: 1.5),
                        padding:
                        const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        final seg = int.tryParse(_ctrl.text) ?? 60;
                        if (seg > 0) {
                          widget.onAnadir(seg);
                          Navigator.pop(context);
                        }
                      },
                      child: Text('Añadir descanso',
                          style: theme.textTheme.labelLarge?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}