import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/ejercicio_global_model.dart';
import '../../models/routine_model.dart';
import '../../viewmodels/routine_viewmodel.dart';
import '../../viewmodels/login_viewmodel.dart';
import '../../viewmodels/ejercicio_viewmodel.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

class CreateRoutineScreen extends StatefulWidget {
  const CreateRoutineScreen({super.key});

  @override
  State<CreateRoutineScreen> createState() => _CreateRoutineScreenState();
}

class _CreateRoutineScreenState extends State<CreateRoutineScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showAddExerciseDialog() {
    final routineVM = context.read<RoutineViewModel>();
    final ejercicioVM = context.read<EjercicioViewModel>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _AddExerciseSheet(
        routineVM: routineVM,
        ejercicioVM: ejercicioVM,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos el token del LoginViewModel
    final token = context.read<LoginViewModel>().user?.token ?? "";
    final routineVM = context.watch<RoutineViewModel>();

    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () {
            context.read<RoutineViewModel>().clearExercises();
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.surfaceLight, AppColors.background],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("NUEVA RUTINA",
                    style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),

                // Nombre de la Rutina
                TextField(
                  controller: _nameController,
                  style: theme.textTheme.bodyLarge,
                  decoration: InputDecoration(
                    hintText: "Ej: Empuje - Lunes",
                    hintStyle: theme.textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.surfaceLight.withOpacity(0.5),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),

                const SizedBox(height: 25),

                // Cabecera de Lista
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Ejercicios", style: theme.textTheme.titleMedium),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.timer_outlined,
                              color: AppColors.textSecondary, size: 28),
                          tooltip: 'Añadir descanso',
                          onPressed: _showAddDescansoDialog,
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle,
                              color: AppColors.primary, size: 30),
                          tooltip: 'Añadir ejercicio',
                          onPressed: _showAddExerciseDialog,
                        ),
                      ],
                    ),
                  ],
                ),

                Expanded(
                  child: routineVM.tempExercises.isEmpty
                      ? Center(child: Text("No hay ejercicios aún", style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)))
                      : ListView.builder(
                    itemCount: routineVM.tempExercises.length,
                    itemBuilder: (context, index) {
                      final ex = routineVM.tempExercises[index];
                      final bool esDescanso = ex.isDescanso;
                      return Card(
                        color: AppColors.surfaceLight.withOpacity(0.5),
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        child: ListTile(
                          leading: Icon(
                            esDescanso ? Icons.timer_outlined : Icons.fitness_center,
                            color: esDescanso
                                ? AppColors.textSecondary
                                : AppColors.primary,
                          ),
                          title: Text(ex.nombre,
                              style: theme.textTheme.bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            esDescanso
                                ? "${ex.duracion}s de descanso"
                                : "${ex.series} series x ${ex.repeticiones} reps",
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // BOTÓN DE GUARDAR
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: AppTheme.primaryButtonStyle,
                    onPressed: routineVM.isLoading ? null : () async {
                      bool success = await routineVM.saveRoutine(_nameController.text, token);
                      if (success && mounted) {
                        await routineVM.loadRoutines(token);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("¡Rutina guardada en el servidor!"))
                        );
                        _nameController.clear();
                      }
                    },
                    child: routineVM.isLoading
                        ? const CircularProgressIndicator(color: AppColors.textPrimary)
                        : Text("GUARDAR RUTINA", style: theme.textTheme.labelLarge?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  void _showAddDescansoDialog() {
    final routineVM = context.read<RoutineViewModel>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _AddDescansoSheet(routineVM: routineVM),
    );
  }
}

class _AddExerciseSheet extends StatefulWidget {
  final RoutineViewModel routineVM;
  final EjercicioViewModel ejercicioVM;

  const _AddExerciseSheet({
    required this.routineVM,
    required this.ejercicioVM,
  });

  @override
  State<_AddExerciseSheet> createState() => _AddExerciseSheetState();
}

class _AddExerciseSheetState extends State<_AddExerciseSheet> {
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
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
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
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.textMuted.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Cabecera
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
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

                  // Label nombre
                  _buildLabel('NOMBRE', theme),
                  const SizedBox(height: 6),

                  // Campo nombre
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
                          ? IconButton(
                        icon: const Icon(Icons.info_outline,
                            color: AppColors.primary),
                        onPressed: () =>
                            _mostrarInfo(context, coincide, theme),
                      )
                          : null,
                    ),
                    onChanged: (v) {
                      widget.ejercicioVM.buscar(v);
                      setState(() {});
                    },
                  ),

                  // Sugerencias
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
                          final isLast = ej == sugerencias.last;
                          return InkWell(
                            onTap: () {
                              _nombreCtrl.text = ej.nombre;
                              widget.ejercicioVM.limpiarSugerencias();
                              setState(() {});
                              FocusScope.of(context)
                                  .requestFocus(_nombreFocus);
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 9),
                              decoration: BoxDecoration(
                                border: isLast
                                    ? null
                                    : const Border(
                                    bottom: BorderSide(
                                        color: AppColors.surface,
                                        width: 1)),
                              ),
                              child: Row(
                                children: [
                                  _buildGrupoChip(ej.grupoMuscular),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(ej.nombre,
                                        style: theme.textTheme.bodyMedium,
                                        overflow: TextOverflow.ellipsis),
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
                  Divider(color: AppColors.textMuted.withOpacity(0.15)),
                  const SizedBox(height: 12),

                  // Series y Reps
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('SERIES', theme),
                            const SizedBox(height: 6),
                            _buildNumericField(_seriesCtrl, '4', theme),
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
                            _buildNumericField(_repsCtrl, '10', theme),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Botones
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
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.background,
                            padding:
                            const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            if (_nombreCtrl.text.isNotEmpty) {
                              widget.routineVM.addExercise(
                                ExerciseModel(
                                  nombre: _nombreCtrl.text,
                                  series: int.tryParse(_seriesCtrl.text) ?? 0,
                                  repeticiones:
                                  int.tryParse(_repsCtrl.text) ?? 0,
                                  descripcion:
                                  '${_seriesCtrl.text}x${_repsCtrl.text}',
                                ),
                              );
                              Navigator.pop(context);
                            }
                          },
                          child: Text('Añadir',
                              style: theme.textTheme.labelLarge
                                  ?.copyWith(fontWeight: FontWeight.bold)),
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

  void _mostrarInfo(BuildContext context, EjercicioGlobalModel ej,
      ThemeData theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textMuted.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _buildGrupoChip(ej.grupoMuscular),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(ej.nombre,
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            if (ej.nivelDificultad != null) ...[
              const SizedBox(height: 6),
              Text(
                _capitalizarPrimera(ej.nivelDificultad!),
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: AppColors.textMuted),
              ),
            ],
            const SizedBox(height: 16),
            Text(ej.descripcion, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, ThemeData theme) => Text(
    text,
    style: theme.textTheme.bodyMedium?.copyWith(
      color: AppColors.textMuted,
      fontSize: 10,
      letterSpacing: 1.1,
      fontWeight: FontWeight.bold,
    ),
  );

  Widget _buildNumericField(
      TextEditingController ctrl, String hint, ThemeData theme) {
    return TextField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      style: theme.textTheme.bodyLarge
          ?.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: theme.textTheme.bodyLarge?.copyWith(
            color: AppColors.textMuted,
            fontSize: 18,
            fontWeight: FontWeight.bold),
        filled: true,
        fillColor: AppColors.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
          const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildGrupoChip(String grupo) {
    final config = _grupoConfig(grupo);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: config.$1.withOpacity(0.15),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: config.$1.withOpacity(0.35), width: 1),
      ),
      child: Text(config.$2,
          style: TextStyle(
              color: config.$1,
              fontSize: 9,
              fontWeight: FontWeight.bold)),
    );
  }

  (Color, String) _grupoConfig(String grupo) => switch (grupo) {
    'pecho' => (const Color(0xFF4FC3F7), 'PECHO'),
    'espalda' => (const Color(0xFF81C784), 'ESPALDA'),
    'piernas' => (const Color(0xFFFFB74D), 'PIERNAS'),
    'hombros' => (const Color(0xFFCE93D8), 'HOMBROS'),
    'brazos' => (const Color(0xFFFF8A65), 'BRAZOS'),
    'core' => (const Color(0xFFF06292), 'CORE'),
    'cardio' => (const Color(0xFF4DB6AC), 'CARDIO'),
    'gluteos' => (const Color(0xFFDCE775), 'GLÚTEOS'),
    'gemelos' => (const Color(0xFFFFD54F), 'GEMELOS'),
    _ => (AppColors.textMuted, grupo.toUpperCase()),
  };

  String _capitalizarPrimera(String t) =>
      t.isEmpty ? t : t[0].toUpperCase() + t.substring(1);
}

class _AddDescansoSheet extends StatefulWidget {
  final RoutineViewModel routineVM;
  const _AddDescansoSheet({required this.routineVM});

  @override
  State<_AddDescansoSheet> createState() => _AddDescansoSheetState();
}

class _AddDescansoSheetState extends State<_AddDescansoSheet> {
  final _ctrl = TextEditingController();
  int _segundosSeleccionados = 60;

  final _opciones = const [30, 60, 90, 120, 180, 300];
  final _etiquetas = const ['30s', '60s', '90s', '2 min', '3 min', '5 min'];

  @override
  void initState() {
    super.initState();
    _ctrl.text = '60';
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _seleccionarOpcion(int segundos) {
    setState(() {
      _segundosSeleccionados = segundos;
      _ctrl.text = segundos.toString();
    });
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
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
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

              // Cabecera
              Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.timer_outlined,
                        color: AppColors.textSecondary, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Text('Tiempo de descanso',
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 20),

              // Botones rápidos
              Text(
                'SELECCIÓN RÁPIDA',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 10,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 2.6,
                children: List.generate(_opciones.length, (i) {
                  final sel = _opciones[i] == _segundosSeleccionados;
                  return GestureDetector(
                    onTap: () => _seleccionarOpcion(_opciones[i]),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: sel
                            ? AppColors.primary.withOpacity(0.12)
                            : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: sel
                              ? AppColors.primary
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _etiquetas[i],
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: sel
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            fontWeight: sel
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),

              // Campo manual
              Text(
                'O INTRODUCE LOS SEGUNDOS',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 10,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
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
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: AppColors.primary, width: 1.5),
                  ),
                ),
                onChanged: (v) {
                  final parsed = int.tryParse(v);
                  if (parsed != null) {
                    setState(() => _segundosSeleccionados = parsed);
                  }
                },
              ),
              const SizedBox(height: 24),

              // Botones
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: AppColors.surfaceLight),
                        padding: const EdgeInsets.symmetric(vertical: 14),
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
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        final seg = int.tryParse(_ctrl.text) ?? 60;
                        if (seg > 0) {
                          widget.routineVM.addExercise(
                            ExerciseModel(
                              nombre: 'Descanso',
                              duracion: seg,
                            ),
                          );
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