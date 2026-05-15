// services/user_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../config/api_config.dart';

class UserService {

  /// Dispara al endpoint /usuarios/me para traer los datos del perfil
  Future<UserModel> fetchMe(String token) async {
    final url = Uri.parse(ApiConfig.userMe);

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        // 🎯 AJUSTE DE PRECISIÓN:
        // Si el JSON es { "usuario": { "nombre": "...", ... } },
        // usamos data['usuario']. Si viene directo, usamos data.
        final userData = data.containsKey('usuario') ? data['usuario'] : data;

        return UserModel.fromJson(userData, token);
      } else if (response.statusCode == 401) {
        throw Exception("No autorizado. El token ha perdido su poder.");
      } else {
        throw Exception("El servidor repelió el ataque: Código ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error de conexión en el Grand Line: $e");
    }
  }
}