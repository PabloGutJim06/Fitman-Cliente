import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/routine_model.dart';
import '../../viewmodels/routine_viewmodel.dart';
import '../../viewmodels/login_viewmodel.dart';
// ¡IMPACTO! Aquí traemos nuestras balas de pintura:
import '../../theme/app_colors.dart';

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

  // --- HISSATSU: DIÁLOGO PARA AÑADIR EJERCICIO ---
  void _showAddExerciseDialog() {
    final nombreExController = TextEditingController();
    final seriesController = TextEditingController();
    final repsController = TextEditingController();
    final theme = Theme.of(context);
    // ✅ Capturamos ANTES
    final routineVM = context.read<RoutineViewModel>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surfaceLight,
        title: Text("Añadir Ejercicio", style: theme.textTheme.titleLarge),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogField(nombreExController, "Nombre (ej: Press Banca)"),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _buildDialogField(seriesController, "Series", isNumber: true)),
                const SizedBox(width: 10),
                Expanded(child: _buildDialogField(repsController, "Reps", isNumber: true)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text("Cancelar",
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              if (nombreExController.text.isNotEmpty) {
                // ✅ VM capturado antes del diálogo
                routineVM.addExercise(
                  ExerciseModel(
                    nombre: nombreExController.text,
                    series: int.tryParse(seriesController.text) ?? 0,
                    repeticiones: int.tryParse(repsController.text) ?? 0,
                    descripcion: "${seriesController.text}x${repsController.text}",
                  ),
                );
                Navigator.pop(dialogContext);
              }
            },
            child: Text("Añadir",
                style: theme.textTheme.labelLarge
                    ?.copyWith(color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos el token del LoginViewModel (¡esencial para el servidor!)
    final token = context.read<LoginViewModel>().user?.token ?? "";
    final routineVM = context.watch<RoutineViewModel>();

    // Capturamos el textTheme de nuestro AppTheme
    final theme = Theme.of(context);

    return Scaffold(
      // --- HISSATSU: BOTÓN DE ESCAPE ---
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
            // Reemplazamos los grises fijos por colores de nuestra paleta
            colors: [AppColors.surfaceLight, AppColors.background],
          ),
        ),
        child: SafeArea(
          // ¡HISSATSU: CAMBIO RÁPIDO! Cambiamos SingleChildScrollView por Padding
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
                    // ✅ Dos botones — ejercicio y descanso
                    Row(
                      children: [
                        // Botón descanso — icono de reloj
                        IconButton(
                          icon: const Icon(Icons.timer_outlined,
                              color: AppColors.textSecondary, size: 28),
                          tooltip: 'Añadir descanso',
                          onPressed: _showAddDescansoDialog,
                        ),
                        // Botón ejercicio — igual que antes
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

                // LISTA DE EJERCICIOS AÑADIDOS
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary, // Antes Color(0xFF388E3C)
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
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
                        : Text("GUARDAR RUTINA", style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para los campos del diálogo
  Widget _buildDialogField(TextEditingController controller, String label, {bool isNumber = false}) {
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.textSecondary)),
      ),
    );
  }

  void _showAddDescansoDialog() {
    final segundosController = TextEditingController(text: '60');
    final theme = Theme.of(context);
    // ✅ Capturamos el VM ANTES de abrir el diálogo
    final routineVM = context.read<RoutineViewModel>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(  // ← renombramos a dialogContext
        backgroundColor: AppColors.surfaceLight,
        title: Text("Añadir descanso", style: theme.textTheme.titleLarge),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.timer_outlined,
                color: AppColors.textSecondary, size: 40),
            const SizedBox(height: 12),
            _buildDialogField(
              segundosController,
              "Duración en segundos (ej: 60)",
              isNumber: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text("Cancelar",
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textSecondary),
            onPressed: () {
              final segundos = int.tryParse(segundosController.text) ?? 60;
              if (segundos > 0) {
                // ✅ Usamos el VM capturado antes, no el del dialogContext
                routineVM.addExercise(
                  ExerciseModel(
                    nombre: 'Descanso',
                    duracion: segundos,
                  ),
                );
                Navigator.pop(dialogContext);
              }
            },
            child: Text("Añadir",
                style: theme.textTheme.labelLarge
                    ?.copyWith(color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }
}