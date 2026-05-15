// Este código es una composición basada en patrones oficiales de Flutter/Dart
// y los recursos de referencia indicados

import 'package:flutter/material.dart';
import '../models/routine_model.dart';
import '../services/routine_service.dart';

class RoutineViewModel extends ChangeNotifier {
  final RoutineService _service = RoutineService();

  List<RoutineModel> _routines = [];
  List<RoutineModel> get routines => _routines;

  List<ExerciseModel> tempExercises = [];

  bool isLoading = false;
  String? errorMessage; // ← NUEVO: null = sin error, String = hay error

  Future<void> loadRoutines(String token) async {
    isLoading = true;
    errorMessage = null; // Limpiamos error anterior al reintentar
    notifyListeners();

    try {
      _routines = await _service.getRoutines(token);
    } on RoutineServiceException catch (e) {
      errorMessage = e.message;
      _routines = []; // Estado consistente
    } catch (e) {
      errorMessage = 'Error inesperado. Inténtalo de nuevo.';
      _routines = [];
    } finally {
      isLoading = false;
      notifyListeners(); // Un solo notifyListeners al final
    }
  }

  void addExercise(ExerciseModel ex) {
    tempExercises.add(ex);
    notifyListeners();
  }

  void clearExercises() {
    tempExercises.clear();
    notifyListeners();
  }

  Future<bool> saveRoutine(String nombre, String token) async {
    if (nombre.isEmpty || tempExercises.isEmpty) {
      return false;
      }
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      try {
        final newRoutine = RoutineModel(
          nombre: nombre,
          ejercicios: tempExercises,
        );
        final success = await _service.postRoutine(newRoutine, token);
        if (success) clearExercises();
        return success;
      } on RoutineServiceException catch (e) {
        debugPrint('Error guardando rutina: ${e.message}');
        errorMessage = e.message;
        return false;
      } catch (e){
        return false;
      } finally {
        isLoading = false;
        notifyListeners();
      }
    }
  }
//}