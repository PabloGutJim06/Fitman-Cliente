import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import '../config/api_config.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();

  Future<String?> getStoredToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<UserModel?> login(String email, String password) async {
    final url = Uri.parse(ApiConfig.login);

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final user = UserModel.fromJson(data['usuario'], data['token']);

        if (user.token != null) {
          await _storage.write(key: 'auth_token', value: user.token!);
        }
        return user;
      } else {
        debugPrint("Login fallido [${response.statusCode}]: ${response.body}");
        return null;
      }
    } catch (e) {
      debugPrint("Error de red en login: $e");
      return null;
    }
  }

  Future<bool> register({
    required String nombre,
    required String email,
    required String password,
    int? edad,
    double? pesoActual,
    double? altura,
    String? objetivo,
    String? nivel,
  }) async {
    final url = Uri.parse(ApiConfig.register);

    try {
      final body = <String, dynamic>{
        'nombre': nombre,
        'email': email,
        'password': password,
      };
      if (edad != null) body['edad'] = edad;
      if (altura != null) body['altura'] = altura;
      if (pesoActual != null) body['peso_actual'] = pesoActual;
      if (objetivo != null) body['objetivo'] = objetivo;
      if (nivel != null) body['nivel'] = nivel;

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      // ✅ TEMPORAL — diagnóstico
      debugPrint('Register status: ${response.statusCode}');
      debugPrint('Register body: ${response.body}');

      return response.statusCode == 201;
    } catch (e) {
      debugPrint('Register exception: $e');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _storage.delete(key: 'auth_token');
      debugPrint("Sesión cerrada. Token eliminado.");
    } catch (e) {
      debugPrint("Error al cerrar sesión: $e");
    }
  }
}