// Este código es una composición basada en patrones oficiales de Flutter/Dart
// y los recursos de referencia indicados

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/routine_model.dart';
import '../../services/auth_service.dart';
import '../../viewmodels/routine_viewmodel.dart';
import '../../theme/app_colors.dart';
import 'create_routine_screen.dart';
import 'routine_detail_screen.dart';

class MyRoutinesScreen extends StatelessWidget { // ← StatelessWidget: ya no necesita initState
  const MyRoutinesScreen({super.key});

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
                    const SizedBox(height: 20),
                    Expanded(child: _buildBody(routineVM, context)),
                  ],
                ),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.background,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateRoutineScreen()),
            ),
            child: const Icon(Icons.add, size: 30),
          ),
        );
      },
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
    // El botón reintentar ahora necesita el token — lo obtiene del AuthService
    // directamente porque ya no tenemos LoginViewModel aquí
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
              // Obtenemos el token directamente del AuthService
              // (fuente de verdad única para el token)
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
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RoutineDetailScreen(routine: routine),
        ),
      ),
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
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "${routine.ejercicios.length} ejercicios",
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
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
    );
  }
}