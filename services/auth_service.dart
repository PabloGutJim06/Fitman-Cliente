// Este código es una composición basada en patrones oficiales de Flutter/Dart
// y los recursos de referencia indicados

import 'dart:convert';
import 'package:flutter/foundation.dart'; // ← debugPrint viene de aquí, no de cupertino
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
        // ✅ debugPrint en lugar de print — no aparece en release builds
        debugPrint("Login fallido [${response.statusCode}]: ${response.body}");
        return null;
      }
    } catch (e) {
      debugPrint("Error de red en login: $e");
      return null;
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