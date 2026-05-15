// Este código es una composición basada en patrones oficiales de Flutter/Dart
// y los recursos de referencia indicados

class UserModel {
  final String id;
  final String nombre;
  final String email;
  final String? token;
  final double? pesoActual;
  final double? altura;
  final int? entrenamientos;
  final int? edad;
  final double? pesoObjetivo;
  final String? experiencia;
  final String? fechaMiembro;       // ← Este campo ya existía
  final int? entrenamientosRealizados;

  UserModel({
    required this.id,
    required this.nombre,
    required this.email,
    this.token,
    this.pesoActual,
    this.altura,
    this.entrenamientos,
    this.edad,
    this.pesoObjetivo,
    this.experiencia,
    this.fechaMiembro,
    this.entrenamientosRealizados,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, [String? token]) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      nombre: json['nombre'] ?? 'Usuario',
      email: json['email'] ?? '',
      token: token,
      pesoActual: (json['pesoActual'] as num?)?.toDouble(),
      altura: (json['altura'] as num?)?.toDouble(),
      entrenamientos: json['entrenamientos'] ?? 0,
      edad: json['edad'],
      pesoObjetivo: (json['pesoObjetivo'] as num?)?.toDouble(),
      experiencia: json['experiencia'] ?? '-',
      // ✅ CORRECCIÓN: mapeamos fecha_registro desde el servidor
      fechaMiembro: json['fecha_registro'] as String?,
      entrenamientosRealizados: json['entrenamientosRealizados'],
    );
  }
}