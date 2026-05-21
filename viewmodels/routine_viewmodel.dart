import 'package:flutter/material.dart';
import '../models/routine_model.dart';
import '../services/routine_service.dart';
import '../services/hive_service.dart';
import '../services/connectivity_service.dart';

class RoutineViewModel extends ChangeNotifier {
  final RoutineService _service = RoutineService();
  final HiveService _hive = HiveService();
  final ConnectivityService _connectivity = ConnectivityService();

  List<RoutineModel> _routines = [];
  List<RoutineModel> get routines => _routines;

  List<ExerciseModel> tempExercises = [];

  bool isLoading = false;
  String? errorMessage;

  Future<void> loadRoutines(String token) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final hayRed = await _connectivity.tieneConexion();

    if (hayRed) {
      try {
        _routines = await _service.getRoutines(token);
        await _hive.guardarRutinas(_routines);
      } on RoutineServiceException catch (e) {
        errorMessage = e.message;
        final cached = _hive.cargarRutinas();
        if (cached.isNotEmpty) {
          _routines = cached;
          errorMessage = null;
        } else {
          _routines = [];
        }
      } catch (e) {
        errorMessage = 'Error inesperado. Inténtalo de nuevo.';
        _routines = [];
      }
    } else {
      final cached = _hive.cargarRutinas();
      _routines = cached;
      debugPrint('RoutineViewModel: cargando ${cached.length} rutinas de caché');
    }

    isLoading = false;
    notifyListeners();
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

  Future<bool> updateRoutine(RoutineModel rutina, String token) async {
    try {
      final success = await _service.patchRoutine(
        rutina.id ?? '',
        rutina,
        token,
      );
      if (success) {
        final index = _routines.indexWhere((r) => r.id == rutina.id);
        if (index != -1) {
          _routines[index] = rutina;
          notifyListeners();
        }
      }
      return success;
    } on RoutineServiceException catch (e) {
      debugPrint('Error actualizando rutina: ${e.message}');
      errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteRoutine(String id, String token) async {
    try {
      final success = await _service.deleteRoutine(id, token);
      if (success) {
        _routines = _routines.where((r) => r.id != id).toList();
        notifyListeners();
      }
      return success;
    } on RoutineServiceException catch (e) {
      debugPrint('Error eliminando rutina: ${e.message}');
      errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }
  Future<String?> addColaborador(
      String rutinaId, String email, String token) async {
    try {
      await _service.addColaborador(rutinaId, email, token);

      await loadRoutines(token);
      return null;
    } on RoutineServiceException catch (e) {
      return e.message;
    }
  }

// Quitar colaborador
  Future<bool> removeColaborador(
      String rutinaId, String colaboradorId, String token) async {
    try {
      final success =
      await _service.removeColaborador(rutinaId, colaboradorId, token);
      if (success) await loadRoutines(token);
      return success;
    } on RoutineServiceException catch (e) {
      debugPrint('Error eliminando colaborador: ${e.message}');
      return false;
    }
  }
}
//}