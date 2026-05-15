class ApiConfig {
  // Si usas emulador de Android: 10.0.2.2
  // Si usas iOS o Web: localhost
  // Si usas Render: https://tu-app.onrender.com/api
  static const String baseUrl = "http://10.0.2.2:3000/api";

  // Endpoints específicos
  static const String login = "$baseUrl/usuarios/login";
  static const String rutinas = "$baseUrl/rutinas";
  static const String userMe = "$baseUrl/usuarios/me";
  static const String registros = "$baseUrl/registros";
  static const String registrosResumen = "$baseUrl/registros/resumen";
}