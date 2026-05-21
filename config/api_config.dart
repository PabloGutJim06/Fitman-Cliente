class ApiConfig {
  static const String baseUrl = "http://10.0.2.2:3000/api";

  // Endpoints específicos
  static const String login = "$baseUrl/usuarios/login";
  static const String rutinas = "$baseUrl/rutinas";
  static const String userMe = "$baseUrl/usuarios/me";
  static const String registros = "$baseUrl/registros";
  static const String registrosResumen = "$baseUrl/registros/resumen";
  static const String register = "$baseUrl/usuarios/register";
  static const String ejercicios = "$baseUrl/ejercicios";
}