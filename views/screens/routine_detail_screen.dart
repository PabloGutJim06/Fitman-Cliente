import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/routine_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../viewmodels/routine_viewmodel.dart';
import 'routine_player_screen.dart';
import 'edit_routine_screen.dart';
import 'colaboradores_screen.dart';
import '../../viewmodels/ejercicio_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/connectivity_service.dart';

class RoutineDetailScreen extends StatelessWidget {
  final RoutineModel routine;

  const RoutineDetailScreen({super.key, required this.routine});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rutinaActual = context
        .watch<RoutineViewModel>()
        .routines
        .firstWhere(
          (r) => r.id == routine.id,
      orElse: () => routine,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(rutinaActual.nombre, style: theme.textTheme.titleLarge),
        backgroundColor: AppColors.surface,
        iconTheme: const IconThemeData(color: AppColors.primary),
        actions: [
          if (rutinaActual.tienePermisoEdicion)
            FutureBuilder<bool>(
              future: ConnectivityService().tieneConexion(),
              builder: (context, snap) {
                final online = snap.data ?? true;
                return IconButton(
                  icon: Icon(Icons.edit_outlined,
                      color: online
                          ? AppColors.primary
                          : AppColors.textMuted),
                  onPressed: online
                      ? () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          EditRoutineScreen(routine: rutinaActual),
                    ),
                  )
                      : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Necesitas conexión para editar'),
                        backgroundColor: AppColors.surfaceLight,
                      ),
                    );
                  },
                );
              },
            ),
          if (rutinaActual.esCreador)
            FutureBuilder<bool>(
              future: ConnectivityService().tieneConexion(),
              builder: (context, snap) {
                final online = snap.data ?? true;
                return IconButton(
                  icon: Icon(Icons.group_outlined,
                      color: online
                          ? AppColors.primary
                          : AppColors.textMuted),
                  onPressed: online
                      ? () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ColaboradoresScreen(routine: rutinaActual),
                    ),
                  )
                      : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Necesitas conexión para gestionar colaboradores'),
                        backgroundColor: AppColors.surfaceLight,
                      ),
                    );
                  },
                );
              },
            ),
        ],
      ),
      body: _RoutineDetailBody(rutina: rutinaActual),
    );
  }
}

class _RoutineDetailBody extends StatefulWidget {
  final RoutineModel rutina;

  const _RoutineDetailBody({required this.rutina});

  @override
  State<_RoutineDetailBody> createState() => _RoutineDetailBodyState();
}

class _RoutineDetailBodyState extends State<_RoutineDetailBody> {
  bool? _mostrarBanner;

  @override
  void initState() {
    super.initState();
    if (!widget.rutina.esCreador && !widget.rutina.puedeEditar) {
      _checkBanner();
    }
  }

  Future<void> _checkBanner() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'rutina_vista_${widget.rutina.id}';
    final yaVisto = prefs.getBool(key) ?? false;

    if (!mounted) return;

    if (!yaVisto) {
      await prefs.setBool(key, true);
      setState(() => _mostrarBanner = true);
    } else {
      setState(() => _mostrarBanner = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rutina = widget.rutina;
    final esSoloLectura =
        !rutina.esCreador && !rutina.puedeEditar;
    final mostrar = _mostrarBanner ?? false;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.background, AppColors.surface],
        ),
      ),
      child: Column(
        children: [
          if (!rutina.esCreador)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppColors.textMuted.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.group_outlined,
                          color: AppColors.textMuted, size: 13),
                      const SizedBox(width: 5),
                      Text(
                        'Compartida contigo',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          if (esSoloLectura && mostrar)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppColors.textMuted.withOpacity(0.25)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_outline,
                        color: AppColors.textMuted, size: 16),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Solo puedes ver y usar esta rutina',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _mostrarBanner = false),
                      child: const Icon(Icons.close,
                          color: AppColors.textMuted, size: 16),
                    ),
                  ],
                ),
              ),
            ),

          // Lista de ejercicios
          Expanded(
            child: rutina.ejercicios.isEmpty
                ? Center(
              child: Text(
                'Esta rutina no tiene ejercicios todavía.',
                style: theme.textTheme.bodyLarge
                    ?.copyWith(color: AppColors.textSecondary),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: rutina.ejercicios.length,
              itemBuilder: (context, index) => _buildExerciseCard(
                  rutina.ejercicios[index], theme),
            ),
          ),

          // Botón iniciar — siempre disponible
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton.icon(
                style: AppTheme.primaryButtonStyle,
                onPressed: rutina.ejercicios.isEmpty
                    ? null
                    : () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        RoutinePlayerScreen(routine: rutina),
                  ),
                ),
                icon: const Icon(Icons.play_arrow_rounded,
                    color: AppColors.primary),
                label: Text(
                  'INICIAR ENTRENAMIENTO',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(ExerciseModel ex, ThemeData theme) {
    final esDescanso = ex.isDescanso;

    return Card(
      color: AppColors.surfaceLight,
      margin: const EdgeInsets.only(bottom: 12),
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: esDescanso
              ? AppColors.textSecondary.withOpacity(0.15)
              : AppColors.primary,
          child: Icon(
            esDescanso ? Icons.timer_outlined : Icons.fitness_center,
            color: esDescanso ? AppColors.textSecondary : Colors.black,
          ),
        ),
        title: Text(
          ex.nombre,
          style: theme.textTheme.bodyLarge?.copyWith(
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
          style:
          theme.textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
        ),
        trailing: (!esDescanso && (ex.descripcion.isNotEmpty ||
            context.read<EjercicioViewModel>().buscarPorNombre(ex.nombre) != null))
            ? Builder(
          builder: (tileContext) => IconButton(
            icon: const Icon(Icons.info_outline,
                color: AppColors.primary),
            onPressed: () =>
                _mostrarInfoEjercicio(tileContext, ex, theme),
          ),
        )
            : null,
      ),
    );
  }

  void _mostrarInfoEjercicio(BuildContext context, ExerciseModel ex, ThemeData theme) {
    final ejercicioVM = context.read<EjercicioViewModel>();
    final globalMatch = ejercicioVM.buscarPorNombre(ex.nombre);
    final descripcion = globalMatch?.descripcion ?? ex.descripcion;
    final grupoMuscular = globalMatch?.grupoMuscular;
    final nivel = globalMatch?.nivelDificultad;

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
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.textMuted.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Cabecera con grupo muscular si existe
            Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.fitness_center,
                      color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ex.nombre,
                          style: theme.textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      if (nivel != null)
                        Text(
                          _capitalizarPrimera(nivel),
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textMuted),
                        ),
                    ],
                  ),
                ),
                if (grupoMuscular != null)
                  _buildGrupoChip(grupoMuscular, theme),
              ],
            ),
            const SizedBox(height: 16),
            // Series y reps
            Row(
              children: [
                _buildInfoChip('${ex.series} series', Icons.repeat, theme),
                const SizedBox(width: 8),
                _buildInfoChip(
                    '${ex.repeticiones} reps', Icons.fitness_center, theme),
              ],
            ),
            if (descripcion.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(descripcion, style: theme.textTheme.bodyLarge),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildGrupoChip(String grupo, ThemeData theme) {
    final config = _grupoConfig(grupo);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: config.$1.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: config.$1.withOpacity(0.35)),
      ),
      child: Text(config.$2,
          style: TextStyle(
              color: config.$1,
              fontSize: 10,
              fontWeight: FontWeight.bold)),
    );
  }

  (Color, String) _grupoConfig(String g) => switch (g) {
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

  String _capitalizarPrimera(String t) =>
      t.isEmpty ? t : t[0].toUpperCase() + t.substring(1);

  Widget _buildInfoChip(String label, IconData icon, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}