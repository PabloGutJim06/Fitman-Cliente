import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/routine_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../viewmodels/registro_viewmodel.dart';
import '../../viewmodels/login_viewmodel.dart';

enum _PlayerEstado { ejercicio, descanso, fin }

class RoutinePlayerScreen extends StatefulWidget {
  final RoutineModel routine;

  const RoutinePlayerScreen({super.key, required this.routine});

  @override
  State<RoutinePlayerScreen> createState() => _RoutinePlayerScreenState();
}

class _RoutinePlayerScreenState extends State<RoutinePlayerScreen> {
  int _indiceActual = 0;
  _PlayerEstado _estado = _PlayerEstado.ejercicio;
  int _segundosRestantes = 0;
  Timer? _timer;

  ExerciseModel get _ejercicioActual =>
      widget.routine.ejercicios[_indiceActual];

  @override
  void initState() {
    super.initState();
    _evaluarEstadoActual();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _evaluarEstadoActual() {
    if (_indiceActual >= widget.routine.ejercicios.length) {
      _timer?.cancel();
      setState(() => _estado = _PlayerEstado.fin);
      return;
    }

    if (_ejercicioActual.isDescanso) {
      _iniciarDescanso();
    } else {
      _timer?.cancel();
      setState(() => _estado = _PlayerEstado.ejercicio);
    }
  }

  void _iniciarDescanso() {
    _timer?.cancel();
    setState(() {
      _estado = _PlayerEstado.descanso;
      _segundosRestantes = _ejercicioActual.duracion;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_segundosRestantes <= 1) {
        timer.cancel();
        _avanzar();
      } else {
        setState(() => _segundosRestantes--);
      }
    });
  }

  // Avanza al siguiente ejercicio
  void _avanzar() {
    _timer?.cancel();
    setState(() => _indiceActual++);
    _evaluarEstadoActual();
  }

  // Guardamos el registro y volvemos
  Future<void> _finalizarEntrenamiento() async {
    final token = context.read<LoginViewModel>().user?.token ?? '';
    final success = await context.read<RegistroViewModel>()
        .completarEntrenamiento(
      token,
      widget.routine.id ?? '',
      widget.routine.nombre,
      widget.routine.ejercicios
          .where((e) => !e.isDescanso)
          .length,
    );

    if (!mounted) return;
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? '¡Entrenamiento completado! 💪'
              : 'Entrenamiento completado (error al guardar el registro)',
        ),
        backgroundColor: success ? AppColors.success : AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textSecondary),
          onPressed: () => _mostrarDialogoAbandonar(context),
        ),
        // Progreso en la cabecera
        title: Text(
          '${_indiceActual + 1} / ${widget.routine.ejercicios.length}',
          style: theme.textTheme.bodyLarge
              ?.copyWith(color: AppColors.textSecondary),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: child,
          ),
          child: _buildEstadoActual(theme),
        ),
      ),
    );
  }

  // Decide qué pantalla mostrar según el estado
  Widget _buildEstadoActual(ThemeData theme) {
    switch (_estado) {
      case _PlayerEstado.ejercicio:
        return _buildPantallaEjercicio(theme);
      case _PlayerEstado.descanso:
        return _buildPantallaDescanso(theme);
      case _PlayerEstado.fin:
        return _buildPantallaFin(theme);
    }
  }

  Widget _buildPantallaEjercicio(ThemeData theme) {
    final ex = _ejercicioActual;
    final esUltimo = _indiceActual >= widget.routine.ejercicios.length - 1;

    return SizedBox.expand(
      key: ValueKey('ejercicio_$_indiceActual'),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono grande
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: const Icon(
                Icons.fitness_center,
                color: AppColors.primary,
                size: 56,
              ),
            ),
            const SizedBox(height: 40),

            // Nombre del ejercicio
            Text(
              ex.nombre,
              style: theme.textTheme.displayLarge?.copyWith(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Series x Reps
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${ex.series} series × ${ex.repeticiones} reps',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.primary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 60),

            // Botón principal
            SizedBox(
              width: double.infinity,
              height: 60,
              child: OutlinedButton(
                style: AppTheme.primaryButtonStyle,
                onPressed: _avanzar,
                child: Text(
                  esUltimo ? 'FINALIZAR' : 'SIGUIENTE',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPantallaDescanso(ThemeData theme) {
    // Porcentaje para el indicador circular
    final total = _ejercicioActual.duracion;
    final progreso = total > 0 ? _segundosRestantes / total : 0.0;

    return SizedBox.expand(
      key: ValueKey('descanso_$_indiceActual'),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'DESCANSO',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 3,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox.expand(
                    child: CircularProgressIndicator(
                      value: progreso,
                      strokeWidth: 8,
                      color: AppColors.primary,
                      backgroundColor:
                      AppColors.primary.withOpacity(0.15),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$_segundosRestantes',
                        style: theme.textTheme.displayLarge?.copyWith(
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        'segundos',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),

            // Botón saltar
            SizedBox(
              width: double.infinity,
              height: 60,
              child: OutlinedButton(
                style: AppTheme.primaryButtonStyle,
                onPressed: _avanzar,
                child: Text(
                  'SALTAR DESCANSO',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPantallaFin(ThemeData theme) {
    return SizedBox.expand(
      key: const ValueKey('fin'),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.emoji_events,
              color: AppColors.primary,
              size: 100,
            ),
            const SizedBox(height: 32),
            Text(
              '¡Rutina completada!',
              style: theme.textTheme.displayLarge?.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              widget.routine.nombre,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 60),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: OutlinedButton(
                style: AppTheme.primaryButtonStyle,
                onPressed: _finalizarEntrenamiento,
                child: Text(
                  'GUARDAR Y SALIR',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoAbandonar(BuildContext context) {
    _timer?.cancel();
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surfaceLight,
        title: Text('¿Abandonar entrenamiento?',
            style: theme.textTheme.titleLarge),
        content: Text(
          'El progreso no se guardará.',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              if (_estado == _PlayerEstado.descanso) {
                _iniciarDescanso();
              }
            },
            child: Text('CONTINUAR',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: AppColors.primary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context);
            },
            child: Text('SALIR',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}