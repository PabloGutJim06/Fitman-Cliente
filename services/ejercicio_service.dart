import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/ejercicio_global_model.dart';

class EjercicioService {
  Future<List<EjercicioGlobalModel>> fetchEjercicios() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.ejercicios),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((json) => EjercicioGlobalModel.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error cargando ejercicios globales: $e');
      return [];
    }
  }
}