class UserModel {
  final String id;
  final String nombre;
  final String email;
  final String? token;
  final double? pesoActual;
  final int? edad;
  final double? altura;
  final String? nivel;
  final String? objetivo;
  final String? fechaMiembro;

  UserModel({
    required this.id,
    required this.nombre,
    required this.email,
    this.token,
    this.pesoActual,
    this.edad,
    this.altura,
    this.nivel,
    this.objetivo,
    this.fechaMiembro,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, [String? token]) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      nombre: json['nombre'] ?? 'Usuario',
      email: json['email'] ?? '',
      token: token,
      pesoActual: (json['peso_actual'] as num?)?.toDouble(),
      edad: json['edad'] as int?,
      altura: (json['altura'] as num?)?.toDouble(),
      nivel: json['nivel'] as String?,
      objetivo: json['objetivo'] as String?,
      fechaMiembro: json['fecha_registro'] as String?,
    );
  }
}