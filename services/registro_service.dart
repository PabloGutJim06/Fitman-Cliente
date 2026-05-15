// Este código es una composición basada en patrones oficiales de Flutter/Dart
// y los recursos de referencia indicados

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/registro_model.dart';

class RegistroService {
  Map<String, String> _headers(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  Future<bool> crearRegistro(
      String token,
      String rutinaId,
      String rutinaNombre,
      int numEjercicios,
      ) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.registros),
        headers: _headers(token),
        body: jsonEncode({
          'rutina_id': rutinaId,
          'rutina_nombre': rutinaNombre,
          'num_ejercicios': numEjercicios,
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      debugPrint('Error al crear registro: $e');
      return false;
    }
  }

  Future<List<RegistroModel>> obtenerRegistros(String token) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.registros),
        headers: _headers(token),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => RegistroModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error al obtener registros: $e');
      return [];
    }
  }

  Future<Map<String, int>> obtenerResumen(String token) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.registrosResumen),
        headers: _headers(token),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'total': (data['total'] as num).toInt(),
          'este_mes': (data['este_mes'] as num).toInt(),
        };
      }
      return {'total': 0, 'este_mes': 0};
    } catch (e) {
      debugPrint('Error al obtener resumen: $e');
      return {'total': 0, 'este_mes': 0};
    }
  }
}