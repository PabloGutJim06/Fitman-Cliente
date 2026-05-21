import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../models/routine_model.dart';
import '../config/api_config.dart';

class RoutineServiceException implements Exception {
  final String message;
  const RoutineServiceException(this.message);
}

class RoutineService {
  Future<bool> postRoutine(RoutineModel routine, String token) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.rutinas),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(routine.toJson()),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      }
      throw RoutineServiceException(
        'Error del servidor: ${response.statusCode}',
      );
    } on RoutineServiceException {
      rethrow;
    } catch (e) {
      throw RoutineServiceException('Sin conexión o error inesperado.');
    }
  }

  Future<List<RoutineModel>> getRoutines(String token) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.rutinas),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => RoutineModel.fromJson(item)).toList();
      }
      throw RoutineServiceException(
        'Error del servidor: ${response.statusCode}',
      );
    } on RoutineServiceException {
      rethrow;
    } catch (e) {
      throw RoutineServiceException('Sin conexión. Comprueba tu red.');
    }
  }

  Future<bool> patchRoutine(String id, RoutineModel routine, String token) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConfig.rutinas}/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(routine.toJson()),
      );
      return response.statusCode == 200;
    } on RoutineServiceException {
      rethrow;
    } catch (e) {
      throw RoutineServiceException('Error al actualizar la rutina.');
    }
  }

  Future<bool> deleteRoutine(String id, String token) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.rutinas}/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );
      return response.statusCode == 200;
    } on RoutineServiceException {
      rethrow;
    } catch (e) {
      throw RoutineServiceException('Error al eliminar la rutina.');
    }
  }
  Future<bool> addColaborador(
      String rutinaId, String email, String token) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.rutinas}/$rutinaId/colaboradores'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 201) return true;

      final body = jsonDecode(response.body);
      throw RoutineServiceException(
          body['error'] ?? 'Error al añadir colaborador');
    } on RoutineServiceException {
      rethrow;
    } catch (e) {
      if (e is RoutineServiceException) rethrow;
      throw RoutineServiceException('Error de conexión.');
    }
  }

  Future<bool> removeColaborador(
      String rutinaId, String colaboradorId, String token) async {
    try {
      final response = await http.delete(
        Uri.parse(
            '${ApiConfig.rutinas}/$rutinaId/colaboradores/$colaboradorId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      return response.statusCode == 200;
    } on RoutineServiceException {
      rethrow;
    } catch (e) {
      throw RoutineServiceException('Error al eliminar colaborador.');
    }
  }
}