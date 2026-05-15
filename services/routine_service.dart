// Este código es una composición basada en patrones oficiales de Flutter/Dart
// y los recursos de referencia indicados

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../models/routine_model.dart';
import '../config/api_config.dart';

// Excepción tipada: sabemos QUÉ falló, no solo que algo falló
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
      rethrow; // Dejamos pasar las nuestras
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
}