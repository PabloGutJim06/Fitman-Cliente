import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/routine_model.dart';
import '../../services/auth_service.dart';
import '../../viewmodels/routine_viewmodel.dart';
import '../../theme/app_colors.dart';
import 'create_routine_screen.dart';
import 'routine_detail_screen.dart';
import 'edit_routine_screen.dart';
import 'dart:async';
import '../../services/connectivity_service.dart';
import '../../services/sync_service.dart';

class MyRoutinesScreen extends StatefulWidget {
  const MyRoutinesScreen({super.key});

  @override
  State<MyRoutinesScreen> createState() => _MyRoutinesScreenState();
}

class _MyRoutinesScreenState extends State<MyRoutinesScreen> {
  final ConnectivityService _connectivity = ConnectivityService();
  bool _isOnline = true;
  StreamSubscription<bool>? _sub;

  @override
  void initState() {
    super.initState();
    _connectivity.tieneConexion().then((v) {
      if (mounted) setState(() => _isOnline = v);
    });
    _sub = _connectivity.onConnectivityChanged.listen((online) {
      if (mounted) setState(() => _isOnline = online);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RoutineViewModel>(
      builder: (context, routineVM, child) {
        return Scaffold(
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
                    Text(
                      "Mis Rutinas",
                      style: Theme.of(context)
                          .textTheme
                          .displayLarge
                          ?.copyWith(fontSize: 28),
                    ),
                    const SizedBox(height: 8),
                    if (!_isOnline) _buildOfflineBanner(context),

                    const SizedBox(height: 12),
                    Expanded(child: _buildBody(routineVM, context)),
                  ],
                ),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: _isOnline
                ? AppColors.primary
                : AppColors.textMuted.withOpacity(0.3),
            foregroundColor: AppColors.background,
            onPressed: _isOnline
                ? () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const CreateRoutineScreen()),
            )
                : () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Necesitas conexión para crear rutinas'),
                  backgroundColor: AppColors.surfaceLight,
                ),
              );
            },
            child: const Icon(Icons.add, size: 30),
          ),
        );
      },
    );
  }

  Widget _buildOfflineBanner(BuildContext context) {
    final theme = Theme.of(context);
    final pendientes = SyncService().totalPendientes;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: AppColors.textMuted.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off_rounded,
              color: AppColors.textMuted, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sin conexión',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Text(
                  pendientes > 0
                      ? '$pendientes ${pendientes == 1 ? 'entrenamiento pendiente' : 'entrenamientos pendientes'} de sincronizar'
                      : 'Mostrando rutinas guardadas',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(RoutineViewModel routineVM, BuildContext context) {
    if (routineVM.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (routineVM.errorMessage != null) {
      return _buildErrorState(routineVM.errorMessage!, context);
    }
    if (routineVM.routines.isEmpty) {
      return _buildEmptyState(context);
    }
    return ListView.builder(
      itemCount: routineVM.routines.length,
      itemBuilder: (context, index) =>
          _buildRoutineItem(routineVM.routines[index], context),
    );
  }

  Widget _buildErrorState(String message, BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, size: 60, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text("Reintentar"),
            onPressed: () async {
              final token = await AuthService().getStoredToken();
              if (token != null && context.mounted) {
                context.read<RoutineViewModel>().loadRoutines(token);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.fitness_center,
              size: 80, color: AppColors.textSecondary),
          const SizedBox(height: 20),
          Text("Aún no tienes rutinas",
              style: Theme.of(context).textTheme.displayLarge),
          const SizedBox(height: 10),
          Text(
            "¡Empieza a entrenar hoy mismo!",
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutineItem(RoutineModel routine, BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: ValueKey(routine.id),
      direction: DismissDirection.endToStart,

      background: Container(
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(15),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, color: Colors.white, size: 28),
            SizedBox(height: 4),
            Text(
              'Borrar',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),

      confirmDismiss: (_) async {
        return await _mostrarConfirmacionBorrar(context, routine.nombre);
      },

      onDismissed: (_) async {
        final token = await AuthService().getStoredToken() ?? '';
        final success = await context
            .read<RoutineViewModel>()
            .deleteRoutine(routine.id ?? '', token);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                success
                    ? '${routine.nombre} eliminada'
                    : 'Error al eliminar la rutina',
              ),
              backgroundColor:
              success ? AppColors.surface : AppColors.error,
            ),
          );
        }
      },

      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RoutineDetailScreen(routine: routine),
          ),
        ),
        onLongPress: () => _mostrarMenuLongPress(context, routine),
        child: Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
                color: AppColors.primary.withOpacity(0.3), width: 1),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.fitness_center,
                  color: AppColors.primary, size: 40),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      routine.nombre,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${routine.ejercicios.length} ejercicios',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  color: AppColors.textSecondary, size: 18),
            ],
          ),
        ),
      ),
    );
  }
  Future<bool> _mostrarConfirmacionBorrar(
      BuildContext context, String nombre) async {
    final theme = Theme.of(context);
    final resultado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surfaceLight,
        title: Text('¿Borrar rutina?', style: theme.textTheme.titleLarge),
        content: Text(
          '¿Seguro que quieres eliminar "$nombre"? Esta acción no se puede deshacer.',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('CANCELAR',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('BORRAR',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
    return resultado ?? false;
  }

  void _mostrarMenuLongPress(BuildContext context, RoutineModel routine) {
    final theme = Theme.of(context);

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
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.textMuted.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Nombre de la rutina como título
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                child: Text(
                  routine.nombre,
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(color: AppColors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const Divider(color: AppColors.surface, height: 16),

              ListTile(
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.edit_outlined,
                      color: AppColors.primary, size: 22),
                ),
                title: Text('Editar rutina',
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                subtitle: Text('Próximamente',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: AppColors.textMuted)),
                trailing: const Icon(Icons.arrow_forward_ios_rounded,
                    color: AppColors.textMuted, size: 14),
                onTap: () {
                  Navigator.pop(sheetContext);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditRoutineScreen(routine: routine),
                    ),
                  );
                },
              ),

              // Opción borrar
              ListTile(
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.delete_outline,
                      color: AppColors.error, size: 22),
                ),
                title: Text('Borrar rutina',
                    style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.error)),
                trailing: const Icon(Icons.arrow_forward_ios_rounded,
                    color: AppColors.textMuted, size: 14),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  final confirmar = await _mostrarConfirmacionBorrar(
                      context, routine.nombre);
                  if (confirmar && context.mounted) {
                    final token =
                        await AuthService().getStoredToken() ?? '';
                    final success = await context
                        .read<RoutineViewModel>()
                        .deleteRoutine(routine.id ?? '', token);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? '${routine.nombre} eliminada'
                                : 'Error al eliminar la rutina',
                          ),
                          backgroundColor: success
                              ? AppColors.surface
                              : AppColors.error,
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}